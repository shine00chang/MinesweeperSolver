//
//  MinesweeperCornerFinder.swift
//  ScreenReader
//
//  Created by shine on 5/28/21.
//
// [VERY IMPORTANT] only works on advanced, 150%.
// why? because the colors are different in different modes for some reason.
import Foundation

let white  = 0xffffffff
let shadow = 0x808080ff
let base   = 0xc0c0c0ff
let scale200p = 64.0/24.0
let scale150p = 48.0/24.0
let scale100p = 32.0/24.0
let edgeSize = 15.0
let blockSize = 24.0
let toolBarSize = 78.0
let center = CGPoint(x: 12,y: 12)
var TopBoardCorner = CGPoint(x:0,y:0)
var BottomBoardCorner = CGPoint(x:0,y:0)
var scale: Double = 1.0
var size = CGSize(width: 0, height: 0)

let MinesweeperColorIdentifier = [
    0xF51D00FF: 1,
    0x227D37FF: 2,
    0x2332EBFF: 3,
    0x7B0900FF: 4,
    0x0C1475FF: 5,
    0x7F7E36FF: 6,
    0x000000FF: 7,
    0x808080FF: 8,
]



func MinesweeperGetScale (bitmap: Bitmap) -> Double {
    var pos = CGPoint(x: 0, y: 0)
    var color = 0
    
    pos.x = CGFloat( 10 )
    pos.y = 0
    // gets first base node on both x and y axis
    while color != base {
        color = getBitmapValue(
            bitmap: bitmap ,
            posX: Int(pos.x),
            posY: Int(pos.y)
        )
        pos.y += 1
    }
    
    while color == base {
        color = getBitmapValue(
            bitmap: bitmap ,
            posX: Int(pos.x),
            posY: Int(pos.y)
        )
        pos.x -= 1
    }; pos.x += 1
    
    switch (pos.x) {
        case CGFloat(8.0):
            scale = scale200p
        case CGFloat(6.0):
            scale = scale150p
        case CGFloat(4.0):
            scale = scale100p
        default:
            print("something's wrong")
    }
    return scale
}

 
func MinesweeperGetBottomFieldCorner (bitmap: Bitmap) -> CGPoint {
    var pos = CGPoint(x: 0, y: 0)
    var color = 0
    
    pos.x = CGFloat(bitmap.w - 1)
    pos.y = 300
    while color != shadow {
        color = getBitmapValue(
            bitmap: bitmap ,
            posX: Int(pos.x),
            posY: Int(pos.y)
        )
        pos.x -= 1
    }
    
    while color == shadow {
        color = getBitmapValue(
            bitmap: bitmap ,
            posX: Int(pos.x),
            posY: Int(pos.y)
        )
        pos.y += 1
    }
    pos.x -= 1
    
    return pos
}

func MinesweeperGetTopFieldCorner (bitmap: Bitmap) -> CGPoint {
    var pos = CGPoint(x: 0, y: 0)
    var color = 0
    
    pos.x = CGFloat( 10 )
    pos.y = 0
    // gets first base node on both x and y axis
    while color != base {
        color = getBitmapValue(
            bitmap: bitmap ,
            posX: Int(pos.x),
            posY: Int(pos.y)
        )
        pos.y += 1
    }
    
    while color == base {
        color = getBitmapValue(
            bitmap: bitmap ,
            posX: Int(pos.x),
            posY: Int(pos.y)
        )
        pos.x -= 1
    }; pos.x += 1
    // indent
    pos.x += CGFloat(blockSize * scale)
    pos.y += CGFloat(blockSize * scale)
    // find edge of first block
    while color != shadow {
        color = getBitmapValue(
            bitmap: bitmap ,
            posX: Int(pos.x),
            posY: Int(pos.y)
        )
        pos.x -= 1
        pos.y -= 1
    }
    pos.x += 1
    pos.y += 1
    
    pos.x -= CGFloat( (edgeSize * scale) - 1)
    pos.y -= CGFloat( (edgeSize * scale) - 1)
    return pos
}


func MinesweeperGetBoardSize () -> CGSize {
    let width = Double(BottomBoardCorner.x - TopBoardCorner.x) / (blockSize * scale)
    let height = Double(BottomBoardCorner.y - TopBoardCorner.y) / (blockSize * scale)

    size = CGSize(width: Int(width) + 1, height: Int(height) + 1)
    
    return size
}

func MinesweeperGetTopBoardCorner (bitmap: Bitmap, FieldCornerT: CGPoint) -> CGPoint {
    
    var pos = FieldCornerT
    pos.x += CGFloat( edgeSize * scale )
    pos.y += CGFloat( toolBarSize * scale ) // accounts for the edges
    
    TopBoardCorner = pos
    return pos
}

func MinesweeperGetBottomBoardCorner (bitmap: Bitmap, FieldCornerB: CGPoint) -> CGPoint {
    
    var pos = FieldCornerB
    pos.x -= CGFloat( edgeSize * scale )
    pos.y -= CGFloat( edgeSize * scale )
    
    BottomBoardCorner = pos
    return pos
}

func MinesweeperGetSquareValue (bitmap: Bitmap, gridX: Int, gridY: Int) -> Int {
    var color: Int = -1
    var isBlankBlock: Bool = true
    let offsetX = Int(TopBoardCorner.x)
    let offsetY = Int(TopBoardCorner.y)
    
    for x in 3...(Int(blockSize) - 3) {
        color = getBitmapValue(
            bitmap: bitmap ,
            posX: offsetX + (gridX * Int(blockSize * scale)) + x,
            posY: offsetY + (gridY * Int(blockSize * scale)) + Int( blockSize * scale / 2 )
        )
        if color != base {
            isBlankBlock = false
        }
        if MinesweeperColorIdentifier[color] != nil {
            return MinesweeperColorIdentifier[color]!
        }
    }
    for y in 3...(Int(blockSize) - 3) {
        color = getBitmapValue(
            bitmap: bitmap ,
            posX: offsetX + (gridX * Int(blockSize * scale)) + Int( blockSize * scale / 2 ),
            posY: offsetY + (gridY * Int( blockSize * scale)) + y
        )
        if color != base {
            isBlankBlock = false
        }
        if MinesweeperColorIdentifier[color] != nil {
            return MinesweeperColorIdentifier[color]!
        }
    }
    if isBlankBlock {
        return 0
    }
    else {
        return -1
    }
}


func MinesweeperGridClick (windowPos: CGPoint, x: Int, y:Int) {
    var pos = TopBoardCorner
    
    pos.x += CGFloat( (Double(x) + 0.5) * blockSize * scale )
    pos.y += CGFloat( (Double(y) + 0.5) * blockSize * scale )
    
    pos.x /= 2
    pos.y /= 2
    
    pos.x += windowPos.x    // windowPos is using the smaller scale, not the bigger one used by the rest of
    pos.y += windowPos.y    // the numbers.
    LClick(pos: pos)
}
