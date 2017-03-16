//
//  LocalFileCuedAudio.swift
//  Mix
//
//  Created by Tom Bryant on 12/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Foundation
import AudioKit

public class LocalFileCuedAudio : CuedAudio
{
    private let _audioFile: AKAudioFile
    public var audioFile: AKAudioFile?
    {
        get { return _audioFile }
    }
    
    public var isReady: Bool
    {
        get { return true }
    }
    
    public var replay: Bool = false
    
    public var displayName: String
    {
        get { return audioFile?.fileName ?? "Unknown" }
    }
    
    public init(fromFile file: AKAudioFile) throws
    {
        _audioFile = file
    }
    
    public init(fromFilePath filePath: String) throws
    {
        _audioFile = try AKAudioFile(forReading: URL(fileURLWithPath: filePath))
    }
    
    public func tryMakePlayer() -> (succeeded: Bool, player: AKAudioPlayer?)
    {       
        do
        {
            return (succeeded: true, player: try AKAudioPlayer(file: audioFile!))
        }
        catch
        {
            return (succeeded: false, player: nil)
        }
    }
}
