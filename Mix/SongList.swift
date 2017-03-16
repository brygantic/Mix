//
//  SongList.swift
//  Mix
//
//  Created by Tom Bryant on 13/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa

public class SongList : NSObject, NSTableViewDataSource, NSTableViewDelegate
{
    private var _loadedSongs: [RemoteFileCuedSong] = []
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return _loadedSongs.count
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableColumn == tableView.tableColumns[0]
        {
            if let cell = tableView.make(withIdentifier: "SongCellID", owner: nil) as? NSTableCellView
            {

                cell.textField?.stringValue = _loadedSongs[row].title
                return cell
            }
        }
        else
        {
            if let cell = tableView.make(withIdentifier: "ArtistCellID", owner: nil) as? NSTableCellView
            {
                cell.textField?.stringValue = _loadedSongs[row].artist
                return cell
            }
        }
        return nil
    }
    
    public func addSong(_ audio: RemoteFileCuedSong)
    {
        _loadedSongs.append(audio)
    }
    
    public func getSong(atIndex index: Int) -> RemoteFileCuedSong?
    {
        return _loadedSongs[index]
    }
}
