//
//  LoadingScreen.swift
//  PartyCollaborate
//
//  Created by Hannes Harnisch on 04.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//
import SwiftUI

struct LoadingScreen: View {
    @Binding var isLoadingScreenShown:Bool
    @State var animate = false
    @State var opacity = 0.0
    var repeatingAnimation: Animation {
        Animation
            .linear(duration: 1)
            .repeatForever()
    }
    var body: some View {
        VStack(alignment: .center){
            Spacer()
            Path{ path in
                let screen = UIScreen.main.bounds
                let center = CGPoint(x: screen.width/2, y: screen.height/2 - 35)
                let width = screen.width > 540 ? 500 : screen.width - 40
                let height = width
                path.move(to: CGPoint(x: center.x, y: center.y - height/2));
                path.addLine(to: CGPoint(x: center.x, y: center.y + height/2));
                path.move(to: CGPoint(x: center.x - width/2, y: center.y));
                path.addLine(to: CGPoint(x: center.x + width/2, y: center.y))
                
            }.stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round)).foregroundColor(.white).cornerRadius(2).rotationEffect(.degrees(animate ? 720 : 0)).opacity(animate ? 0.0 : 1.0).animation(.easeInOut(duration: 1.4))
            Spacer()
            Text(NSLocalizedString("touchToStart", comment:"Touch to start description")).foregroundColor(.blue).opacity(animate ? 0.0 :self.opacity).onAppear(){withAnimation(self.repeatingAnimation){self.opacity = 1.0}}.padding()
            Spacer()
        }.background(Image( "170622kategorie-party-und-events-header_mini").resizable().scaledToFill().opacity(animate ? 0.0 : 1.0).animation(.easeInOut(duration: 1.6))).edgesIgnoringSafeArea([.top,.bottom]).onTapGesture {
                self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isLoadingScreenShown = false
            }
            
        }
    }
}
