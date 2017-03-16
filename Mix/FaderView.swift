//
//  FaderView.swift
//  Mix
//
//  Created by Tom Bryant on 01/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa
import AudioKit

public class FaderView: NSView {

    // View
    override public var isOpaque: Bool { get { return true } }

    public let faderId = NSUUID().uuidString

    // Notification Center stuff
    private let notifier = NotificationCenter.default

    public var volumeNotificationName: NSNotification.Name
    {
        get { return NSNotification.Name(faderId + ":VolumeChanged") }
    }

    public var volumeChangedFromZeroNotificationName: NSNotification.Name
    {
        get { return NSNotification.Name(faderId + ":VolumeChangedFromZero") }
    }

    public var volumeChangedToZeroNotificationName: NSNotification.Name
    {
        get { return NSNotification.Name(faderId + ":VolumeChangedToZero") }
    }
    
    // Audio out
    public let output: AKMixer = AKMixer()
    public let _mixer: AKMixer = AKMixer()
    private let amplitudeTracker: AKAmplitudeTracker

    // Volume
    private var _volume: Double = 0.5
    public var volume: Double {
        get { return _volume }
        set(newVolume) {
            var normalisedNewVolume = newVolume

            if (newVolume > 1)
            {
                normalisedNewVolume = 1
            }
            else if (newVolume < 0)
            {
                normalisedNewVolume = 0
            }

            let previousVolume = volume
            _volume = normalisedNewVolume
            
            setNeedsDisplay(bounds)
            
            _mixer.volume = volume
            
            self.performSelector(onMainThread: #selector(setNeedsDisplay), with: nil, waitUntilDone: true)

            notifier.post(name: volumeNotificationName, object: volume)

            if (volume == 0 && previousVolume != 0)
            {
                notifier.post(name: volumeChangedToZeroNotificationName, object: volume)
            }
            else if (volume != 0 && previousVolume == 0)
            {
                notifier.post(name: volumeChangedFromZeroNotificationName, object: volume)
            }
        }
    }

    // Drawable object stuff
    private let trackWidth = CGFloat(20)
    private let trackTopMargin = CGFloat(40)
    private let trackBottomMargin = CGFloat(80)

    private var trackHeight: CGFloat
    {
        get { return bounds.height - trackTopMargin - trackBottomMargin }
    }

    private var trackX: CGFloat
    {
        get { return (bounds.width - trackWidth) / 2 }
    }

    private var trackRect: NSRect
    {
        get
        {
            return NSRect(
                x: trackX,
                y: trackBottomMargin,
                width: trackWidth,
                height: trackHeight)
        }
    }

    private let faderWidth = CGFloat(50)
    private let faderHeight = CGFloat(25)
    private var faderX: CGFloat
    {
        get { return (bounds.width - faderWidth) / 2 }
    }
    private var faderY: CGFloat
    {
        get { return trackBottomMargin + (trackHeight / 2) }
    }
    private var faderMinY: CGFloat
    {
        get { return trackBottomMargin - (faderHeight / 2) }
    }
    private var faderMaxY: CGFloat
    {
        get { return trackBottomMargin + trackHeight - (faderHeight / 2) }
    }
    private var faderRect: NSRect
    {
        get
        {
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
    private var faderColor = NSColor.black

    private let initialVolume: Double = 0.0

    public override init(frame frameRect: NSRect)
    {
        amplitudeTracker = AKAmplitudeTracker(_mixer)
        super.init(frame:frameRect)
        wireUpAudio()
    }

    public required init?(coder: NSCoder)
    {
        amplitudeTracker = AKAmplitudeTracker(_mixer)
        super.init(coder: coder)
        wireUpAudio()
    }

    private func wireUpAudio()
    {
        volume = initialVolume
        _mixer.volume = volume
        output.volume = 1
        output.connect(amplitudeTracker)
    }

    public var levelIndicator = NSLevelIndicator()
    private var levelIndicatorRect: NSRect
    {
        get {
            return NSRect(
                x: faderX,
                y: 20,
                width: faderWidth,
                height: 20)
        }
    }

    private var audioLevelUpdater: AKPlaygroundLoop? = nil

    // Can do things in here such as set up gesture recognizers
    public override func awakeFromNib()
    {
        // Number of cells
        levelIndicator.maxValue = 6
        levelIndicator.warningValue = 5
        levelIndicator.criticalValue = 6

        audioLevelUpdater = AKPlaygroundLoop(every: 0.1) {
            let level = self.getMonitorLevel(from: self.amplitudeTracker.amplitude)
            self.levelIndicator.doubleValue = level
        }

        self.addSubview(levelIndicator)
    }

    private func getMonitorLevel(from actualLevel: Double) -> Double {
        let multiplier = 6
        return actualLevel.squareRoot() * multiplier
    }

    public override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)

        backgroundColor.set()
        NSBezierPath.fill(bounds)

        NSColor.black.set()
        NSBezierPath.setDefaultLineWidth(CGFloat(5))
        NSBezierPath.stroke(bounds)

        trackColor.set()
        NSBezierPath.fill(trackRect)

        faderColor.set()
        NSBezierPath.fill(faderRect)

        levelIndicator.frame = levelIndicatorRect
    }

    var yOffset: CGFloat? = nil

    override public func scrollWheel(with event: NSEvent) {
        translateFader(y: -event.scrollingDeltaY)
    }

    override public func
        mouseDown(with event: NSEvent)
    {
        let point = self.convert(event.locationInWindow, from: nil)
        let y = point.y

        if (faderRect.contains(point) || trackRect.contains(point))
        {
            faderColor = NSColor.blue
            setNeedsDisplay(bounds)

            if (faderRect.contains(point))
            {
                yOffset = point.y - faderHeight / 2 - faderRect.origin.y
            }
            else
            {
                yOffset = CGFloat(0)
                let yTranslation = y - yOffset! - faderHeight / 2 - faderRect.origin.y
                translateFader(y: yTranslation)
            }
        }
    }

    override public func mouseUp(with event: NSEvent)
    {
        if (yOffset != nil)
        {
            faderColor = NSColor.black
            setNeedsDisplay(bounds)
            yOffset = nil
        }
    }

    override public func mouseDragged(with event: NSEvent)
    {
        if (yOffset != nil)
        {
            let location = self.convert(event.locationInWindow, from: nil)
            let y = location.y

            let yTranslation = y - yOffset! - faderHeight / 2 - faderRect.origin.y
            translateFader(y: yTranslation)
        }
    }

    private func translateFader(y translationY: CGFloat)
    {
        let maxTranslationY = trackHeight

        let newVolume = volume + Float(translationY / maxTranslationY)
        if (newVolume > 1) {
            volume = 1
        } else if (newVolume < 0) {
            volume = 0
        } else {
            volume = newVolume
        }
    }
}
