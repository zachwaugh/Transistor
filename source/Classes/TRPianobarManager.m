//
//  TRPianobarManager.m
//  Transistor
//
//  Created by Zach Waugh on 2/13/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import "TRPianobarManager.h"
#import <signal.h>

// Notifications
NSString * const TransistorSelectStationNotification = @"TransistorSelectStationNotification";


@interface TRPianobarManager ()

- (void)parseEventInfo:(NSString *)info;
- (void)processOutput:(NSString *)output;
- (void)handleSongStartEvent:(NSNotification *)notification;

@end


@implementation TRPianobarManager

@synthesize currentArtist, currentSong, currentAlbum, currentTime, currentArtworkURL, stationList;
@synthesize username, password;

- (id)init
{
	if ((self = [super init]))
	{
		// Notification data available from stdout
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputAvailable:) name:NSFileHandleReadCompletionNotification object:nil];
		
		// Notification for data from TransistorHelper via pianobar event_command
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSongStartEvent:) name:@"TransistorSongStartEventNotification" object:nil suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];	
		
		// Info about current song
		currentArtist = @"";
		currentSong = @"";
		currentAlbum = @"";
		currentTime = @"";
		stationList = @"";
		stationsStarted = NO;
		
		// Basic plumbing for communicating with the pianobar process
		/*outputPipe = [[NSPipe pipe] retain];
		 inputPipe = [[NSPipe pipe] retain];
		 readHandle = [outputPipe fileHandleForReading];
		 writeHandle = [inputPipe fileHandleForWriting];
		 
		 pianobar = [[NSTask alloc] init];
		 
		 // TODO: make path customizable
		 [pianobar setLaunchPath:@"/usr/local/bin/pianobar"];
		 [pianobar setStandardOutput:outputPipe];
		 [pianobar setStandardInput:inputPipe];
		 [pianobar setStandardError:outputPipe];
		 
		 // get data asynchronously and notify when available
		 [readHandle readInBackgroundAndNotify];
		 
		 [pianobar launch];*/
	}
	
	return self;
}

- (void)launch
{
	// Basic plumbing for communicating with the pianobar process
	outputPipe = [NSPipe pipe];
	inputPipe = [NSPipe pipe];
	readHandle = [outputPipe fileHandleForReading];
	writeHandle = [inputPipe fileHandleForWriting];
	
	pianobar = [[NSTask alloc] init];
	
	// TODO: make path customizable
	[pianobar setLaunchPath:@"/usr/local/bin/pianobar"];
	[pianobar setStandardOutput:outputPipe];
	[pianobar setStandardInput:inputPipe];
	[pianobar setStandardError:outputPipe];
	
	// get data asynchronously and notify when available
	[readHandle readInBackgroundAndNotify];
	
	[pianobar launch];
}


// Quit pianobar process
- (void)quit
{
	NSLog(@"quitting pianobar");
	
	if ([pianobar isRunning])
	{
		[self sendCommand:QUIT];
		[pianobar terminate];
	}
	
	pianobar = nil;
}


// Sends a command to pianobar via stdin
- (void)sendCommand:(NSString *)command
{
	NSLog(@"pianobar: sendCommand: %@", command);
	// http://stackoverflow.com/questions/1294436/how-to-catch-sigpipe-in-iphone-app
	signal(SIGPIPE, SigPipeHandler);
	[writeHandle writeData:[[NSString stringWithFormat:@"%@\n", command] dataUsingEncoding:NSUTF8StringEncoding]];
}

void SigPipeHandler(int s)
{
	// do your handling
}


// Notification when output is available from pianobar 
- (void)outputAvailable: (NSNotification *)notification
{
	NSData *data = [[notification userInfo] objectForKey:@"NSFileHandleNotificationDataItem"];
	
	if ([data length])
	{
		[self processOutput:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
		
		[readHandle readInBackgroundAndNotify];
	}
}


// Take all the output and figure out what to do with it
- (void)processOutput:(NSString *)output
{
	NSLog(@"raw output:\n%@", output);
	
	// Remove whitespace and newlines from output as well as the character pianobar starts every line with
	NSString *cleaned = [[[output stringByReplacingOccurrencesOfString:@"\033[2K" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// Concatenate station list output
	if (stationsStarted)
	{
		self.stationList = [self.stationList stringByAppendingFormat:@"%@\n", cleaned];
	}
	
	// Time lines are prefixed with #
	if ([cleaned hasPrefix:@"#"])
	{
		self.currentTime = [cleaned stringByReplacingOccurrencesOfString:@"#  " withString:@""];
	}
	else if ([cleaned rangeOfString:@"Email"].location != NSNotFound)
	{
		// Not using at the moment, username should be in ~/.config/pianobar/config
		[self sendCommand:username];
	}
	else if ([cleaned rangeOfString:@"Password"].location != NSNotFound) 
	{
		// Not using at the moment, password should be in ~/.config/pianobar/config
		[self sendCommand:password];
	}
	else if ([cleaned rangeOfString:@"Get stations"].location != NSNotFound)
	{
		// Start of station list output
		stationsStarted = YES;
	}
	else if ([cleaned rangeOfString:@"Select station"].location != NSNotFound)
	{
		// End of station list output, prompt for selecting station
		stationsStarted = NO;
		
		// A little more specific cleanup
		self.stationList = [self.stationList stringByReplacingOccurrencesOfString:@"Ok.\n" withString:@""];
		self.stationList = [self.stationList stringByReplacingOccurrencesOfString:@"\n[?] Select station:\n" withString:@""];
		
		// Notification that we need to choose a station
		[[NSNotificationCenter defaultCenter] postNotificationName:TransistorSelectStationNotification object:self userInfo:[NSDictionary dictionaryWithObject:self.stationList forKey:@"stations"]];
	}
}



#pragma mark -
#pragma mark NSDistributedNotification - communication with helper app

// Only handling a single event, when a new song starts
- (void)handleSongStartEvent:(NSNotification *)notification
{
	[self parseEventInfo:[notification object]];	
}


// Data passed from helper app is one string of name = value pairs separated by newlines
// Parse into a dictionary so we can get the info we need out easier
- (void)parseEventInfo:(NSString *)info
{
	NSLog(@"event info:%@", info);
	NSMutableDictionary *data = [NSMutableDictionary dictionary];
	NSArray *lines = [[info stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"\n"];
	
	for (NSString *line in lines)
	{
		NSArray *keyValue = [line componentsSeparatedByString:@"="];
		[data setObject:[keyValue objectAtIndex:1] forKey:[keyValue objectAtIndex:0]];
	}
	
	// Use accessors to ensure KVO notifications are sent
	self.currentArtist = [data objectForKey:@"artist"];
	self.currentSong = [data objectForKey:@"title"];
	self.currentAlbum = [data objectForKey:@"album"];
	self.currentArtworkURL = [NSURL URLWithString:[data objectForKey:@"coverArt"]];
}


#pragma mark -
#pragma mark Default Apple Singleton code

+ (TRPianobarManager *)sharedManager
{
	static TRPianobarManager *shared;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		shared = [[TRPianobarManager alloc] init];
	});
	
	return shared;
}

@end
