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
	TRPianobarManager *pianobar;
	NSMutableData *imageData;
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
