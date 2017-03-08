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
    
    private var audioElements: [AudioElement] = []
    private var channelSelectors: [AudioChannelSelector] = []
    
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
        
        // For current testing
        
        audioElements[0].audioFilePath = "/Users/tom/OneDrive/Radio/Beds/Bust-Out Brigade Main.aif"
        audioElements[1].audioFilePath = "/Users/tom/OneDrive/Radio/Beds/Bust-Out Brigade Out.aif"
        
        // End
        
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
    }
    
    private var faders: [Int: CuedAudioFader] = [Int: CuedAudioFader]()
    
    public func ConnectCuedAudioFader(_ fader: CuedAudioFader, withId id: Int)
    {
        faders[id] = fader
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AudioCueingView.updateCuedLists),
            name: fader.playNotificationName,
            object: nil)
    }
    
    private func onAudioElementClick(withAudioElementIndex index: Int) {
        if let channelId = selectedChannel
        {
            faders[channelId]?.tryCueAudio(absoluteFilePath: audioElements[index].audioFilePath!)
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
