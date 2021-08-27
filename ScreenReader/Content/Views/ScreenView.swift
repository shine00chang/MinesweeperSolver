//
//  ScreenView.swift
//  ScreenReader
//
//  Created by shine on 5/25/21.
//

import SwiftUI

struct ScreenView: View {
    
    let solveMode: Bool = true
    
    let targetWindow: TargetWindow
    @State var solver: MinesweeperSolver? = nil
    let zoomW: Double = 100.0
    let zoomH: Double = 100.0
    let frameRate: Int = 33 // ms per frame
    @State var screenImage: CGImage? = nil
    @State var screenBitmap: Bitmap?
    @State var mousePos: CGPoint = CGPoint(x: 0, y:0)
    @State var mouseColor: Int = 0
    @State var mouseZoomImage: CGImage? = nil
    @State var keyZoomImage: CGImage? = nil
    @State var geoW: Int = 0
    @State var geoH: Int = 0
    @State var mouseClickTesterX: Int = 0
    @State var mouseClickTesterY: Int = 0

    init (targetWindow: TargetWindow) {
        self.targetWindow = targetWindow
        let screenImage: CGImage? = targetWindow.captureImage()
        let bitmap = Bitmap(image: screenImage!)
        self.screenImage = screenImage!
        self.screenBitmap = bitmap
    }
    
    func initSolver () {
        self.solver = MinesweeperSolver(bitmap: screenBitmap!, windowPos: targetWindow.pos)
    }
    
    func update () {
        screenImage = targetWindow.captureImage()!
        let bitmap = Bitmap(image: screenImage!)
        self.screenBitmap = bitmap
        
        if solver != nil {
            solver!.update(bitmap: bitmap)
        }
    }
    
    func onMouseClick (mouseWindowPos: CGPoint, geo: GeometryProxy) {
        let x = Double(mouseWindowPos.x) / Double( geo.size.width ) * Double(screenImage!.width )
        let y = Double(mouseWindowPos.y) / Double( geo.size.height) * Double(screenImage!.height)
        
        mousePos = CGPoint(x:Int(x),y:Int(y))
        mouseColor = getBitmapValue(
            bitmap: screenBitmap!,
            posX: Int(x),
            posY: Int(y)
        )
        mouseZoomImage = cropToBounds(
            image: screenImage!,
            x: x,
            y: y,
            width : zoomW,
            height: zoomH
        )
    }
    
    var body: some View {
        ScrollView{
            //Stats & interactive buttons
            HStack {
                if screenImage != nil {
                    VStack {
                        Text("Width: \(screenImage!.width)")
                        Text("Height: \(screenImage!.height)")
                        Text("Width: \(targetWindow.size.width)")
                        Text("Height: \(targetWindow.size.height)")
                    }
                    VStack {

                        Button("Update") {
                            self.update()
                        }
                        if solveMode {
                            Button("Clear") {
                                initSolver()
                            }
                            Button("Auto Solve") {
                                self.update()
                                
                                repeat {
                                    var windowPos = targetWindow.pos
                                    windowPos.x += CGFloat(10)
                                    windowPos.y += CGFloat(10)
                                    LClick(pos: windowPos)
                                    solver!.solve(bitmap: screenBitmap!)

                                    usleep(100000)
                                    self.update()
                                    
                                } while solver!.stuck == false
                            }
                            Button("Solve") {
                                self.update()
                                var windowPos = targetWindow.pos
                                windowPos.x += CGFloat(10)
                                windowPos.y += CGFloat(10)
                                LClick(pos: windowPos)
                                solver!.solve(bitmap: screenBitmap!)
                            }
                            Button("Print Chart") {
                                solver!.printChart()
                            }
                        }
                    }

                    VStack {
                        Text("click pos:")
                        let numberFormatter = NumberFormatter()
                        TextField(
                            "x",
                            value:  $mouseClickTesterX,
                            formatter: numberFormatter
                        )
                        .border(Color(color: 0x7b7b7bff))
                        TextField(
                            "y",
                            value: $mouseClickTesterY,
                            formatter: numberFormatter
                        )
                        .border(Color(color: 0x7b7b7bff))
                        Button("ClickTest") {
                            MinesweeperGridClick(
                                windowPos: targetWindow.pos,
                                x: mouseClickTesterX,
                                y: mouseClickTesterY
                            )
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                    VStack {
                        Text("X: \(mousePos.x)")
                        Text("Y: \(mousePos.y)")
                    }
                    VStack {
                        Text("Hex: \(mouseColor)")
                        Text("B: \(intToHex(int: self.mouseColor)[0])")
                        Text("G: \(intToHex(int: self.mouseColor)[1])")
                        Text("R: \(intToHex(int: self.mouseColor)[2])")
                        Text("A: \(intToHex(int: self.mouseColor)[3])")
                    }
                    
                    Circle()
                        .fill(Color(color: mouseColor))
                        .frame(width: 100, height: 100)
                    
                    if mouseZoomImage != nil {
                        Image(decorative: mouseZoomImage!, scale: 1.0)
                    }
                    if keyZoomImage != nil {
                        Image(decorative: keyZoomImage!, scale: 1.0)
                    }
                }
            }
            
            
            if self.screenImage != nil {
                HStack {
                    GeometryReader { geo in
                        Image(decorative: screenImage!, scale: 1.0)
                            .resizable()
                            .gesture (
                                DragGesture (minimumDistance: 0).onEnded({ (value) in
                                    self.onMouseClick(mouseWindowPos: value.location, geo: geo)
                                })
                            )
                    }
                    .aspectRatio(
                        CGFloat(Double(screenImage!.width) / Double(screenImage!.height)),
                        contentMode: .fit
                    )
                    Spacer()
                }
            }
            if (solveMode && solver != nil) {

                Divider()
                
                // Solver statistics
                HStack {
                    VStack {
                        Text("TopCorner:")
                        Text("x: \(solver!.topCorner.x)")
                        Text("y: \(solver!.topCorner.y)")
                    }
                    VStack {
                        Text("BottomCorner:")
                        Text("x: \(solver!.bottomCorner.x)")
                        Text("y: \(solver!.bottomCorner.y)")
                    }
                    VStack {
                        Text("TopFieldCorner:")
                        Text("x: \(solver!.topFieldCorner.x)")
                        Text("y: \(solver!.topFieldCorner.y)")
                    }
                    VStack {
                        Text("BottomFieldCorner:")
                        Text("x: \(solver!.bottomFieldCorner.x)")
                        Text("y: \(solver!.bottomFieldCorner.y)")
                    }
                    VStack {
                        Text("Width: \(solver!.size.width)")
                        Text("height: \(solver!.size.height)")
                    }
                    Text("Scale: \(solver!.scale)")
                }
                Divider()
            }
        }
        .onAppear() {
            self.update()
            if (solveMode) {
                self.initSolver()
            }
        }
    }
}
