//
//  ContentView.swift
//  ProggressBarSwiftUI
//
//  Created by Mark Goldin on 06/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

let progressBarHeight = 20
let progressBarStripeWidth = 20
let progressBarStripePad = 15

struct Stripe: View {
    
    @Binding<Length> var value: Length
    
    var initialDeltaX: Int
    var maxWidth: CGFloat
    
    @State var deltaX = 0
    
    let timer = Timer.publish(every: 1.0/24.0, on: .current, in: .common).autoconnect()
    
    var body: some View {
        
            Path { path in
                
                //Y axis padding
                var x1Ypad = 0
                var x2Ypad = 0
                var x3Ypad = 0
                var x4Ypad = 0
                
                var shouldCalculateX4 = false
                
                let maxX = Int(self.value * maxWidth)
                if maxX == 0 {
                    return
                }
                
                var x1 = self.initialDeltaX + self.deltaX
                var x2 = self.initialDeltaX + self.deltaX + progressBarStripePad
                var x3 = self.initialDeltaX + self.deltaX + progressBarStripeWidth
                var x4 = self.initialDeltaX + self.deltaX + progressBarStripePad + progressBarStripeWidth
                
                //chek "out of bounds"
                if x1 > maxX {
                    return
                }
                
                //adjust right bound
                if x2 > maxX {
                    x2Ypad = progressBarHeight - x2 + maxX
                    x2 = maxX
                }
                
                if x3 < maxX && x4 > maxX {
                    shouldCalculateX4 = true
                }
                
                x3 = min(x3, maxX)
                
                if x4 > maxX {
                    if shouldCalculateX4 {
                        x4Ypad = progressBarHeight - x4 + maxX
                    }
                    
                    x4 = maxX
                }
                
                //adjust left bound
                if x1 < 0 {
                    x1Ypad = -x1
                    x1 = 0
                }
                
                x2 = max(x2, 0)
                
                if x3 < 0 {
                    x3Ypad = -x3
                    x3 = 0
                }
                
                x4 = max(x4, 0)
                
                //draw stripe
                
                
                /*
                 progressBarStripeWidth
                        |
                X1 _____|___ X3
                   \        \
                    \        \
                   X2\________\ X4
                     |
                  |..| <-  progressBarStripePad
                 
                 */
                
                //X1
                path.move(
                    to: CGPoint(x: x1, y: 0)
                )
                
                //X1
                path.addLine(
                    to: CGPoint(x: x1, y: 0)
                )
                
                //X3
                path.addLine(
                    to: CGPoint( x: x3, y: x3Ypad)
                )
                
                //add right cutted edge point if needed
                if x4Ypad > 0 {
                    path.addLine(
                        to: CGPoint(x: maxX, y: x4Ypad)
                    )
                }
                
                //X4
                path.addLine(
                    to: CGPoint(x: x4, y: progressBarHeight)
                )
                
                //X2
                path.addLine(
                    to: CGPoint(x: x2, y: progressBarHeight)
                )
                
                //add left cutted edge point if needed
                if x2Ypad > 0 {
                    path.addLine(
                        to: CGPoint(x: maxX, y: x2Ypad)
                    )
                }
                
                //X1
                path.addLine(
                    to: CGPoint(x: x1, y: x1Ypad)
                )
            }
            .foregroundColor(Color.gray)
                .opacity(0.5)
                .onReceive(self.timer) {
                    //timer runloop
                    let thisTime = CACurrentMediaTime().truncatingRemainder(dividingBy: 1)
                    self.deltaX = Int(thisTime * Double(2 * progressBarStripeWidth)) - 2 * progressBarStripeWidth
            }
    }
}

struct Bar: View {
    
    @Binding<Length> var value: Length
    var totalWidth: CGFloat
    
    var body: some View {
        Path { path in
            
            let width = Int(self.value * totalWidth)
            
            path.move(
                to: CGPoint(x: 0, y: 0)
            )
            
            path.addLine(
                to: .init(x: width, y: 0)
            )
            
            path.addLine(
                to: .init(x: width, y: progressBarHeight)
            )
            
            path.addLine(
                to: .init(x: 0, y: progressBarHeight)
            )
            
            path.addLine(
                to: .init(x: 0, y: 0)
            )
        }
        .foregroundColor(Color.init(.displayP3, red: 92.0 / 255.0, green: 183.0 / 255.0, blue: 92.0 / 255.0, opacity: 1))
    }
    
}

struct ProgressBar : View {
    @Binding<Length> var value: Length
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: Alignment.leading) {
                //gray scale
                Rectangle()
                    .foregroundColor(Color.init(.displayP3, red: 222.0 / 255.0, green: 222.0 / 255.0, blue: 222.0 / 255.0, opacity: 1))
                
                //green scale
                Bar(value: self.$value, totalWidth: geometry.size.width)
                
                //stripes
                ForEach(0..<Int(geometry.size.width / CGFloat(2 * progressBarStripeWidth))) { index in
                    Stripe(value: self.$value, initialDeltaX: index * 2 * progressBarStripeWidth, maxWidth: geometry.size.width)
                }
            }
        }
    }
}

struct ContentView : View {
    
    @State var value: Length = 0.0
    
    var body: some View {
        
        VStack {
            Spacer()
            
            ProgressBar(value: $value).frame(height: CGFloat(progressBarHeight)).padding()
           
            Spacer()
            
            Slider(value: $value).padding()
            
            Spacer()
        }
    }
}
