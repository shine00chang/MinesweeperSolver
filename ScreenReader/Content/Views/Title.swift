//
//  Title.swift
//  ScreenReader
//
//  Created by shine on 5/20/21.
//

import SwiftUI

struct Title: View {

    let WindowOwnerFilter: [String] = ["Creative Cloud", "Control Center", "Window Server", "Notification Center", "Dock", "TextInputMenuAgent", "Spotlight"]
    
    let windowSelector:WindowSelector = WindowSelector()!
    @State var targetMode: Bool = false
    @State var targetWindow: TargetWindow?
    
    func captureImage(id: CGWindowID) -> CGImage? {
        let image = CGWindowListCreateImage(.null, .optionIncludingWindow, id, .boundsIgnoreFraming)
        return image
    }
    
    var body: some View {
        
        if self.targetMode {
            ScreenView(targetWindow: self.targetWindow!)
        }
        else {
            let windows: [CFDictionary] = self.windowSelector.windows
            ScrollView {
                ForEach (windows.indices, id: \.self) { index in
                    let window = (windows[index] as? [String: Any])!
                    let OwnerName = (window[kCGWindowOwnerName as String] as? String)!
                    
                    // insures that unwanted windows are filtered
                    if  self.WindowOwnerFilter.contains(OwnerName) == false {
                        // [Doesn't work] insures that Xcode's pop-up "build succeded" will not be counted, as it is temporary
                        if (OwnerName == "Xcode" && index == 1) || OwnerName != "Xcode" {
                            
                            let id = CGWindowID((window[kCGWindowNumber as String] as? Int)!)
                            let image = self.captureImage(id: id)!
                            
                            Image(
                                decorative: image,
                                scale: 0.1
                            )
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            
                            
                            HStack {
                                Text("Owner: \((window[kCGWindowOwnerName as String] as? String)!); Title: \(OwnerName)")
                                Button("Set as Target") {
                                    self.targetWindow = self.windowSelector.setTarget(index: index)
                                    self.targetMode = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

