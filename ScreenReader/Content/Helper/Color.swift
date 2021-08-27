//
//  Color.swift
//  ScreenReader
//
//  Created by shine on 5/23/21.
//

import Foundation
import SwiftUI

func intToHex (int: Int) -> [Int]{
    let blue = (int >> 24) & 0xFF
    let green = (int >> 16) & 0xFF
    let red = (int >> 8) & 0xFF
    let alpha = int & 0xFF
    
    return [blue,green,red, alpha]
}

extension Color {
    init(red: Int, green: Int, blue: Int) {
        self.init(red: Double(red) / 255.0, green: Double(green) / 255.0, blue: Double(blue) / 255.0, opacity: 1.0)
    }

    init(color: Int) {
        self.init(
            red: (color >> 8) & 0xFF,
            green: (color >> 16) & 0xFF,
            blue: (color >> 24) & 0xFF
        )
   }
}
