//
//  TRMainWindowController.h
//  Transistor
//
//  Created by Zach Waugh on 2/13/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TRPianobarManager, TRArtworkView;

@interface TRMainWindowController : NSWindowController
{
    NSTextField *__weak song;
    NSTextField *__weak artist;
    NSTextField *__weak album;
    NSTextField *__weak time;
    NSImageView *__weak artwork;
    NSButton *__weak pauseButton;
    
    BOOL paused;
    TRPianobarManager *pianobar;
	
	NSMutableData *imageData;
    
    // Stations
    NSWindow *__unsafe_unretained stationsWindow;
    NSWindow *__unsafe_unretained signInWindow;
    NSTextView *__unsafe_unretained stations;
    NSTextField *__weak station;
    NSTextField *__weak usernameField;
    NSTextField *__weak passwordField;
}


@property (weak) IBOutlet NSTextField *song;
@property (weak) IBOutlet NSTextField *artist;
@property (weak) IBOutlet NSTextField *album;
@property (weak) IBOutlet NSTextField *time;
@property (weak) IBOutlet NSImageView *artwork;
@property (weak) IBOutlet NSButton *pauseButton;
@property (unsafe_unretained) IBOutlet NSWindow *stationsWindow;
@property (unsafe_unretained) IBOutlet NSWindow *signInWindow;
@property (unsafe_unretained) IBOutlet NSTextView *stations;
@property (weak) IBOutlet NSTextField *station;
@property (weak) IBOutlet NSTextField *usernameField;
@property (weak) IBOutlet NSTextField *passwordField;
@property (assign) BOOL paused;


- (void)updateArtworkWithURL:(NSURL *)artworkURL;
- (void)pause:(id)sender;
- (void)next:(id)sender;
- (void)didSelectStation:(id)sender;
- (void)showStations;
- (void)showSignIn;
- (IBAction)signIn:(id)sender;

@end
