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
    
    public var playNotificationName: NSNotification.Name
        {
        get { return NSNotification.Name(faderId + ":Play") }
    }
    
    public var stopNotificationName: NSNotification.Name
        {
        get { return NSNotification.Name(faderId + ":Stop") }
    }
    
    private var player: AKAudioPlayer? = nil
    private var _nextPlayer: AKAudioPlayer? = nil

    private let _audioFileQueue = Queue<AKAudioFile>()
    
    public var currentlyPlaying: String? {
        get {
            return player?.audioFile.fileName
        }
    }
    
    public var cued: [String] {
        get
        {
            var cuedFileNames = audioFileQueue.getElements().map(
                { (file: AKAudioFile) -> String in file.fileName })

            if let nextPlayer = _nextPlayer
            {
                cuedFileNames = [nextPlayer.audioFile.fileName] + cuedFileNames
            }
            
            return cuedFileNames
        }
    }

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
        if (_nextPlayer == nil)
        {
            do
            {
                _nextPlayer = try AKAudioPlayer(file: file)
            }
            catch
            {
                // Hmm
            }
        }
        else
        {
            _audioFileQueue.enqueue(file)
        }
    }

    public func tryCueAudio(absoluteFilePath path: String) -> Bool
    {
        let firstCharIndex = path.index(path.startIndex, offsetBy: 1)

        if (path.substring(to: firstCharIndex) != "/")
        {
            return false
        }

        let filePath = "../../.." + path
        do
        {
            let audioFile = try AKAudioFile(readFileName: filePath, baseDir: .documents)
            cueAudio(file: audioFile)
            return true
        }
        catch
        {
            return false
        }
    }

    public func tryCueAudio(filePathInUserFolder path: String) -> Bool
    {
        let firstCharIndex = path.index(path.startIndex, offsetBy: 1)
        if (path.substring(to: firstCharIndex) == "/")
        {
            return false
        }

        let filePath = "../" + path
        do
        {
            let audioFile = try AKAudioFile(readFileName: filePath, baseDir: .documents)
            cueAudio(file: audioFile)
            return true
        }
        catch
        {
            return false
        }
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
        if (!_audioFileQueue.isEmpty || _nextPlayer != nil)
        {
            do
            {
                if (player == nil && _nextPlayer == nil)
                {
                    return false
                }
                _mixer.connect(_nextPlayer!)
                _nextPlayer?.start()
                player?.stop()
                player = _nextPlayer

                if (_audioFileQueue.isEmpty)
                {
                    _nextPlayer = nil
                }
                else
                {
                    do
                    {
                        _nextPlayer = try AKAudioPlayer(file: _audioFileQueue.dequeue()!)
                    }
                    catch
                    {
                        NotificationCenter.default.post(name: playNotificationName, object: self)
                        return true
                    }
                }
                NotificationCenter.default.post(name: playNotificationName, object: self)
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
        NotificationCenter.default.post(name: stopNotificationName, object: self)
    }
}
