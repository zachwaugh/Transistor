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

@implementation TRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  windowController = [[TRMainWindowController alloc] initWithWindowNibName:@"TRMainWindow"];
  [windowController showWindow:self];
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
	int keyRepeat = (keyFlags & 0x1);
	
	if (keyIsPressed) {
		TRMainWindowController *controller = (TRMainWindowController*)windowController;
		NSString *debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
				[controller pause:nil]; 
				debugString = [@"Play/pause pressed" stringByAppendingString:debugString];
				break;
			case NX_KEYTYPE_FAST:
				[controller next:nil];
				debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
				break;
			default:
				break;
		}
		NSLog(@"%@", debugString);
	}
}

@end

@implementation TRApp
- (void)sendEvent:(NSEvent *)theEvent
{
	// If event tap is not installed, handle events that reach the app instead
	BOOL shouldHandleMediaKeyEventLocally = [SPMediaKeyTap usesGlobalMediaKeyTap];
	
	if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
		[(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
	}
	[super sendEvent:theEvent];
}
@end
