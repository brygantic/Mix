//
//  DoNothingMidiListener.swift
//  Mix
//
//  Created by Tom Bryant on 19/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Foundation
import AudioKit

public class LoggingMidiListener : AKMIDIListener
{
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel)
    {
        print ("receivedMIDINoteOn; noteNumber: \(noteNumber), velocity: \(velocity), channel: \(channel)")
    }
    
    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel)
    {
        print ("receivedMIDINoteOff; noteNumber: \(noteNumber), velocity: \(velocity), channel: \(channel)")
    }
    
    public func receivedMIDIController(_ controller: Int, value: Int, channel: MIDIChannel)
    {
        print ("receivedMIDIController; controller: \(controller), value: \(value), channel: \(channel)")
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
