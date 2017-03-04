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

    
    
    @IBOutlet weak var MicFader: NSSlider!
    @IBOutlet weak var MicLevelIndicator: NSLevelIndicator!
    
    @IBOutlet weak var PlayerFader: NSSlider!
    @IBOutlet weak var PlayerLevelIndicator: NSLevelIndicator!
    @IBOutlet weak var PlayerFileNameLabel: NSTextField!
    @IBOutlet weak var PlayButton: NSButton!
    
    @IBOutlet weak var MasterFader: NSSlider!
    @IBOutlet weak var MasterLevelIndicator: NSLevelIndicator!
    
    var player: AKAudioPlayer?
    var playerFile: AKAudioFile?
    var mic: AKMicrophone
    
    var trackedMicAmplitude: AKAmplitudeTracker
    var trackedPlayerAmplitude: AKAmplitudeTracker
    var trackedMixerAmplitude: AKAmplitudeTracker
    
    let mixer: AKMixer
    
    let _initialVolume = 0.5
    
    @IBAction func playSound(_ sender: NSButton) {
        playSound()
    }
    
    func playSound() {
        if (player?.isPlaying)!
        {
            player?.stop()
            PlayButton.title = "Play"
        }
        else
        {
            player?.play()
            PlayButton.title = "Stop"
        }
    }
    
    @IBAction func updateVolumes(_ sender: NSSlider)
    {
        updateVolumes()
    }
    
    func updateVolumes() {
        let masterVolume = MasterFader.doubleValue
        
        if player?.volume == 0 {
            let newPlayerVolume = PlayerFader.doubleValue
            if newPlayerVolume > 0 && !(player?.isStarted)! {
                playSound()
            }
        }
        
        mic.volume = MicFader.doubleValue * masterVolume
        player?.volume = PlayerFader.doubleValue * masterVolume
    }
    
    required init?(coder: NSCoder) {
        do {
            playerFile = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .resources)
            
            player = try AKAudioPlayer(file: playerFile!)
            player?.looping = true
            player?.volume = _initialVolume
        } catch {
        }
        
        mixer = AKMixer()
        
        mic = AKMicrophone()
        mic.volume = _initialVolume
        
        trackedMicAmplitude = AKAmplitudeTracker(mic)
        trackedPlayerAmplitude = AKAmplitudeTracker(player!)
        trackedMixerAmplitude = AKAmplitudeTracker(mixer)
        
        super.init(coder: coder)
    }
    
    var audioLevelUpdater: AKPlaygroundLoop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MicFader.doubleValue = _initialVolume
        PlayerFader.doubleValue = _initialVolume
        
        configureAmplitudeTracking()
        
        wireUpAudio()

        // Do any additional setup after loading the view.
    }
    
    func configureAmplitudeTracking() {
        trackedMicAmplitude.start()
        trackedPlayerAmplitude.start()
        trackedMixerAmplitude.start()
        
        audioLevelUpdater = AKPlaygroundLoop(every: 0.1) {
            let micLevel = self.getMonitorLevel(from: self.trackedMicAmplitude.amplitude)
            let playerLevel = self.getMonitorLevel(from: self.trackedPlayerAmplitude.amplitude)
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
        PlayerFileNameLabel.stringValue = (playerFile?.fileName)!
        
        mixer.connect(trackedMicAmplitude)
        mixer.connect(trackedPlayerAmplitude)
        
        AudioKit.output = trackedMixerAmplitude
        AudioKit.start()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
