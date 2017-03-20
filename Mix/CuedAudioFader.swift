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
    
    private var currentPlayer: AKAudioPlayer?
    private var nextPlayer: AKAudioPlayer?
    
    private var currentAudio: CuedAudio? = nil
    private let _cuedAudios = Queue<CuedAudio>()
    
    required public init?(coder: NSCoder)
    {
        super.init(coder: coder)
        configureButtons()
        instantiatePlayers()
    }
    
    override public init(frame: NSRect)
    {
        super.init(frame: frame)
        configureButtons()
        instantiatePlayers()
    }
    
    private func instantiatePlayers()
    {
        do
        {
            currentPlayer = try AKAudioPlayer(file: AKAudioFile(readFileName: "drumloop.wav", baseDir: .resources), looping: false, completionHandler: stop)
            nextPlayer = try AKAudioPlayer(file: AKAudioFile(readFileName: "drumloop.wav", baseDir: .resources), looping: false, completionHandler: stop)
            _mixer.connect(currentPlayer!)
            _mixer.connect(nextPlayer!)
        }
        catch
        {
            Swift.print("Something went really wrong")
        }
    }
    
    private func eagerlyLoad()
    {
        if let frontOfQueue = _cuedAudios.front
        {
            if nextPlayer!.audioFile != frontOfQueue.audioFile
            {
                OperationQueue().addOperation()
                {
                    do
                    {
                        try self.nextPlayer?.replace(file: frontOfQueue.audioFile!)
                    }
                    catch
                    {
                        Swift.print("Could not load file for \(frontOfQueue.displayName)")
                    }
                }
                
            }
        }
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
        eagerlyLoad()
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
        if _cuedAudios.front?.isReady == true
        {
            let nextAudio = _cuedAudios.dequeue()!
            
            nextPlayer!.start()
            currentPlayer!.stop()

            let temp = currentPlayer
            currentPlayer = nextPlayer
            currentAudio = nextAudio
            nextPlayer = temp

            NotificationCenter.default.post(name: playNotificationName, object: self)
            eagerlyLoad()
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
}
