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
    
    private var _midiIn: AKMIDI?
    private var _midiListener: FaderMidiListener?
    
    func wireUpAudio() {
        MasterFader.connect(fader: MicFader)
        MasterFader.connect(fader: PlayerFader)
        
        let midiListener = FaderMidiListener()
        midiListener.attach(volumeController: 19, toFader: MicFader)
        midiListener.attach(volumeController: 23, toFader: PlayerFader)
        midiListener.attach(volumeController: 62, toFader: MasterFader)
        
        midiListener.attach(noteOff: 6, toFader: PlayerFader)
        
        _midiIn = AKMIDI()
        _midiIn?.openInput()
        _midiIn?.addListener(midiListener)
        _midiListener = midiListener
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
