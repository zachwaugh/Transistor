//
//  TRArtworkView.m
//  Transistor
//
//  Created by Zach Waugh on 2/13/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import "TRArtworkView.h"

@implementation TRArtworkView

@synthesize artwork;

- (void)dealloc
{
  [artwork release];
  artwork = nil;
  
  [super dealloc];
}


- (void)drawRect:(NSRect)dirtyRect
{
  if (self.artwork != nil)
  {
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
    [shadow setShadowOffset:NSMakeSize(0, -3)];
    [shadow setShadowBlurRadius:5.0];
    [shadow set];
    
    [self.artwork drawInRect:NSMakeRect(5, 0, 130, 130) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    [shadow release];
  }
}


// Flip coordinates, I hate bottom-left origin
- (BOOL)isFlipped
{
  return YES;
}


// Fade out current artwork and async load image
- (void)setArtworkURL:(NSURL *)artworkURL
{
  self.artwork = nil;
  
  [[self animator] setAlphaValue:0.0];
  
  imageData = [[NSMutableData data] retain];
  [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:artworkURL] delegate:self];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [imageData appendData:data];
}


// Update image and fade in
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  self.artwork = [[[NSImage alloc] initWithData:imageData] autorelease];
  [self setNeedsDisplay:YES];
  [[self animator] setAlphaValue:1.0];
  [imageData release];
}

@end
