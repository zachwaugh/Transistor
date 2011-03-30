//
//  TRArtworkView.h
//  Transistor
//
//  Created by Zach Waugh on 2/13/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TRArtworkView : NSView
{
  NSImage *artwork;
  NSMutableData *imageData;
}

@property (retain) NSImage *artwork;

- (void)setArtworkURL:(NSURL *)artworkURL;

@end
