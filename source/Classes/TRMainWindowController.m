//
//  TRMainWindowController.m
//  Transistor
//
//  Created by Zach Waugh on 2/13/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import "TRMainWindowController.h"
#import "TRPianobarManager.h"
#import "TRArtworkView.h"


@implementation TRMainWindowController

@synthesize song, artist, album, time, artwork, paused, pauseButton;

- (void)awakeFromNib
{
  // Keep reference to TRPianobarManager, which also automatically starts pianobar
  pianobar = [TRPianobarManager sharedManager];
  
  // KVO for all the current properties that pianobar exposes for automatic changes
  [pianobar addObserver:self forKeyPath:@"currentArtist" options:NSKeyValueObservingOptionNew context:nil];
  [pianobar addObserver:self forKeyPath:@"currentSong" options:NSKeyValueObservingOptionNew context:nil];
  [pianobar addObserver:self forKeyPath:@"currentAlbum" options:NSKeyValueObservingOptionNew context:nil];
  [pianobar addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:nil];
  [pianobar addObserver:self forKeyPath:@"currentArtworkURL" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  NSObject *newValue = [change objectForKey:NSKeyValueChangeNewKey];
  NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
  [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.35]];
  [shadow setShadowOffset:NSMakeSize(0, 1)];
  
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:shadow, NSShadowAttributeName, nil];
  
  if ([keyPath isEqualToString:@"currentArtist"])
  {
    [self.artist setAttributedStringValue:[[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes] autorelease]];
  }
  else if ([keyPath isEqualToString:@"currentSong"])
  {
    [self.song setAttributedStringValue:[[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes] autorelease]];
  }
  else if ([keyPath isEqualToString:@"currentAlbum"])
  {
    [self.album setAttributedStringValue:[[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes] autorelease]];
  }
  else if ([keyPath isEqualToString:@"currentTime"])
  {
    [self.time setAttributedStringValue:[[[NSAttributedString alloc] initWithString:(NSString *)newValue attributes:attributes] autorelease]];
  }
  if ([keyPath isEqualToString:@"currentArtworkURL"])
  {
    [self.artwork setArtworkURL:(NSURL *)newValue];
  }
}


#pragma -
#pragma User API

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
  [pianobar sendCommand:NEXT];
}

@end
