//
//  RemoteFileCuedAudio.swift
//  Mix
//
//  Created by Tom Bryant on 12/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Foundation
import AudioKit

public class RemoteFileCuedAudio : CuedAudio
{
    public var audioFile: AKAudioFile?
    
    public var isReady: Bool
    {
        get { return audioFile != nil }
    }
    
    public var replay: Bool = false
    
    private let _displayName: String
    public var displayName: String
    {
        get { return _displayName + (!isReady ? " (Loading)" : "") }
    }
    
    private var _localFilePath: URL?
    
    private var _downloadTask: URLSessionDownloadTask? = nil
    
    private let _additionalCompletionHandler: (URL?, URLResponse?, Error?) -> Void
    
    public convenience init(fromRemoteUrl urlString: String, withName name: String) throws
    {
        let doNothing = {(_: URL?, _: URLResponse?, _: Error?) -> Void in return}
        self.init(fromRemoteUrl: urlString, withName: name, completionHandler: doNothing)
    }
    
    public init(
        fromRemoteUrl urlString: String,
        withName name: String,
        completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void)
    {
        _additionalCompletionHandler = completionHandler
        audioFile = nil
        _displayName = name
        let url = URL(string: urlString)!
        let urlSession = URLSession(configuration: .default)
        _downloadTask = urlSession.downloadTask(with: url, completionHandler: onDownloadComplete)
        _downloadTask?.resume()
    }
    
    @objc
    private func onDownloadComplete(tempLocalUrl: URL?, response: URLResponse?, error: Error?)
    {
        if error == nil
        {
            do
            {
                let folder = FileManager.default
                                        .homeDirectoryForCurrentUser
                                        .appendingPathComponent("Mix")
                                        .appendingPathComponent("tmp")
                
                if !FileManager.default.fileExists(atPath: folder.absoluteString)
                {
                    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [:])
                }
                
                _localFilePath = folder.appendingPathComponent((tempLocalUrl?.lastPathComponent)!)
                try FileManager.default.copyItem(at: tempLocalUrl!, to: _localFilePath!)
                audioFile = try AKAudioFile(forReading: _localFilePath!)
                _additionalCompletionHandler(_localFilePath, response, error)
                return
            }
            catch
            {
                print("Nope, something went wrong honey")
                _additionalCompletionHandler(tempLocalUrl, response, error)
            }
        }
    }
    
    public func tryMakePlayer() -> (succeeded: Bool, player: AKAudioPlayer?)
    {
        if !isReady
        {
            return (succeeded: false, player: nil)
        }
        
        do
        {
            return (succeeded: true, player: try AKAudioPlayer(file: audioFile!))
        }
        catch
        {
            return (succeeded: false, player: nil)
        }
    }
    
    deinit
    {
        if let filePath = _localFilePath
        {
            do
            {
                try FileManager.default.removeItem(at: filePath)
            }
            catch
            {
            }
        }
    }
}
