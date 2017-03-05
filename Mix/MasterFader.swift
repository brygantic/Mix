//
//  MasterFader.swift
//  Mix
//
//  Created by Tom Bryant on 05/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa
import AudioKit

class MasterFader: FaderView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        start()
    }
    
    private func start()
    {
        AudioKit.output = output
        AudioKit.start()
    }
    
    public func connect(fader: FaderView)
    {
        _mixer.connect(fader.output)
    }
}
