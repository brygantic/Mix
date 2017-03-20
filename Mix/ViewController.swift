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
    
    @IBOutlet weak var cuedAudioFader1: CuedAudioFader!
    @IBOutlet weak var cuedAudioFader2: CuedAudioFader!
    @IBOutlet weak var cuedAudioFader3: CuedAudioFader!
    
    @IBOutlet weak var MasterFader: MasterFader!

    private var mixer: AKMixer?
    private var playerOne: AKAudioPlayer?
    private var playerTwo: AKAudioPlayer?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var audioLevelUpdater: AKPlaygroundLoop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wireUpAudio()
        
        openAudioWindow()

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
            
            vc.ConnectCuedAudioFader(cuedAudioFader1, withId: 1)
            vc.ConnectCuedAudioFader(cuedAudioFader2, withId: 2)
            vc.ConnectCuedAudioFader(cuedAudioFader3, withId: 3)
        }
    }
    
    private var _midiOut: AKMIDI?
    
    private func wireUpAudio() {
        MasterFader.connect(fader: MicFader)
        MasterFader.connect(fader: cuedAudioFader1)
        MasterFader.connect(fader: cuedAudioFader2)
        MasterFader.connect(fader: cuedAudioFader3)
        
        attachAkaiMidiControllers()
    }
    
    private var _midiListener: FaderMidiListener?
    private var _midiWriter: FaderMidiWriter?
    
    private func attachAkaiMidiControllers()
    {
        let midiInterface = AkaiMidiMixProfessionalMidiControllerInterface()
        
        let faders = [
            0: MicFader,
            1: cuedAudioFader1,
            2: cuedAudioFader2,
            3: cuedAudioFader3
            ] as [Int : FaderView]
        
        _midiListener = FaderMidiListener(usingInterface: midiInterface,
                                          forIndexedFaders: faders,
                                          andMasterFader: MasterFader)
        _midiListener!.start()
        
        _midiWriter = FaderMidiWriter(usingInterface: midiInterface,
                                      forIndexedFaders: faders)
        _midiWriter!.start()
    }
}
