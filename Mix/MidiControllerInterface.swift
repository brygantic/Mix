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
    
    func getControllerNumberForMasterFader() -> Int
    
    func getPlayInputNoteNumberForFader(atIndex index: Int) -> MIDINoteNumber
    
    func getPlayLightOnFunctionForFader(atIndex index: Int) ->
        (function: MidiFunction, noteNumber: MIDINoteNumber, velocity: MIDIVelocity)
    
    func getPlayLightOffFunctionForFader(atIndex index: Int) ->
        (function: MidiFunction, noteNumber: MIDINoteNumber, velocity: MIDIVelocity)
}
