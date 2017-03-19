//
//  FaderMidiWriter.swift
//  Mix
//
//  Created by Tom Bryant on 19/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Foundation
import AudioKit

public class FaderMidiWriter
{
    private let _midiOut: AKMIDI
    private let _midiInterface: MidiControllerInterface
    private let _faders: [Int: FaderView]
    
    init(usingInterface interface: MidiControllerInterface, forIndexedFaders faders: [Int: FaderView])
    {
        _midiOut = AKMIDI()
        _midiOut.openOutput()
        
        _midiInterface = interface
        _faders = faders
    }
    
    public func start()
    {
        reset()
        startObserving()
    }
    
    private func reset()
    {
        for noteNumber in 0...127
        {
            _midiOut.sendNoteOnMessage(
                noteNumber: MIDINoteNumber(noteNumber),
                velocity: 0,
                channel: 0)
            
            _midiOut.sendNoteOffMessage(
                noteNumber: MIDINoteNumber(noteNumber),
                velocity: 0,
                channel: 0)
        }
    }
    
    private func startObserving()
    {
        for kvp in _faders
        {
            if let fader = kvp as? (index: Int, object: CuedAudioFader)
            {
                let notificationNames = [
                    fader.object.cuedNotificationName,
                    fader.object.playNotificationName
                ]
                
                for name in notificationNames
                {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(updateEverything),
                        name: name,
                        object: nil)
                }
            }
        }
    }
    
    @objc
    private func updateEverything()
    {
        for kvp in _faders
        {
            if let fader = kvp as? (index: Int, object: CuedAudioFader)
            {
                if fader.object.cued.isEmpty
                {
                    let function = _midiInterface.getPlayLightOnFunctionForFader(atIndex: fader.index)
                    
                    runMidiFunction(function)
                }
                else
                {
                    let function = _midiInterface.getPlayLightOffFunctionForFader(atIndex: fader.index)
                    
                    runMidiFunction(function)
                }
            }
        }
    }
    
    private func runMidiFunction(_ function: (function: MidiFunction, noteNumber: MIDINoteNumber, velocity: MIDIVelocity))
    {
        switch function.function
        {
            case .noteOn:
                _midiOut.sendNoteOnMessage(noteNumber: function.noteNumber, velocity: function.velocity)
            
            case .noteOff:
                _midiOut.sendNoteOffMessage(noteNumber: function.noteNumber, velocity: function.velocity)
        }
    }
}
