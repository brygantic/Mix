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
        
        if audioFilePath == nil
        {
            label.isHidden = true
        }
        else
        {
            label.frame = labelFrame
            label.stringValue = GetStrippedFileName(filePath: audioFilePath)!
            label.isHidden = false
            label.sizeToFit()
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
    
    public var audioFilePath: String? = nil
    
    public override func mouseDown(with event: NSEvent)
    {
        self.fillColor = highlightColor
        self.needsToDraw(bounds)
        clickFunction()
    }
    
    public override func mouseUp(with event: NSEvent)
    {
        self.fillColor = defaultColor
        self.needsToDraw(bounds)
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
