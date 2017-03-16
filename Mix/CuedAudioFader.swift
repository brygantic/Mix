//
//  CuedAudioFader.swift
//  Mix
//
//  Created by Tom Bryant on 04/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa
import AudioKit

public class CuedAudioFader: FaderView {

    override public func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
    }
    
    public var playNotificationName: NSNotification.Name
        {
        get { return NSNotification.Name(faderId + ":Play") }
    }
    
    public var stopNotificationName: NSNotification.Name
        {
        get { return NSNotification.Name(faderId + ":Stop") }
    }
    
    private var currentAudio: CuedAudio? = nil
    private var currentPlayer: AKAudioPlayer? = nil
    
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
                    selector: #selector(CuedAudioFader.tryPlay),
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
            let nextPlayer = nextAudio.tryMakePlayer().player
            _mixer.connect(nextPlayer!)
            nextPlayer?.start()
            currentPlayer?.stop()
            currentAudio = nextAudio
            currentPlayer = nextPlayer
            NotificationCenter.default.post(name: playNotificationName, object: self)
            return true
        }
        return false
    }

    public func stop()
    {
        currentPlayer?.stop()
        NotificationCenter.default.post(name: stopNotificationName, object: self)
    }
}
