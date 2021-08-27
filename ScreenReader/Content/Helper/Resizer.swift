//
//  Resizer.swift
//  ScreenReader
//
//  Created by shine on 5/31/21.
//

import Foundation

extension RangeReplaceableCollection {
    public mutating func resize(_ size: IndexDistance, fillWith value: Iterator.Element) {
        let c = count
        if c < size {
            append(contentsOf: repeatElement(value, count: c.distance(to: size)))
        } else if c > size {
            let newEnd = index(startIndex, offsetBy: size)
            removeSubrange(newEnd ..< endIndex)
        }
    }
}
