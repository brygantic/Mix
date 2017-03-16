//
//  AudioCueingWindow.swift
//  Mix
//
//  Created by Tom Bryant on 05/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa

class AudioCueingView: NSViewController
{
    @IBOutlet weak var audioElement1: AudioElement!
    @IBOutlet weak var audioElement2: AudioElement!
    @IBOutlet weak var audioElement3: AudioElement!
    @IBOutlet weak var audioElement4: AudioElement!
    @IBOutlet weak var audioElement5: AudioElement!
    @IBOutlet weak var audioElement6: AudioElement!
    @IBOutlet weak var audioElement7: AudioElement!
    @IBOutlet weak var audioElement8: AudioElement!
    @IBOutlet weak var audioElement9: AudioElement!
    @IBOutlet weak var audioElement10: AudioElement!
    @IBOutlet weak var audioElement11: AudioElement!
    @IBOutlet weak var audioElement12: AudioElement!
    @IBOutlet weak var audioElement13: AudioElement!
    @IBOutlet weak var audioElement14: AudioElement!
    @IBOutlet weak var audioElement15: AudioElement!
    @IBOutlet weak var audioElement16: AudioElement!
    
    @IBOutlet weak var audioChannelSelector1: AudioChannelSelector!
    @IBOutlet weak var audioChannelSelector2: AudioChannelSelector!
    @IBOutlet weak var audioChannelSelector3: AudioChannelSelector!
    
    @IBOutlet weak var channel1CueList: NSTextField!
    @IBOutlet weak var channel2CueList: NSTextField!
    @IBOutlet weak var channel3CueList: NSTextField!
    
    @IBOutlet weak var artistInput: NSTextField!
    @IBOutlet weak var songTitleInput: NSTextField!
    @IBOutlet weak var loadButton: NSButton!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    @IBOutlet weak var songList: NSTableView!
    @IBOutlet weak var cueButton: NSButton!
    
    private var audioElements: [AudioElement] = []
    private var channelSelectors: [AudioChannelSelector] = []
    
    private var _loadedSongs = SongList()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        audioElements = [
            audioElement1,
            audioElement2,
            audioElement3,
            audioElement4,
            audioElement5,
            audioElement6,
            audioElement7,
            audioElement8,
            audioElement9,
            audioElement10,
            audioElement11,
            audioElement12,
            audioElement13,
            audioElement14,
            audioElement15,
            audioElement16,
        ]
        
        channelSelectors = [
            audioChannelSelector1,
            audioChannelSelector2,
            audioChannelSelector3
        ]
        
        loadingIndicator.isHidden = true
        
        
        // For current testing
        
        do
        {
            try audioElements[0].cuedAudio = LocalFileCuedAudio(fromFilePath: "/Users/tom/OneDrive/Radio/Beds/Bust-Out Brigade Main.aif")
            try audioElements[1].cuedAudio = LocalFileCuedAudio(fromFilePath: "/Users/tom/OneDrive/Radio/Beds/Bust-Out Brigade Out.aif")
            try audioElements[2].cuedAudio = RemoteFileCuedAudio(fromRemoteUrl: "http://0.0.0.0:9999/get_by_search?type=song&artist=Kaiser%20Chiefs", withName: "Kaiser Chiefs")
        }
        catch
        {
            print("Something fucked up")
        }
        
        for (index, audioElement) in audioElements.enumerated()
        {
            audioElement.clickFunction = { (Void) -> Void in
                self.onAudioElementClick(withAudioElementIndex: index)
            }
        }
        
        for (_, channelSelector) in channelSelectors.enumerated()
        {
            channelSelector.onSelection = self.onChannelSelection
        }
        
        songList.delegate = _loadedSongs
        songList.dataSource = _loadedSongs
    }
    
    @IBAction func onLoadButtonClick(_ sender: Any)
    {
        loadButton.isEnabled = false
        loadingIndicator.startAnimation(self)
        loadingIndicator.isHidden = false
        
        let artist = artistInput.stringValue
        
        let escapedArtist = artist
                .addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
        
        let songTitle = songTitleInput
                        .stringValue
            
        let escapedSongTitle = songTitle.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
        
        let songUrl = "http://0.0.0.0:9999/get_by_search?type=song&artist=\(escapedArtist)&title=\(escapedSongTitle)"
        
        _loadedSongs.addSong(
            RemoteFileCuedSong(
                fromRemoteUrl: songUrl,
                withTitle: songTitle,
                andArtist: artist,
                completionHandler: onDownloadCompleted))
    }

    @IBAction func onCueButtonClick(_ sender: Any)
    {
        if let channelId = selectedChannel
        {
            let song = _loadedSongs.getSong(atIndex: songList.selectedRow)!
            faders[channelId]?.cue(audio: song)
            updateCuedLists()
        }
    }
    
    private func onDownloadCompleted(_: URL?, _: URLResponse?, error: Error?)
    {
        loadButton.isEnabled = true
        performSelector(onMainThread: #selector(finishLoading), with: nil, waitUntilDone: false)
        songList.reloadData()
    }
    
    @objc private func finishLoading()
    {
        loadingIndicator.stopAnimation(self)
        loadingIndicator.isHidden = true
    }
    
    private var faders: [Int: CuedAudioFader] = [Int: CuedAudioFader]()
    
    public func ConnectCuedAudioFader(_ fader: CuedAudioFader, withId id: Int)
    {
        faders[id] = fader
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCuedLists),
            name: fader.playNotificationName,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCuedLists),
            name: fader.stopNotificationName,
            object: nil)
    }
    
    private func onAudioElementClick(withAudioElementIndex index: Int) {
        if let channelId = selectedChannel
        {
            faders[channelId]?.cue(audio: audioElements[index].cuedAudio!)
        }
        updateCuedLists()
    }
    
    private var selectedChannel: Int? = nil
    
    @objc
    private func onChannelSelection(channelId: Int) {
        selectedChannel = channelId
        for (_, channelSelector) in channelSelectors.enumerated()
        {
            if (channelSelector.id != channelId)
            {
                channelSelector.deselect()
            }
        }
    }
    
    @objc
    private func updateCuedLists() {
        if let fader = faders[1]
        {
            var text = fader.cued.joined(separator: "\n")
            if let currentlyPlaying = fader.currentlyPlaying
            {
                text = "Playing:\n" + currentlyPlaying + "\n\nCued:\n" + text
            }
            channel1CueList.stringValue = text
        }
        
        if let fader = faders[2]
        {
            var text = fader.cued.joined(separator: "\n")
            if let currentlyPlaying = fader.currentlyPlaying
            {
                text = "Playing:\n" + currentlyPlaying + "\n\nCued:\n" + text
            }
            channel1CueList.stringValue = text
        }
        
        if let fader = faders[3]
        {
            var text = fader.cued.joined(separator: "\n")
            if let currentlyPlaying = fader.currentlyPlaying
            {
                text = "Playing:\n" + currentlyPlaying + "\n\nCued:\n" + text
            }
            channel1CueList.stringValue = text
        }
    }
}
