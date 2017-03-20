//
//  MidiControllerInterface.swift
//  Mix
//
//  Created by Tom Bryant on 16/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Foundation
import AudioKit

public protocol MidiControllerInterface
{
    var channelNumber: Int { get }
    
    func getControllerNumberForFader(atIndex index: Int) -> Int
    func getFaderIndex(forControllerNumber controller: Int) -> Int?
    
    func getControllerNumberForMasterFader() -> Int
    func isMasterFader(controllerNumber: Int) -> Bool
    
    func getPlayInputNoteNumberForFader(atIndex index: Int) -> MIDINoteNumber
    
    func getFunctionForNoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) -> (function: FaderFunction, faderIndex: Int)?
    
    func getFunctionForNoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) -> (function: FaderFunction, faderIndex: Int)?
    
    
    // Awful names
    // Also a weird abstraction
    // - may be better having an In and Out version of MidiControllerInterface
    
    func getPlayLightOnFunctionForFader(atIndex index: Int) ->
        (function: MidiFunction, noteNumber: MIDINoteNumber, velocity: MIDIVelocity)?
    
    func getPlayLightOffFunctionForFader(atIndex index: Int) ->
        (function: MidiFunction, noteNumber: MIDINoteNumber, velocity: MIDIVelocity)?
}
