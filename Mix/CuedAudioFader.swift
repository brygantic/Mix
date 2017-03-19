//
//  CuedAudioFader.swift
//  Mix
//
//  Created by Tom Bryant on 04/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa
import AudioKit

public class CuedAudioFader: FaderView
{
    private let playButton = NSButton()
    private let stopButton = NSButton()
    private let playOnFaderTriggerButton = NSButton()
    
    required public init?(coder: NSCoder)
    {
        super.init(coder: coder)
        startCheckIfStoppedTimer()
        configureButtons()
    }
    
    override public init(frame: NSRect)
    {
        super.init(frame: frame)
        startCheckIfStoppedTimer()
        configureButtons()
    }
    
    private func startCheckIfStoppedTimer()
    {
        Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(checkIfStopped),
            userInfo: nil,
            repeats: true)
    }
    
    private var buttonWidth: CGFloat { get { return footerBounds.width * 0.9 } }
    private var buttonHeight: CGFloat { get { return 40 } }
    
    private var playButtonRect: NSRect
    {
        get
        {
            return NSRect(
                x: footerBounds.origin.x + footerBounds.width / 2 - buttonWidth / 2,
                y: footerBounds.origin.y + footerBounds.height - buttonHeight * CGFloat(1.5),
                width: buttonWidth,
                height: buttonHeight)
        }
    }
    
    private var stopButtonRect: NSRect
    {
        get
        {
            return NSRect(
                x: footerBounds.origin.x + footerBounds.width / 2 - buttonWidth / 2,
                y: footerBounds.origin.y + footerBounds.height - buttonHeight * CGFloat(2.5),
                width: buttonWidth,
                height: buttonHeight)
        }
    }
    
    private var playOnFaderTriggerButtonRect: NSRect
    {
        get
        {
            return NSRect(
                x: footerBounds.origin.x + footerBounds.width / 2 - buttonWidth / 2,
                y: footerBounds.origin.y + footerBounds.height - buttonHeight * CGFloat(3.5),
                width: buttonWidth,
                height: buttonHeight)
        }
    }
    
    private func configureButtons()
    {
        playButton.title = "Play Next"
        playButton.setButtonType(NSMomentaryLightButton)
        playButton.bezelStyle = NSRoundedBezelStyle
        playButton.target = self
        playButton.action = #selector(forcePlayNext)
        
        stopButton.title = "Stop"
        stopButton.setButtonType(NSMomentaryLightButton)
        stopButton.bezelStyle = NSRoundedBezelStyle
        stopButton.target = self
        stopButton.action = #selector(stop)
        
        playOnFaderTriggerButton.title = "Play on Fader Trigger"
        playOnFaderTriggerButton.setButtonType(NSSwitchButton)
        playOnFaderTriggerButton.target = self
        playOnFaderTriggerButton.action = #selector(togglePlayOnFaderTrigger)
        
        addSubview(playButton)
        addSubview(stopButton)
        addSubview(playOnFaderTriggerButton)
        
        updateButtons()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateButtons),
            name: playNotificationName,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateButtons),
            name: stopNotificationName,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateButtons),
            name: cuedNotificationName,
            object: nil)
    }
    
    @objc
    private func updateButtons()
    {
        playButton.isEnabled = !cued.isEmpty
        stopButton.isEnabled = isPlaying
    }
    
    @objc
    private func togglePlayOnFaderTrigger()
    {
        playOnFaderTrigger = playOnFaderTriggerButton.intValue == 1
    }
    
    override public func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
        
        playButton.frame = playButtonRect
        stopButton.frame = stopButtonRect
        playOnFaderTriggerButton.frame = playOnFaderTriggerButtonRect
    }
    
    public var playNotificationName: NSNotification.Name
    {
        get { return NSNotification.Name(faderId + ":Play") }
    }
    
    public var stopNotificationName: NSNotification.Name
    {
        get { return NSNotification.Name(faderId + ":Stop") }
    }
    
    public var cuedNotificationName: NSNotification.Name
    {
        get { return NSNotification.Name(faderId + ":Cued") }
    }
    
    private var currentAudio: CuedAudio? = nil
    private var currentPlayer: AKAudioPlayer? = nil
    private var nextPlayer: AKAudioPlayer? = nil
    
    private let _cuedAudios = Queue<CuedAudio>()
    
    public var currentlyPlaying: String? {
        get { return currentAudio?.displayName }
    }
    
    public var cued: [String] {
        get
        {
            return _cuedAudios.getElements().map(
                { (audio: CuedAudio) -> String in audio.displayName })
        }
    }
    
    public var isPlaying: Bool
    {
        get { return currentPlayer?.isPlaying ?? false }
    }
    
    public func cue(audio: CuedAudio)
    {
        _cuedAudios.enqueue(audio)
        NotificationCenter.default.post(name: cuedNotificationName, object: self)
    }

    public var playOnFaderTrigger: Bool = false
    {
        didSet {
            if (oldValue == playOnFaderTrigger)
            {
                return;
            }

            if (oldValue)
            {
                NotificationCenter.default.removeObserver(
                    self,
                    name: volumeChangedFromZeroNotificationName,
                    object: nil)
            }
            else
            {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(tryPlay),
                    name: volumeChangedFromZeroNotificationName,
                    object: nil)
            }
        }
    }

    public func tryPlay() -> Bool
    {
        if (currentPlayer?.isPlaying ?? false)
        {
            return false
        }

        return forcePlayNext()
    }

    public func forcePlayNext() -> Bool
    {
        if _cuedAudios.front?.isReady != nil && (_cuedAudios.front?.isReady)!
        {
            let nextAudio = _cuedAudios.dequeue()!
            do
            {
                if nextPlayer == nil
                {
                    nextPlayer = try AKAudioPlayer(file: nextAudio.audioFile!, looping: false, completionHandler: stop)
                    _mixer.connect(nextPlayer!)
                }
                else
                {
                    try nextPlayer!.replace(file: nextAudio.audioFile!)
                }
            }
            catch
            {
                return false
            }
            
            nextPlayer!.start()
            currentPlayer?.stop()
            
            currentAudio = nextAudio
            
            let temp = currentPlayer
            currentPlayer = nextPlayer
            nextPlayer = temp
            
            NotificationCenter.default.post(name: playNotificationName, object: self)
            return true
        }
        return false
    }

    public func stop()
    {
        if currentPlayer?.isPlaying == true
        {
            currentPlayer?.stop()
        }
        NotificationCenter.default.post(name: stopNotificationName, object: self)
    }
    
    private var _wasPlayingLastTimeChecked: Bool = false
    @objc private func checkIfStopped()
    {
        let isPlayingCaptured = isPlaying
        
        if _wasPlayingLastTimeChecked
        {
            if !isPlayingCaptured
            {
                currentPlayer = nil
                currentAudio = nil
                NotificationCenter.default.post(name: stopNotificationName, object: self)
            }
        }
        _wasPlayingLastTimeChecked = isPlayingCaptured
    }
}
