//
//  TransistorAppDelegate.h
//  Transistor
//
//  Created by Zach Waugh on 2/8/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TRMainWindowController;

@interface TRAppDelegate : NSObject <NSApplicationDelegate>
{
  TRMainWindowController *windowController;
}

@end
