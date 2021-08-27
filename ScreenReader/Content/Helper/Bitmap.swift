//
//  Bitmap.swift
//  ScreenReader
//
//  Created by shine on 5/23/21.
//

import Foundation
import SwiftUI

struct Bitmap {
    init (image: CGImage) {
        let rawData: CFData = image.dataProvider!.data!
        
        self.data = rawData
        self.w = image.width
        self.h = image.height
        self.bitsPerComponent = image.bitsPerComponent
        self.bitsPerPixel = image.bitsPerPixel
        self.bytesPerRow = image.bytesPerRow
    }
    public var data: CFData?
    public var w: Int
    public var h: Int
    public var bitsPerComponent: Int
    public var bitsPerPixel: Int
    public var bytesPerRow: Int
}

func getBitmapValue (bitmap: Bitmap, posX:Int, posY:Int) -> Int {
    
    if bitmap.data == nil {
        return 0;
    }
    
    let buf: UnsafePointer<UInt8> = CFDataGetBytePtr(bitmap.data);
    
    let index: Int = (posY * bitmap.bytesPerRow) + (posX * 4)
    let b: UInt8 = buf[index]
    let g: UInt8 = buf[index+1]
    let r: UInt8 = buf[index+2]
    let a: UInt8 = buf[index+3]

    let color = (Int(b) << 24) + (Int(g) << 16) + (Int(r) << 8) + Int(a)
    return color
}
