//
//  WindowSelector .swift
//  ScreenReader
//
//  Created by shine on 5/25/21.
//

import Cocoa
import CoreGraphics


struct WindowSelector {
    
    let windows: [CFDictionary]
    let isSet: Bool = false;
    
    init?() {
        self.windows = (CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [CFDictionary])!
    }
    
    func setTarget (index: Int) -> TargetWindow? {
        let targetWindow = TargetWindow(windows: windows, index: index)
        return targetWindow
    }
}



