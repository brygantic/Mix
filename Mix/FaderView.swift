//
//  FaderView.swift
//  Mix
//
//  Created by Tom Bryant on 01/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa

@IBDesignable
class FaderView: NSView {
    
    // View
    override var isOpaque: Bool { get { return true } }
    
    // Notification Center stuff
    public let notifier = NotificationCenter.default
    public let faderId = NSUUID().uuidString
    public var volumeNotificationName: NSNotification.Name {
        get {
            return NSNotification.Name(faderId + ":VolumeChanged")
        }
    }
    
    // Volume
    public var volume: Float
    
    // Drawable object stuff
    private let trackWidth = CGFloat(20)
    private let trackTopMargin = CGFloat(40)
    private let trackBottomMargin = CGFloat(40)
    
    private var trackHeight: CGFloat {
        get {
            return bounds.height - trackTopMargin - trackBottomMargin
        }
    }
    
    private var trackX: CGFloat {
        get {
            return (bounds.width - trackWidth) / 2
        }
    }
    
    private var trackRect: NSRect {
        get {
            return NSRect(
                x: trackX,
                y: trackBottomMargin,
                width: trackWidth,
                height: trackHeight)
        }
    }
    
    private let faderWidth = CGFloat(50)
    private let faderHeight = CGFloat(25)
    private var faderX: CGFloat {
        get {
            return (bounds.width - faderWidth) / 2
        }
    }
    private var faderY: CGFloat {
        get {
            return trackBottomMargin + (trackHeight / 2)
        }
    }
    private var faderMinY: CGFloat {
        get {
            return trackBottomMargin - (faderHeight / 2)
        }
    }
    private var faderMaxY: CGFloat {
        get {
            return trackBottomMargin + trackHeight - (faderHeight / 2)
        }
    }
    private var faderRect: NSRect {
        get {
            return NSRect(
                x: faderX,
                y: faderMinY + (CGFloat(volume) * (faderMaxY - faderMinY)),
                width: faderWidth,
                height: faderHeight
            )
        }
    }
    
    private let backgroundColor = NSColor.lightGray
    private let trackColor = NSColor.darkGray
    private let faderColor = NSColor.black
    
    public override init(frame frameRect: NSRect) {
        volume = 0.5
        super.init(frame:frameRect)
    }
    
    public required init?(coder: NSCoder) {
        volume = 0.5
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        let panRecognizer = NSPanGestureRecognizer(target: self, action: #selector(FaderView.moveFader))
        addGestureRecognizer(panRecognizer)
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // assign fader position based on volume
        // draw
        
        backgroundColor.set()
        NSBezierPath.fill(bounds)
        
        trackColor.set()
        NSBezierPath.fill(trackRect)
        
        faderColor.set()
        NSBezierPath.fill(faderRect)
    }
    
    private func setVolume(to newVolume: Float) {
        if (newVolume > 1)
        {
            volume = 1
        } else if (newVolume < 0) {
            volume = 0
        } else {
            volume = newVolume
        }
        setNeedsDisplay(bounds)
    
        notifier.post(name: volumeNotificationName, object: volume)
    }
    
    private var previousYValue: CGFloat? = nil;
    
    @objc
    private func moveFader(gesture: NSPanGestureRecognizer) {
        let newYValue = gesture.location(in: self).y
        
        if (gesture.velocity(in: self).y == 0) {
            if (previousYValue == nil ||
                (volume == 1 && newYValue < previousYValue!) ||
                (volume == 0 && newYValue > previousYValue!)) {
                previousYValue = gesture.location(in: self).y
            }
        } else {
            if (previousYValue != nil)
            {
                
                let translationY = newYValue - previousYValue!
                
                let maxTranslationY = trackHeight
                
                let newVolume = volume + Float(translationY / maxTranslationY)
                if (newVolume > 1) {
                    setVolume(to: 1.0)
                } else if (newVolume < 0) {
                    setVolume(to: 0.0)
                } else {
                    setVolume(to: newVolume)
                    previousYValue = newYValue
                }
            }
        }
    }
}
