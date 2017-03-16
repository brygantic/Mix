//
//  CuedAudio.swift
//  Mix
//
//  Created by Tom Bryant on 12/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import AudioKit

public protocol CuedAudio
{
    var audioFile: AKAudioFile? { get }
    var isReady: Bool { get }
    var replay: Bool { get set }
    var displayName: String { get }
    func tryMakePlayer() -> (succeeded: Bool, player: AKAudioPlayer?)
}
