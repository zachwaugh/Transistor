//
//  TransistorAppDelegate.m
//  Transistor
//
//  Created by Zach Waugh on 2/8/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import "TRAppDelegate.h"
#import "TRPianobarManager.h"
#import "TRMainWindowController.h"
#import "TRArtworkView.h"

@implementation TRAppDelegate

+(void)initialize;
{
	if ([self class] != [TRAppDelegate class]) return;
	
	// Register defaults for the whitelist of apps that want to use media keys
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
															 [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
															 nil]];
}

- (void)awakeFromNib
{
	NSBundle *myBundle = [NSBundle bundleForClass:[TRAppDelegate class]];
	NSString *growlPath = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
	if (growlBundle && [growlBundle load]) {
		[GrowlApplicationBridge setGrowlDelegate:self];
	} else {
		NSLog(@"Could not load Growl.framework");
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	windowController = [[TRMainWindowController alloc] initWithWindowNibName:@"TRMainWindow"];
	[windowController showWindow:self];
	
	keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if ([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
	else
		NSLog(@"Media key monitoring disabled");
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[[TRPianobarManager sharedManager] quit];
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	
	if (keyIsPressed) {
		TRMainWindowController *controller = (TRMainWindowController*)windowController;
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
				[controller pause:nil];
				[self sendGrowlNotification:nil];
				break;
			case NX_KEYTYPE_FAST:
				[controller next:nil];
				[self sendGrowlNotification:nil];
				break;
			default:
				break;
		}
	}
}

- (void)sendGrowlNotification:(NSData *)iconData
{
	TRMainWindowController *controller = (TRMainWindowController*)windowController;
	NSString *title;
	NSString *description;
	
	
	if ([controller paused]) {
		title = [[NSRunningApplication currentApplication] localizedName];
		description = @"Paused";
		iconData = nil;
	} else {
		title = [[controller song] stringValue];
		description = [NSString stringWithFormat:@"%@ - %@", [[controller artist] stringValue], [[controller album] stringValue]];
		if (iconData == nil) {
			iconData = [[[controller artwork] image] TIFFRepresentation];
		}
	}
	
	[GrowlApplicationBridge notifyWithTitle:title
								description:description
						   notificationName:@"Track Changed"
								   iconData:iconData
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}


@end

@implementation TRApp
- (void)sendEvent:(NSEvent *)theEvent
{
	// If event tap is not installed, handle events that reach the app instead
	BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
	
	if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
		[(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
	}
	[super sendEvent:theEvent];
}
@end
