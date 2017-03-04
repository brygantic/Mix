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
    @IBOutlet weak var MicLevelIndicator: NSLevelIndicator!
    
    @IBOutlet weak var PlayerFader: CuedAudioFader!
    @IBOutlet weak var PlayerLevelIndicator: NSLevelIndicator!
    @IBOutlet weak var PlayButton: NSButton!
    
    @IBOutlet weak var MasterFader: FaderView!
    @IBOutlet weak var MasterLevelIndicator: NSLevelIndicator!
    
    var trackedMicAmplitude: AKAmplitudeTracker? = nil
    var trackedPlayerAmplitude: AKAmplitudeTracker? = nil
    var trackedMixerAmplitude: AKAmplitudeTracker
    
    let mixer: AKMixer
    
    let _initialVolume = 1.0
    
    @IBAction func playSound(_ sender: NSButton) {
        PlayerFader.forcePlayNext()
    }
    
    @IBAction func updateVolumes(_ sender: NSSlider)
    {
        updateVolumesInternal()
    }
    
    func updateVolumesInternal() {
        mixer.volume = MasterFader.volume
    }
    
    required init?(coder: NSCoder) {
        mixer = AKMixer()
        
        trackedMixerAmplitude = AKAmplitudeTracker(mixer)
        
        super.init(coder: coder)
    }
    
    var audioLevelUpdater: AKPlaygroundLoop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAmplitudeTracking()
        
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.updateVolumesInternal),
            name: MicFader.volumeNotificationName,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.updateVolumesInternal),
            name: PlayerFader.volumeNotificationName,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.updateVolumesInternal),
            name: MasterFader.volumeNotificationName,
            object: nil)

        // Do any additional setup after loading the view.
    }
    
    func configureAmplitudeTracking() {
        trackedPlayerAmplitude = AKAmplitudeTracker(PlayerFader.output)
        trackedMicAmplitude = AKAmplitudeTracker(MicFader.output)
        trackedMicAmplitude?.start()
        trackedPlayerAmplitude?.start()
        trackedMixerAmplitude.start()
        
        audioLevelUpdater = AKPlaygroundLoop(every: 0.1) {
            let micLevel = self.getMonitorLevel(from: (self.trackedMicAmplitude?.amplitude)!)
            let playerLevel = self.getMonitorLevel(from: (self.trackedPlayerAmplitude?.amplitude)!)
            let mixedOutputLevel = self.getMonitorLevel(from: self.trackedMixerAmplitude.amplitude)
            
            self.MicLevelIndicator.doubleValue = micLevel
            self.PlayerLevelIndicator.doubleValue = playerLevel
            self.MasterLevelIndicator.doubleValue = mixedOutputLevel
        }
    }
    
    func getMonitorLevel(from actualLevel: Double) -> Double {
        let multiplier = 6
        return actualLevel.squareRoot() * multiplier
    }
    
    func wireUpAudio() {
        mixer.connect(trackedMicAmplitude!)
        mixer.connect(trackedPlayerAmplitude!)
        
        AudioKit.output = trackedMixerAmplitude
        AudioKit.start()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
