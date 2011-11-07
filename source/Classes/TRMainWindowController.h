//
//  TRMainWindowController.h
//  Transistor
//
//  Created by Zach Waugh on 2/13/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TRPianobarManager, TRArtworkView;

@interface TRMainWindowController : NSWindowController <NSWindowDelegate, NSAnimationDelegate>
{
	TRPianobarManager *pianobar;
	NSMutableData *imageData;
	BOOL drawerOpen;
	BOOL didDrag;
	BOOL launching;
}


@property (weak) IBOutlet NSTextField *song;
@property (weak) IBOutlet NSTextField *artist;
@property (weak) IBOutlet NSTextField *album;
@property (weak) IBOutlet NSTextField *time;
@property (weak) IBOutlet NSImageView *artwork;
@property (weak) IBOutlet NSButton *pauseButton;
@property (unsafe_unretained) IBOutlet NSWindow *signInWindow;
@property (weak) IBOutlet NSMenu *stationMenu;
@property (weak) IBOutlet NSPopUpButton *stationButton;
@property (weak) IBOutlet NSTextField *usernameField;
@property (weak) IBOutlet NSTextField *passwordField;
@property (weak) IBOutlet NSButton *rememberMe;
@property (assign) BOOL paused;
@property (weak) IBOutlet NSView *mainView;


- (void)updateArtworkWithURL:(NSURL *)artworkURL;
- (IBAction)pause:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)selectStation:(id)sender;
- (void)showStations;
- (void)showSignIn;
- (IBAction)signIn:(id)sender;
- (void)slideDrawer:(float)offset animated:(BOOL)animated;
- (void)closeDrawer:(BOOL)animated;
- (void)openDrawer:(BOOL)animated;

@end
