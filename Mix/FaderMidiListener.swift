//
//  MidiListener.swift
//  Mix
//
//  Created by Tom Bryant on 16/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Foundation
import AudioKit

public class FaderMidiListener : AKMIDIListener
{
    private var _controllers: [Int:[FaderView]] = [:]
    private var _noteOffs: [MIDINoteNumber:[CuedAudioFader]] = [:]
    
    public func attach(volumeController controller: Int, toFader fader: FaderView)
    {
        if _controllers[controller] == nil
        {
            _controllers[controller] = []
        }
        _controllers[controller]!.append(fader)
    }
    
    public func attach(noteOff noteNumber: MIDINoteNumber, toFader fader: CuedAudioFader)
    {
        if _noteOffs[noteNumber] == nil
        {
            _noteOffs[noteNumber] = []
        }
        _noteOffs[noteNumber]!.append(fader)
    }
    
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel)
    {
        print ("receivedMIDINoteOn; noteNumber: \(noteNumber), velocity: \(velocity), channel: \(channel)")
    }
    
    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel)
    {
        if let faders = _noteOffs[noteNumber]
        {
            faders.forEach({ (fader: CuedAudioFader) in
                fader.forcePlayNext()
            })
        }
        
        print ("receivedMIDINoteOff; noteNumber: \(noteNumber), velocity: \(velocity), channel: \(channel)")
    }
    
    public func receivedMIDIController(_ controller: Int, value: Int, channel: MIDIChannel)
    {
        print("Controller: \(controller)")
        
        if let faders = _controllers[controller]
        {
            let volume = value / 127.0
            
            faders.forEach({ (fader: FaderView) in
                fader.volume = volume
            })
        }
    }
    
    public func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: Int, channel: MIDIChannel)
    {
        print ("receivedMIDIAftertouch; noteNumber: \(noteNumber), pressure: \(pressure), channel: \(channel)")
    }
    
    public func receivedMIDIAfterTouch(_ pressure: Int, channel: MIDIChannel)
    {
        print ("receivedMIDIAfterTouch; pressure: \(pressure), channel: \(channel)")
    }
    
    public func receivedMIDIPitchWheel(_ pitchWheelValue: Int, channel: MIDIChannel)
    {
        print ("receivedMIDIPitchWheel; pitchWheelValue: \(pitchWheelValue), channel: \(channel)")
    }
    
    public func receivedMIDIProgramChange(_ program: Int, channel: MIDIChannel)
    {
        print ("receivedMIDIProgramChange: program: \(program), channel: \(channel)")
    }
    
    public func receivedMIDISystemCommand(_ data: [MIDIByte])
    {
        print ("receivedMIDISystemCommand; data: \(data)")
    }
    
    public func receivedMIDISetupChange()
    {
        print ("receivedMIDISetupChange")
    }
}
