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
    
    public func getControllerNumberForMasterFader() -> Int
    {
        return 62
    }
    
    public func getPlayInputNoteNumberForFader(atIndex index: Int) -> MIDINoteNumber
    {
        return MIDINoteNumber(getPlayNoteNumber(fromFaderIndex: index))
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
