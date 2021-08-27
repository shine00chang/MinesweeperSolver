//
//  MinesweeperSolver.swift
//  ScreenReader
//
//  Created by shine on 5/28/21.
//

import Foundation

class MinesweeperSolver {
    
    let windowPos: CGPoint
    let topCorner: CGPoint
    let bottomCorner: CGPoint
    let bottomFieldCorner: CGPoint
    let topFieldCorner: CGPoint
    let blockSize: Double
    let edgeSize: Double
    let scale: Double
    let size: CGSize
    var chart: [[Int]] = []
    var isClearedChart: [[Bool]] = []
    var stuck: Bool = false
    let dx = [
        -1, 0, 1,
        -1,    1,
        -1, 0, 1
    ]
    let dy = [
        -1,-1,-1,
         0,    0,
         1, 1, 1
    ]
    let willAffectDx = [
        -2,-1, 0, 1, 2,
        -2,-1, 0, 1, 2,
        -2,-1   , 1, 2,
        -2,-1, 0, 1, 2,
        -2,-1, 0, 1, 2,
    ]
    let willAffectDy = [
        -2,-2,-2,-2,-2,
        -1,-1,-1,-1,-1,
         0, 0,    0, 0,
         1, 1, 1, 1, 1,
         2, 2, 2, 2, 2,
    ]

    init (bitmap: Bitmap, windowPos: CGPoint) {
        
        let scale = MinesweeperGetScale(bitmap: bitmap)
        let topFieldCorner = MinesweeperGetTopFieldCorner(bitmap: bitmap)
        let bottomFieldCorner = MinesweeperGetBottomFieldCorner(bitmap: bitmap)
        let topCorner = MinesweeperGetTopBoardCorner(bitmap:bitmap, FieldCornerT: topFieldCorner)
        let bottomCorner = MinesweeperGetBottomBoardCorner(bitmap:bitmap, FieldCornerB: bottomFieldCorner)
        let size = MinesweeperGetBoardSize()


        self.windowPos = windowPos
        self.scale = scale
        self.edgeSize = scale * 15
        self.blockSize = scale * 24
        self.topCorner = topCorner
        self.bottomCorner = bottomCorner
        self.size = size
        self.bottomFieldCorner = bottomFieldCorner
        self.topFieldCorner = topFieldCorner
        
        
        for y in 0...(Int( size.height ) - 1) {
            var container: [Int] = []
            for x in 0...(Int( size.width ) - 1) {
                container.append(-1)
                container[x] = MinesweeperGetSquareValue(bitmap: bitmap, gridX: x, gridY: y)
            }
            chart.append(container)
        }
        for y in 0...(Int( size.height ) - 1) {
            var container: [Bool] = []
            for x in 0...(Int( size.width ) - 1) {
                container.append(false)
                if chart[y][x] == 0 {
                    container[x] = true
                }
            }
            isClearedChart.append(container)
        }
    }
    func update (bitmap: Bitmap) {
        for y in 0...(Int( size.height ) - 1) {
            for x in 0...(Int( size.width ) - 1) {
                if chart[y][x] == -2 {      // without this, it would clear the already-marked flags
                    continue
                }
                chart[y][x] = MinesweeperGetSquareValue(bitmap: bitmap, gridX: x, gridY: y)
                if chart[y][x] == 0 {
                    isClearedChart[y][x] = true
                }
            }
        }
    }

    func printChart (num: Bool? = true, clear: Bool? = true) {
        
        if num! {
            for y in 0...(Int(size.height) - 1) {
                var str: String = ""
                for x in 0...(Int(size.width) - 1) {
                    if chart[y][x] >= 0 {
                        str += " "
                    }
                    str += "\(chart[y][x])"
                }
                print(str)
            }
            print()
        }
        
        if clear! {
            print("Filtered:")
            for y in 0...(Int(size.height) - 1) {
                var str: String = ""
                for x in 0...(Int(size.width) - 1) {
                    if !isClearedChart[y][x] {
                        str += "  "
                        continue
                    }
                    if chart[y][x] >= 0 {
                        str += " "
                    }
                    str += "\(chart[y][x])"
                }
                print(str)
            }
            print()
        }
    }
    
    func solve(bitmap: Bitmap) {
        
        var stuck = true
        
        func solveNode(x:Int, y:Int) {
            if (isClearedChart[y][x]) { // if already delt with
                return
            }
            if chart[y][x] == -2 || chart[y][x] == -1 {
                return
            }
        
            var mineCount = 0
            var unknownCount = 0
            for i in 0...7 {
                let nX = x + dx[i]
                let nY = y + dy[i]
                if nX < 0 || nX >= Int(size.width) || nY < 0 || nY >= Int(size.height) {
                    continue
                }
                if (chart[nY][nX] == -2) {
                    mineCount += 1
                }
                if (chart[nY][nX] == -1) {
                    unknownCount += 1
                }
            }
            if unknownCount + mineCount == chart[y][x] {  // If all surrounding blocks are mines, mark all
                for i in 0...7 {
                    let nX = x + dx[i]
                    let nY = y + dy[i]
                    if nX < 0 || nX >= Int(size.width) || nY < 0 || nY >= Int(size.height) {
                        continue
                    }
                    if (chart[nY][nX] == -1) {
                        chart[nY][nX] = -2
                    }
                }
                isClearedChart[y][x] = true
            }
            if mineCount == chart[y][x] {   // If all mines have been marked, flip all unknown
                for i in 0...7 {
                    let nX = x + dx[i]
                    let nY = y + dy[i]
                    if nX < 0 || nX >= Int(size.width) || nY < 0 || nY >= Int(size.height) {
                        continue
                    }
                    if (chart[nY][nX] == -1) {
                        MinesweeperGridClick(windowPos: windowPos, x:nX, y:nY)
                        chart[nY][nX] = -3//MinesweeperGetSquareValue(bitmap: bitmap, gridX: nX, gridY: nY)
                    }
                }
                isClearedChart[y][x] = true
            }
            if isClearedChart[y][x] { // If you did something, check up with people you might've affected
                callAffected(x:x, y:y)
            }
        }
        func callAffected (x:Int, y:Int) {
            stuck = false      // I placed this here because if someone is affected, that means something was deduced.
            for i in 0...23 {
                let nX = x + willAffectDx[i]
                let nY = y + willAffectDy[i]
                if nX < 0 || nX >= Int(size.width) || nY < 0 || nY >= Int(size.height) {
                    continue
                }
                solveNode(x:nX, y:nY)
            }
        }
        
        for y in 0...(Int(size.height) - 1) {
            for x in 0...(Int(size.width) - 1) {
                solveNode(x:x,y:y)
            }
        }
        self.stuck = stuck
    }
}



