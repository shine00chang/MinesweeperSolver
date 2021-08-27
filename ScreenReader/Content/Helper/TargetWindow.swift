//
//  Screen.swift
//  ScreenReader
//
//  Created by shine on 5/11/21.
//

import Cocoa
import CoreGraphics


struct TargetWindow {
    let id: CGWindowID
    let pos: CGPoint
    let size: CGSize
    
    init?(windows: [CFDictionary], index: Int) {
        let window = (windows[index] as? [String: Any])!
        let bounds = (window[kCGWindowBounds as String] as! [String: Any])
        self.id = CGWindowID((window[kCGWindowNumber as String] as? Int)!)
        self.pos = CGPoint(x: CGFloat(bounds["X"] as! Double), y: CGFloat(bounds["Y"] as! Double))
        self.size = CGSize(width: CGFloat(bounds["Width"] as! Double), height: CGFloat(bounds["Height"] as! Double))
    }
    
    func captureImage() -> CGImage? {
        let image = CGWindowListCreateImage(.null, .optionIncludingWindow, self.id, .boundsIgnoreFraming) 
        return image
    }
}



