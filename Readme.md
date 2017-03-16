# Mix

## What is it?
Mix is a MacOS application that allows you to control different audio channels - basically a digital mixing desk.

## What features does it have?
- Control microphone input
- Cue local audio tracks to be played on a channel
- Cue Google Music* tracks to be played on a channel

## Building
- If you want to use the Google Music features, see the section below on Using Google Music
- Check out the code
- Navigate to the code root in a terminal window and run `pod install`
- Open Mix.xcworkspace in XCode, build and run!

## * Using Google Music
This requires running http://gmusicproxy.net/ on your machine before you start the Mix app.
The best way to use the Google Music Proxy is to set up a Python Virtual Env, install the proxy into it and then run it as per its instructions.
You will need to login using a Google Music premium account - using an app-specific password if you have 2FA enabled.