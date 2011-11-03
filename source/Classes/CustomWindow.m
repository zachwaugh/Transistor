//
//  CustomWindow.m
//  Transistor
//
//  Created by Matthew Crenshaw on 11/3/11.
//  Copyright (c) 2011 Batoul Apps. All rights reserved.
//

#import "CustomWindow.h"

@implementation CustomWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
	if (self) {
		[self setMovableByWindowBackground:YES];
		[self setLevel:NSNormalWindowLevel];
		[self makeKeyWindow];
	}
	return self;
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}

@end
