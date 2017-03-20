//
//  MidiListener.swift
//  Mix
//
//  Created by Tom Bryant on 16/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Foundation
import AudioKit

public class FaderMidiListener : LoggingMidiListener
{
    private let _midiInterface: MidiControllerInterface
    private let _faders: [Int:FaderView]
    private let _masterFader: MasterFader?
    
    private let _midiIn: AKMIDI
    
    init(usingInterface interface: MidiControllerInterface,
         forIndexedFaders faders: [Int:FaderView],
         andMasterFader masterFader: MasterFader?)
    {
        _midiInterface = interface
        _faders = faders
        _masterFader = masterFader
        
        _midiIn = AKMIDI()

        super.init()
    }
    
    public func start()
    {
        _midiIn.openInput()
        _midiIn.addListener(self)
    }
    
    public override func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel)
    {
        super.receivedMIDINoteOn(noteNumber: noteNumber, velocity: velocity, channel: channel)
                
        if let function = _midiInterface.getFunctionForNoteOn(noteNumber: noteNumber, velocity: velocity)
        {
            performFunction(function)
        }
    }
    
    public override func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel)
    {
        super.receivedMIDINoteOff(noteNumber: noteNumber, velocity: velocity, channel: channel)
        
        if let function = _midiInterface.getFunctionForNoteOff(noteNumber: noteNumber, velocity: velocity)
        {
            performFunction(function)
        }
    }
    
    public override func receivedMIDIController(_ controller: Int, value: Int, channel: MIDIChannel)
    {
        super.receivedMIDIController(controller, value: value, channel: channel)
        
        if _midiInterface.isMasterFader(controllerNumber: controller)
        {
            _masterFader?.volume = value / 127.0
            return
        }
        
        if let faderIndex = _midiInterface.getFaderIndex(forControllerNumber: controller)
        {
            if let fader = _faders[faderIndex]
            {
                let volume = value / 127.0
                fader.volume = volume
            }
        }
    }
    
    private func performFunction(_ function: (function: FaderFunction, faderIndex: Int))
    {
        switch function.function
        {
            case .play:
                if let fader = _faders[function.faderIndex] as? CuedAudioFader
                {
                    fader.forcePlayNext()
                }
            
            case .stop:
                if let fader = _faders[function.faderIndex] as? CuedAudioFader
                {
                    fader.stop()
                }
        }
    }
    
    
}
