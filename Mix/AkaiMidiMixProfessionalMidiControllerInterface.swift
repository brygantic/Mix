//
//  AkaiMidiMixProfessionalMidiControllerInterface.swift
//  Mix
//
//  Created by Tom Bryant on 16/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Foundation
import AudioKit

public class AkaiMidiMixProfessionalMidiControllerInterface
    : MidiControllerInterface
{
    public var channelNumber: Int { get { return 0 } }
    
    public func getControllerNumberForFader(atIndex index: Int) -> Int
    {
        return index * 4 + 19
    }
    
    public func getFaderIndex(forControllerNumber controller: Int) -> Int
    {
        return (controller - 19) / 4
    }
    
    public func getControllerNumberForMasterFader() -> Int
    {
        return 62
    }
    
    public func isMasterFader(controllerNumber: Int) -> Bool
    {
        return controllerNumber == getControllerNumberForMasterFader()
    }
    
    public func getFunctionForNoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity)
        -> (function: FaderFunction, faderIndex: Int)?
    {
        return nil
    }
    
    public func getFunctionForNoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity)
        -> (function: FaderFunction, faderIndex: Int)?
    {
        if let faderFunction = getFaderFunction(forNoteNumber: noteNumber)
        {
            return (faderFunction, getFaderIndex(forNoteNumber: noteNumber))
        }
        return nil
    }
    
    private func getFaderFunction(forNoteNumber noteNumber: MIDINoteNumber) -> FaderFunction?
    {
        if noteNumber % 3 == 0
        {
            return .play
        }
        return nil
    }
    
    private func getFaderIndex(forNoteNumber noteNumber: MIDINoteNumber) -> Int
    {
        return Int(noteNumber / 3) - 1
    }
    
    public func getPlayInputNoteNumberForFader(atIndex index: Int) -> MIDINoteNumber
    {
        return getPlayNoteNumber(fromFaderIndex: index)
    }
    
    public func getPlayLightOnFunctionForFader(atIndex index: Int) ->
        (function: MidiFunction, noteNumber: MIDINoteNumber, velocity: MIDIVelocity)
    {
        return (
            .noteOn,
            getPlayNoteNumber(fromFaderIndex: index),
            MIDIVelocity(127))
    }
    
    public func getPlayLightOffFunctionForFader(atIndex index: Int) ->
        (function: MidiFunction, noteNumber: MIDINoteNumber, velocity: MIDIVelocity)
    {
        return (
            .noteOn,
            getPlayNoteNumber(fromFaderIndex: index),
            MIDIVelocity(0))
    }
    
    private func getPlayNoteNumber(fromFaderIndex index: Int) -> MIDINoteNumber
    {
        return MIDINoteNumber((index + 1) * 3)
    }
}
