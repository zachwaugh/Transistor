//
//  TRPianobarManager.h
//  Transistor
//
//  Created by Zach Waugh on 2/13/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define QUIT @"q"
#define PAUSE @"p"
#define NEXT @"n"

@interface TRPianobarManager : NSObject
{
  NSTask *pianobar;
	NSPipe *inputPipe;
  NSPipe *outputPipe;
  NSFileHandle *readHandle;
  NSFileHandle *writeHandle;
  
  NSString *currentArtist;
  NSString *currentSong;
  NSString *currentAlbum;
  NSString *currentTime;
  NSURL *currentArtworkURL;
}

@property (retain) NSString *currentArtist;
@property (retain) NSString *currentSong;
@property (retain) NSString *currentAlbum;
@property (retain) NSString *currentTime;
@property (retain) NSURL *currentArtworkURL;

+ (TRPianobarManager *)sharedManager;
- (void)sendCommand:(NSString *)command;
- (void)quit;

@end
