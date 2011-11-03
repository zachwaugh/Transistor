//
//  TransistorAppDelegate.h
//  Transistor
//
//  Created by Zach Waugh on 2/8/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "SPMediaKeyTap.h"

@class TRMainWindowController;

@interface TRAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate>
{
	TRMainWindowController *windowController;
	SPMediaKeyTap *keyTap;
}
- (void)sendGrowlNotification;
@end

@interface TRApp : NSApplication
@end