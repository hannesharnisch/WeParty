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
                let height = UIScreen.main.bounds.width - 50
                let width = height
                let ytranslation:CGFloat = UIScreen.main.bounds.height/2 - (width/2+35);
                let xtranslation:CGFloat = 25
                path.move(to: CGPoint(x: xtranslation, y: height/2+ytranslation));
                path.addLine(to: CGPoint(x: width+xtranslation, y: height/2+ytranslation));
                path.move(to: CGPoint(x: width/2+xtranslation, y: ytranslation));
                path.addLine(to: CGPoint(x: width/2+xtranslation, y: height+ytranslation))
                
            }.stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round)).foregroundColor(.white).cornerRadius(2).rotationEffect(.degrees(animate ? 720 : 0)).opacity(animate ? 0.0 : 1.0).animation(.easeIn(duration: 1.4))
            Spacer()
            Text(NSLocalizedString("touchToStart", comment:"Touch to start description")).foregroundColor(.blue).opacity(animate ? 0.0 :self.opacity).onAppear(){withAnimation(self.repeatingAnimation){self.opacity = 1.0}}.padding()
            Spacer()
        }.background(Image( "170622kategorie-party-und-events-header_mini").resizable().scaledToFill().opacity(animate ? 0.0 : 1.0).animation(.easeInOut(duration: 1.5))).edgesIgnoringSafeArea([.top,.bottom]).onTapGesture {
                self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.isLoadingScreenShown = false
            }
            
        }
    }
}
