//
//  TRMainWindowController.m
//  Transistor
//
//  Created by Zach Waugh on 2/13/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import "TRMainWindowController.h"
#import "TRPianobarManager.h"
#import "TRAppDelegate.h"


@implementation TRMainWindowController

@synthesize song, artist, album, time, artwork, paused, pauseButton, stations, station, stationsWindow;
@synthesize signInWindow, usernameField, passwordField;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}


- (void)awakeFromNib
{
	// Keep reference to TRPianobarManager, which also automatically starts pianobar
	pianobar = [TRPianobarManager sharedManager];
	// Gives window time to load otherwise modal will not slide
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showSignIn) userInfo:nil repeats:NO];
	
	[pianobar addObserver:self forKeyPath:@"currentArtist" options:NSKeyValueObservingOptionNew context:nil];
	[pianobar addObserver:self forKeyPath:@"currentSong" options:NSKeyValueObservingOptionNew context:nil];
	[pianobar addObserver:self forKeyPath:@"currentAlbum" options:NSKeyValueObservingOptionNew context:nil];
	[pianobar addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:nil];
	[pianobar addObserver:self forKeyPath:@"currentArtworkURL" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSObject *newValue = [change objectForKey:NSKeyValueChangeNewKey];
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.35]];
	[shadow setShadowOffset:NSMakeSize(0, 1)];
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:shadow, NSShadowAttributeName, nil];
	
	if ([keyPath isEqualToString:@"currentArtist"])
	{
		[self.artist setAttributedStringValue:[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes]];
	}
	else if ([keyPath isEqualToString:@"currentSong"])
	{
		[self.song setAttributedStringValue:[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes]];
	}
	else if ([keyPath isEqualToString:@"currentAlbum"])
	{
		[self.album setAttributedStringValue:[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes]];
	}
	else if ([keyPath isEqualToString:@"currentTime"])
	{
		[self.time setAttributedStringValue:[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes]];
	}
	if ([keyPath isEqualToString:@"currentArtworkURL"])
	{
		[self updateArtworkWithURL:(NSURL *)newValue];
	}
}


- (void)pianobarNotification:(NSNotification *)notification
{
	if ([notification name] == TransistorSelectStationNotification)
	{
		[self showStations];
		[self.stations setString:[[notification userInfo] objectForKey:@"stations"]];
	}
}

- (void)updateArtworkWithURL:(NSURL *)artworkURL
{
	[[self.artwork animator] setAlphaValue:0.0];
	
	imageData = [NSMutableData data];
	[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:artworkURL] delegate:self];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[imageData appendData:data];
}


// Update image and fade in
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[(TRAppDelegate*)[[NSApplication sharedApplication] delegate] sendGrowlNotification:imageData];
	[self.artwork setImage:[[NSImage alloc] initWithData:imageData]];
	[[self.artwork animator] setAlphaValue:1.0];
}


#pragma mark -
#pragma mark User API

- (void)pause:(id)sender
{
	[pianobar sendCommand:PAUSE];
	
	self.paused = !self.paused;
	
	if (self.paused)
	{
		[self.pauseButton setImage:[NSImage imageNamed:@"play.png"]];
		[self.pauseButton setAlternateImage:[NSImage imageNamed:@"play_over.png"]];
	}
	else
	{
		[self.pauseButton setImage:[NSImage imageNamed:@"pause.png"]];
		[self.pauseButton setAlternateImage:[NSImage imageNamed:@"pause_over.png"]];
	}
	
}


- (void)next:(id)sender
{
	// If we are paused then unpause it
	if (self.paused) {
		self.paused = NO;
		[self.pauseButton setImage:[NSImage imageNamed:@"pause.png"]];
		[self.pauseButton setAlternateImage:[NSImage imageNamed:@"pause_over.png"]];
	}
	[pianobar sendCommand:NEXT];
}


#pragma mark -
#pragma mark Stations


- (void)showStations
{
	[NSApp beginSheet:stationsWindow modalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)showSignIn
{
	[NSApp beginSheet:signInWindow modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(sheetDidEnd) contextInfo:nil];
}

- (IBAction)signIn:(id)sender
{
	[NSApp endSheet:signInWindow];
	[signInWindow orderOut:self];
}

- (void)sheetDidEnd
{
	[pianobar setUsername:[usernameField stringValue]];
	[pianobar setPassword:[passwordField stringValue]];
	[pianobar launch];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pianobarNotification:) name:nil object:pianobar];
}


- (void)didSelectStation:(id)sender
{
	[pianobar sendCommand:[station stringValue]];
	[NSApp endSheet:stationsWindow];
	[stationsWindow orderOut:self];
}

@end
