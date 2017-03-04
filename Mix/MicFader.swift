//
//  MicFader.swift
//  Mix
//
//  Created by Tom Bryant on 04/03/2017.
//  Copyright © 2017 Tom Bryant. All rights reserved.
//

import Cocoa
import AudioKit

class MicFader: FaderView {

    let microphone: AKMicrophone
    
    required init?(coder: NSCoder)
    {
        microphone = AKMicrophone()
        super.init(coder: coder)
        output.connect(microphone)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
