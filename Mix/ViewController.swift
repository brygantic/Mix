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
    
    var audioLevelUpdater: AKPlaygroundLoop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wireUpAudio()
        
        do
        {
            let main = try AKAudioFile(readFileName: "../OneDrive/Radio/Beds/Bust-Out Brigade Main.aif", baseDir: .documents)
            
            PlayerFader.cueAudio(file: main)
            
            let out = try AKAudioFile(readFileName: "../OneDrive/Radio/Beds/Bust-Out Brigade Out.aif", baseDir: .documents)
            
            PlayerFader.cueAudio(file: out)
            
            PlayerFader.playOnFaderTrigger = true
        }
        catch {
            print("****")
            print("Couldn't load audio file: ")
            print(error)
            print("****")
        }

        // Do any additional setup after loading the view.
    }
    
    func wireUpAudio() {
        MasterFader.connect(fader: MicFader)
        MasterFader.connect(fader: PlayerFader)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
