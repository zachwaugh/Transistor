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
#import "NSObject+PWObject.h"

@implementation TRMainWindowController

@synthesize song, artist, album, time, artwork, paused, pauseButton, stationMenu, stationButton;
@synthesize signInWindow, usernameField, passwordField, rememberMe, mainView;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

- (void)windowDidLoad
{
	launching = YES;
	drawerOpen = YES;
	[self closeDrawer:NO];
	
	pianobar = [TRPianobarManager sharedManager];
	[pianobar addObserver:self forKeyPath:@"currentArtist" options:NSKeyValueObservingOptionNew context:nil];
	[pianobar addObserver:self forKeyPath:@"currentSong" options:NSKeyValueObservingOptionNew context:nil];
	[pianobar addObserver:self forKeyPath:@"currentAlbum" options:NSKeyValueObservingOptionNew context:nil];
	[pianobar addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:nil];
	[pianobar addObserver:self forKeyPath:@"currentArtworkURL" options:NSKeyValueObservingOptionNew context:nil];
	
	[self.artist setStringValue:@""];
	[self.song setStringValue:@""];
	[self.album setStringValue:@""];
	[self.time setStringValue:@"-00:00/00:00"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:@"remember"] && [defaults objectForKey:@"username"] && [defaults objectForKey:@"password"]) {
		[pianobar setUsername:[defaults objectForKey:@"username"]];
		[pianobar setPassword:[defaults objectForKey:@"password"]];
		[pianobar launch];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pianobarNotification:) name:nil object:pianobar];
	} else {
		[self showSignIn];
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if ([[NSApplication sharedApplication] isActive] && !didDrag) {
		if (drawerOpen) {
			[self closeDrawer:YES];
		} else {
			[self openDrawer:YES];
		}
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	didDrag = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	didDrag = YES;
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
		[self.artist setNeedsDisplay];
	}
	else if ([keyPath isEqualToString:@"currentSong"])
	{
		[self.song setAttributedStringValue:[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes]];
		[self.song setNeedsDisplay];
	}
	else if ([keyPath isEqualToString:@"currentAlbum"])
	{
		[self.album setAttributedStringValue:[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes]];
		[self.album setNeedsDisplay];
	}
	else if ([keyPath isEqualToString:@"currentTime"])
	{
		[self.time setAttributedStringValue:[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes]];
		[self.time setNeedsDisplay];
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
		[self.stationMenu removeAllItems];
		NSArray *lines = [[[notification userInfo] objectForKey:@"stations"] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		for (NSString *line in lines) {
			NSRange range = [line rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"Qq"]];
			if (range.location != NSNotFound) {
				NSString *name = [line stringByReplacingCharactersInRange:NSMakeRange(0, range.location+range.length) withString:@""];
				name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				[self.stationMenu addItemWithTitle:name action:nil keyEquivalent:@""];
			}
		}
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:@"station"] && launching) {
			[self.stationButton selectItemAtIndex:[[defaults objectForKey:@"station"] integerValue]];
			NSString *stationIndex = [NSString stringWithFormat:@"%d", stationButton.indexOfSelectedItem];
			[pianobar sendCommand:stationIndex];
			launching = NO;
		} else {
			[self showStations];
		}
	}
}

- (void)updateArtworkWithURL:(NSURL *)artworkURL
{
	if (artworkURL == nil) {
		[self.artwork setImage:[NSImage imageNamed:@"Icon.icns"]];
		[(TRAppDelegate*)[[NSApplication sharedApplication] delegate] sendGrowlNotification];
		[[self.artwork animator] setAlphaValue:1.0];
		return;
	}
	
	[[self.artwork animator] setAlphaValue:0.0];
	
	imageData = [NSMutableData data];
	[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:artworkURL] delegate:self];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self.artwork setImage:[NSImage imageNamed:@"Icon.icns"]];
	[(TRAppDelegate*)[[NSApplication sharedApplication] delegate] sendGrowlNotification];
	[[self.artwork animator] setAlphaValue:1.0];
	imageData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[imageData appendData:data];
}


// Update image and fade in
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.artwork setImage:[[NSImage alloc] initWithData:imageData]];
	[(TRAppDelegate*)[[NSApplication sharedApplication] delegate] sendGrowlNotification];
	[[self.artwork animator] setAlphaValue:1.0];
	imageData = nil;
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
	[self openDrawer:YES];
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
	if (rememberMe.state) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:YES forKey:@"remember"];
		[defaults setObject:[usernameField stringValue] forKey:@"username"];
		[defaults setObject:[passwordField stringValue] forKey:@"password"];
		[defaults synchronize];
	}
	
	[pianobar setUsername:[usernameField stringValue]];
	[pianobar setPassword:[passwordField stringValue]];
	[pianobar launch];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pianobarNotification:) name:nil object:pianobar];
}


- (IBAction)selectStation:(id)sender
{
	NSString *stationIndex = [NSString stringWithFormat:@"%d", stationButton.indexOfSelectedItem];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:stationIndex forKey:@"station"];
	[defaults synchronize];
	if (!launching) [pianobar sendCommand:STATIONS];
	[pianobar sendCommand:stationIndex];
	launching = NO;
	[self performBlock:^{
		[self closeDrawer:YES];
	} afterDelay:0.7];
}
	 
#pragma mark - Animations

- (void)slideDrawer:(float)offset animated:(BOOL)animated
{
	NSTimeInterval duration = (animated) ? 0.3 : 0.0;
	
	NSRect frame = [self.window frame];
	frame.origin.y -= offset;
	frame.size.height += offset;
	
	NSDictionary *windowResize = [NSDictionary dictionaryWithObjectsAndKeys:self.window, NSViewAnimationTargetKey, [NSValue valueWithRect:frame], NSViewAnimationEndFrameKey, nil];
	
	NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:windowResize]];
	
	[animation setAnimationBlockingMode:NSAnimationBlocking];
	[animation setAnimationCurve:NSAnimationEaseIn];
	[animation setDuration:duration];
	[animation setDelegate:self];
	[animation startAnimation];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	if (!drawerOpen) {
		[self.stationButton setEnabled:NO];
	}
}

- (void)closeDrawer:(BOOL)animated
{
	if (drawerOpen) {
		drawerOpen = NO;
		[self slideDrawer:-60.0 animated:animated];
	}
}

- (void)openDrawer:(BOOL)animated
{
	if (!drawerOpen) {
		drawerOpen = YES;
		[self.stationButton setEnabled:YES];
		[self slideDrawer:60.0 animated:animated];
	}
}

@end
