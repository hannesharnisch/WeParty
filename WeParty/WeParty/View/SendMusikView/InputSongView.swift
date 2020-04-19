//
//  InputSongView.swift
//  PartyCollaborate
//
//  Created by Hannes Harnisch on 06.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct InputSongView: View {
    var connectivity:WePartyModel?
    @Binding var shown:Bool
    @State var musicTitle = ""
    @State var interpret = ""
    var body: some View {
        VStack{
            Image(systemName: "minus").resizable().foregroundColor(Color(UIColor.lightGray)).frame(width:40,height:6).padding(.horizontal, 5).onTapGesture {
                self.shown = false
            }
            Text("Send a Song!").font(.largeTitle).padding()
            Spacer()
            Text("Title")
            .font(.headline)
            TextField("", text: $musicTitle).padding(.all)
                .background(Color.gray).cornerRadius(5.0)
            Text("Interpret")
            .font(.headline)
            TextField("", text: $interpret).padding(.all)
                .background(Color.gray).cornerRadius(5.0)
            Spacer()
            Button(action:{
                self.connectivity?.didInput(songs: [Song(title: self.musicTitle, interpret: self.interpret)])
            }){
                Text("Send").font(.headline).foregroundColor(.white)
            }.padding(.vertical, 10.0).background(Color.blue).cornerRadius(4.0).padding(.horizontal, 50)
            Spacer()
        }.padding()
    }
}

