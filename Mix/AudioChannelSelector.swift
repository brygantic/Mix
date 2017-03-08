//
//  AudioChannelSelector.swift
//  Mix
//
//  Created by Tom Bryant on 08/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa

@IBDesignable
class AudioChannelSelector: NSBox {

    private let defaultColor = NSColor.white
    
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
    
    required init?(coder: NSCoder) {
        let tempLabel = NSTextField()
        tempLabel.drawsBackground = false
        tempLabel.isEditable = false
        tempLabel.isBezeled = false
        tempLabel.textColor = NSColor.black
        tempLabel.alignment = NSTextAlignment.center
        
        label = tempLabel
        
        super.init(coder: coder)
        
        self.addSubview(label)
        fillColor = defaultColor
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        label.frame = labelFrame
        label.stringValue = "Channel " + String(id)
    }
    
    public let label: NSTextField
    
    @IBInspectable
    public var id: Int = 0
    
    public var onSelection: (Int) -> Void = {(x: Int) -> Void in return}
    
    public func deselect() {
        self.fillColor = defaultColor
    }
    
    override func mouseDown(with event: NSEvent) {
        onSelection(id)
        self.fillColor = NSColor.yellow
    }
}
