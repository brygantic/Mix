//
//  CuedAudioFader.swift
//  Mix
//
//  Created by Tom Bryant on 04/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa
import AudioKit

class CuedAudioFader: FaderView {

    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
    }
    
    private var player: AKAudioPlayer? = nil
    
    private let _audioFileQueue = Queue<AKAudioFile>()
    
    public var audioFileQueue: ReadOnlyQueue<AKAudioFile>
    {
        get { return _audioFileQueue as ReadOnlyQueue<AKAudioFile> }
    }
    
    public var isPlaying: Bool
    {
        get { return player != nil && (player?.isPlaying)! }
    }
    
    public func cueAudio(file: AKAudioFile)
    {
        _audioFileQueue.enqueue(file)
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
        if (player != nil && (player?.isPlaying)!)
        {
            return false
        }
        
        return forcePlayNext()
    }
    
    public func forcePlayNext() -> Bool
    {
        if (!_audioFileQueue.isEmpty)
        {
            do
            {
                if (player == nil)
                {
                    player = try AKAudioPlayer(file: _audioFileQueue.dequeue()!)
                    output.connect(player!)
                }
                else
                {
                    let newPlayer = try AKAudioPlayer(file: _audioFileQueue.dequeue()!)
                    output.connect(newPlayer)
                    newPlayer.start()
                    player?.stop()
                    player = newPlayer
                }
                player?.play()
                return true
            }
            catch
            {
                return false
            }
        }
        return false
    }
    
    public func stop()
    {
        player?.stop()
    }
}
