//
//  TRContentView.m
//  Transistor
//
//  Created by Zach Waugh on 2/13/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import "TRContentView.h"


@implementation TRContentView

// Draw background of window
// TODO: cache image
- (void)drawRect:(NSRect)dirtyRect
{
  [[NSImage imageNamed:@"content_bg.png"] drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
