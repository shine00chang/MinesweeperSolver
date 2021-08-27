//
//  Clicker.swift
//  ScreenReader
//
//  Created by shine on 6/4/21.
//

import Foundation

func LClick (pos: CGPoint) {
    // Left button down
    let leftDown = CGEvent(
        mouseEventSource: nil,
        mouseType: CGEventType.leftMouseDown,
        mouseCursorPosition: pos,
        mouseButton: .left
    )!
    leftDown.post(
        tap: .cghidEventTap
    )

    let leftUp = CGEvent(
        mouseEventSource: nil,
        mouseType: CGEventType.leftMouseUp,
        mouseCursorPosition: pos,
        mouseButton: .left
    )!
    leftUp.post(
        tap: .cghidEventTap
    )
}
