//
//  AudioElement.swift
//  Mix
//
//  Created by Tom Bryant on 05/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa

@IBDesignable
class AudioElement: NSBox {

    required init?(coder: NSCoder)
    {
        let tempLabel = NSTextField()
        tempLabel.drawsBackground = false
        tempLabel.isEditable = false
        tempLabel.isBezeled = false
        tempLabel.textColor = NSColor.white
        tempLabel.alignment = NSTextAlignment.center

        label = tempLabel
        
        super.init(coder: coder)
        
        self.addSubview(label)
        self.fillColor = defaultColor
    }
    
    var labelFrame: NSRect {
        get {
            return NSRect(
                x: bounds.width * 0.05,
                y: bounds.height * 0.3,
                width: bounds.width * 0.9,
                height: bounds.height * 0.4
            )
        }
    }
    
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
        
        if let displayName = cuedAudio?.displayName
        {
            label.frame = labelFrame
            label.stringValue = displayName
            label.isHidden = false
            label.sizeToFit()
        }
        else
        {
            label.isHidden = true
        }

        // Drawing code here.
    }
    
    private let label: NSTextField
    
    @IBInspectable
    public var defaultColor: NSColor = NSColor.darkGray
    
    @IBInspectable
    public var highlightColor: NSColor = NSColor.blue
    
    @IBInspectable
    public var id: Int = 0
    
    public var clickFunction: (Void) -> Void = {(Void) -> Void in return}
    
    public var cuedAudio: CuedAudio? = nil
    
    public override func mouseDown(with event: NSEvent)
    {
        self.fillColor = highlightColor
        self.needsToDraw(bounds)
    }
    
    public override func rightMouseUp(with event: NSEvent) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.runModal()
        
        if let filePath = openPanel.urls.first?.absoluteString
        {
            do
            {
                let formattedFilePath = filePath.removingPercentEncoding!.replacingOccurrences(of: "file:///", with: "/")
                
                cuedAudio = try LocalFileCuedAudio(fromFilePath: formattedFilePath)
                setNeedsDisplay(bounds)
            }
            catch
            {
                Swift.print(error)
            }
        }
    }
    
    public override func mouseUp(with event: NSEvent)
    {
        self.fillColor = defaultColor
        self.needsToDraw(bounds)
        clickFunction()
    }
    
    private func GetStrippedFileName(filePath: String?) -> String?
    {
        return filePath?
            .components(separatedBy: "/")
            .last?
            .components(separatedBy: ".")
            .first
    }
}
