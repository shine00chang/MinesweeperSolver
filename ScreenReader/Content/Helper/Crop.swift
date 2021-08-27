//
//  Crop.swift
//  ScreenReader
//
//  Created by shine on 5/28/21.
//

import Foundation

func cropToBounds(image: CGImage, x: Double, y: Double, width: Double, height: Double) -> CGImage {

    let posX = CGFloat(Int(x) - Int(width/2))
    let posY = CGFloat(Int(y) - Int(height/2))
    let cgwidth: CGFloat = CGFloat(width)
    let cgheight: CGFloat = CGFloat(height)

    let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

    // Create bitmap image from context using the rect
    let imageCropped: CGImage = image.cropping(to: rect)!

    return imageCropped
}
