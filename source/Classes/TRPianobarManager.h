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

extern NSString * const TransistorSelectStationNotification;

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
    NSString *stationList;
    NSString *username;
    NSString *password;
    
    BOOL stationsStarted;
}

@property (retain) NSString *currentArtist;
@property (retain) NSString *currentSong;
@property (retain) NSString *currentAlbum;
@property (retain) NSString *currentTime;
@property (retain) NSURL *currentArtworkURL;
@property (retain) NSString *stationList;
@property (retain) NSString *username;
@property (retain) NSString *password;

+ (TRPianobarManager *)sharedManager;
- (void)sendCommand:(NSString *)command;
- (void)quit;
- (void)launch;
void SigPipeHandler(int s);

@end
