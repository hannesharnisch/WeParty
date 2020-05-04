//
//  IntroductionView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 26.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct IntroductionView: View {
    var body: some View {
        VStack{
            Image( "170622kategorie-party-und-events-header_mini").resizable().scaledToFill().frame(width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height/3).edgesIgnoringSafeArea([.top,.bottom])
            VStack{
                SizedImage(name: "person.fill").padding(.vertical,50)
                HStack{
                    SizedImage(name: "person.fill").padding()
                    Spacer()
                    SizedImage(name: "music.note.list").padding()
                    Spacer()
                    SizedImage(name: "person.fill").padding()
                }.padding(.vertical,30)
                SizedImage(name: "person.fill").padding(.vertical,50)
            }.padding().background(BackgroundCircleView()).offset(y:-(UIScreen.main.bounds.width/3 * 2))
                .padding(.bottom, -(UIScreen.main.bounds.width/6 * 5))
            VStack{
                Text("Welcome to WeParty!").foregroundColor(.black).font(.title).padding().multilineTextAlignment(.center)
                /*Text("Did you ever had the problem at a party with the Music?").font(.headline).padding().multilineTextAlignment(.center)
                Text("WePary resolves all these problems!").padding().multilineTextAlignment(.center)*/
                Text("WeParty lets you create a Shared Playlist and lets you send songs to those around you!").foregroundColor(.black).font(.callout).multilineTextAlignment(.center)
                //Spacer()
            }
        }
    }
}
struct BackgroundCircleView:View{
    var body: some View {
        ZStack{
            Circle().foregroundColor(.white).padding()
            Circle().stroke(Color.gray,lineWidth: 1).padding(50)
            Rectangle().frame(width:50).foregroundColor(.white).padding(.vertical,80)
            Rectangle().frame(height:50).foregroundColor(.white).padding(.horizontal,40)
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
