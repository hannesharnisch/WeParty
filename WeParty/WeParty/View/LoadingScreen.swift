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
                let ytranslation:CGFloat = UIScreen.main.bounds.height/2 - (width/2+15);
                let xtranslation:CGFloat = 25
                path.move(to: CGPoint(x: xtranslation, y: height/2+ytranslation));
                path.addLine(to: CGPoint(x: width+xtranslation, y: height/2+ytranslation));
                path.move(to: CGPoint(x: width/2+xtranslation, y: ytranslation));
                path.addLine(to: CGPoint(x: width/2+xtranslation, y: height+ytranslation))
                
            }.stroke(lineWidth: 30).foregroundColor(.white).rotationEffect(.degrees(animate ? 360 : 0)).opacity(animate ? 0.2 : 1.0).animation(.easeInOut(duration: 1.0))
            Spacer()
            Text("Touch to Start!").foregroundColor(.blue).opacity(self.opacity).onAppear(){withAnimation(self.repeatingAnimation){self.opacity = 1.0}}
            Spacer()
        }.background(Image( "170622kategorie-party-und-events-header_mini").resizable().scaledToFill().opacity(animate ? 0.0 : 1.0).animation(.easeInOut(duration: 1.0))).edgesIgnoringSafeArea([.top,.bottom]).onTapGesture {
            if self.animate{
                self.animate = false
            }else{
                self.animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isLoadingScreenShown = false
            }
            
        }
    }
}
