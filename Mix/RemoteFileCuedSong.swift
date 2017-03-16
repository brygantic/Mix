//
//  RemoteFileCuedSong.swift
//  Mix
//
//  Created by Tom Bryant on 13/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Foundation

public class RemoteFileCuedSong : RemoteFileCuedAudio
{
    public let title: String
    public let artist: String
    
    convenience init(fromRemoteUrl url: String, withTitle title: String, andArtist artist: String) throws
    {
        let doNothing = {(_: URL?, _: URLResponse?, _: Error?) -> Void in return}
        
        self.init(
            fromRemoteUrl: url,
            withTitle: title,
            andArtist: artist,
            completionHandler: doNothing)
    }
    
    init(
        fromRemoteUrl url: String,
        withTitle title: String,
        andArtist artist: String,
        completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void)
    {
        self.title = title
        self.artist = artist
        super.init(
            fromRemoteUrl: url,
            withName: title,
            completionHandler: completionHandler)
    }
}
