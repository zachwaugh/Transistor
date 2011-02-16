Transistor is a native mac app that is currently just a GUI for the [pianobar](https://github.com/PromyLOPh/pianobar) Pandora console client. I hate the Pandora flash web interface, and pianobar is a huge improvement, but I still prefer a native app. Transistor is a hacky way of achieving that, but works for now. Pianobar takes care of the all the hardwork of communicating with Pandora via a non-public API. When I have some more time, I'll most likely rewrite the pianobar Pandora API in Objective-C, or incorporate pianobar's C code directly into the app instead of launching a separate executable.


## Warning
Warning, this is definitely buggy and not even an alpha yet, put together in a few hours. I haven't spent any time yet optimizing or looking for memory leaks. But I've been using it pretty much all day for the last week, so feel free to give it a go. You can get binary from the downloads. Open an issue for any bugs or feature requests.


## Installation
First, you need to have pianobar installed. Easiest way is via homebrew, just

    brew install pianobar
    
In this first version, it assumes the pianobar binary is at /usr/local/bin/pianobar, in the final version, it'll prompt for the path if it can't find it. Next, you need to have a pianobar config in ~/.config/pianobar/config that includes your pandora username, password, and an event_command entry for the TransistorHelper. Here's an example config:

    username = yourpandorausername
    password = yourpandorapassword
    event_command = /Applications/Transistor.app/Contents/Resources/TransistorHelper


## Architecture
Transistor consists of two binaries, the Transistor app and a TransistorHelper app. The main app launches and manages the pianobar process, connecting pianobar's stdin and stdout to a Objective-C pipe. In addition to stdin and stdout, pianobar has an external events system that sends events to the TransistorHelper command line app which then sends a distributed notification to the main Transistor app. I could do it all by parsing stdout, but this is simpler for now.


## Todo
- Prompt for username and password, store in keychain
- Better UI for choosing/changing stations
- Support for other Pandora commands (thumbs up, thumbs down, bookmark, etc)
- Growl integration
- Global keyboard shortcuts for play/pause and next song (maybe intercept keyboard shortcuts iTunes uses if we can prevent them from also reaching iTunes)


