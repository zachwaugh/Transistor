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
    NSTextField *song;
    NSTextField *artist;
    NSTextField *album;
    NSTextField *time;
    TRArtworkView *artwork;
    NSButton *pauseButton;
    
    BOOL paused;
    TRPianobarManager *pianobar;
    
    // Stations
    NSWindow *stationsWindow;
    NSWindow *signInWindow;
    NSTextView *stations;
    NSTextField *station;
    NSTextField *usernameField;
    NSTextField *passwordField;
}


@property (assign) IBOutlet NSTextField *song;
@property (assign) IBOutlet NSTextField *artist;
@property (assign) IBOutlet NSTextField *album;
@property (assign) IBOutlet NSTextField *time;
@property (assign) IBOutlet TRArtworkView *artwork;
@property (assign) IBOutlet NSButton *pauseButton;
@property (assign) IBOutlet NSWindow *stationsWindow;
@property (assign) IBOutlet NSWindow *signInWindow;
@property (assign) IBOutlet NSTextView *stations;
@property (assign) IBOutlet NSTextField *station;
@property (assign) IBOutlet NSTextField *usernameField;
@property (assign) IBOutlet NSTextField *passwordField;
@property (assign) BOOL paused;


- (void)pause:(id)sender;
- (void)next:(id)sender;
- (void)didSelectStation:(id)sender;
- (void)showStations;
- (void)showSignIn;
- (IBAction)signIn:(id)sender;

@end
