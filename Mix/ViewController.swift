//
//  ViewController.swift
//  Mix
//
//  Created by Tom Bryant on 26/02/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa
import AudioKit

class ViewController: NSViewController {

    @IBOutlet weak var MicFader: MicFader!
    
    @IBOutlet weak var PlayerFader: CuedAudioFader!
    @IBOutlet weak var PlayButton: NSButton!
    
    @IBOutlet weak var MasterFader: MasterFader!
    
    @IBAction func playSound(_ sender: NSButton) {
        PlayerFader.forcePlayNext()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var player: AVPlayer? = nil
    
    var audioLevelUpdater: AKPlaygroundLoop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wireUpAudio()
        
        openAudioWindow()
    
        PlayerFader.playOnFaderTrigger = true

        // Do any additional setup after loading the view.
    }
    
    var audioWindow: NSWindow? = nil
    var audioWindowController: NSWindowController? = nil
    
    func openAudioWindow()
    {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateController(withIdentifier: "AudioCueingView") as? AudioCueingView
        {
            audioWindow = NSWindow(contentViewController: vc)
            audioWindow?.makeKeyAndOrderFront(self)
            audioWindowController = NSWindowController(window: audioWindow)
            audioWindowController?.showWindow(self)
            
            vc.ConnectCuedAudioFader(PlayerFader, withId: 1)
        }
    }
    
    private var _midiOut: AKMIDI?
    
    private func wireUpAudio() {
        MasterFader.connect(fader: MicFader)
        MasterFader.connect(fader: PlayerFader)
        
        attachAkaiMidiController()
    }
    
    private var _midiIn: AKMIDI?
    private var _midiListener: FaderMidiListener?
    private var _midiInterface: MidiControllerInterface?
    
    private func attachAkaiMidiController()
    {
        _midiInterface = AkaiMidiMixProfessionalMidiControllerInterface()
        
        let midiListener = FaderMidiListener()
        midiListener.attach(
            volumeController: (_midiInterface?.getControllerNumberForFader(atIndex: 0))!,
            toFader: MicFader)
        midiListener.attach(
            volumeController: (_midiInterface?.getControllerNumberForFader(atIndex: 1))!,
            toFader: PlayerFader)
        midiListener.attach(
            volumeController: (_midiInterface?.getControllerNumberForMasterFader())!,
            toFader: MasterFader)
        
        midiListener.attach(
            noteOff: (_midiInterface?.getPlayInputNoteNumberForFader(atIndex: 1))!,
            toFader: PlayerFader)
        
        _midiIn = AKMIDI()
        _midiIn?.openInput()
        _midiIn?.addListener(midiListener)
        _midiListener = midiListener
        
        _midiOut = AKMIDI()
        _midiOut?.openOutput()
        
        reset(midiOut: _midiOut!)
        playerFaderToggle()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerFaderToggle),
            name: PlayerFader.cuedNotificationName,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerFaderToggle),
            name: PlayerFader.playNotificationName,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerFaderToggle),
            name: PlayerFader.stopNotificationName,
            object: nil)
    }
    
    @objc private func playerFaderToggle()
    {
        if PlayerFader.cued.isEmpty
        {
            runMidiFunction((_midiInterface?.getPlayLightOffFunctionForFader(atIndex: 1))!)
        }
        else
        {
            runMidiFunction((_midiInterface?.getPlayLightOnFunctionForFader(atIndex: 1))!)
        }
    }
    
    private func runMidiFunction(_ function: (function: MidiFunction, noteNumber: MIDINoteNumber, velocity: MIDIVelocity))
    {
        switch function.function
        {
            case .noteOn:
                _midiOut?.sendNoteOnMessage(noteNumber: function.noteNumber, velocity: function.velocity)
            case .noteOff:
                _midiOut?.sendNoteOffMessage(noteNumber: function.noteNumber, velocity: function.velocity)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func reset(midiOut: AKMIDI)
    {
        for noteNumber in 0...127
        {
            for channel in 0...7
            {
                midiOut.sendNoteOnMessage(
                    noteNumber: MIDINoteNumber(noteNumber),
                    velocity: 0,
                    channel: MIDIChannel(channel))
            }
        }
    }
}
