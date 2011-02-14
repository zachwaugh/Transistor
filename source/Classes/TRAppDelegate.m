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
  [windowController showWindow:nil];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
  [[TRPianobarManager sharedManager] quit];
}

@end
