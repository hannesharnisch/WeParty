//
//  AskingView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 14.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct AskingView: View{
    @Binding var wasIsServerSet:Bool
    @Binding var isServer:Bool
    var onSelected:() -> ()
    var body: some View {
        VStack{
            Spacer()
            Text("Do you want to start or join a Party?").multilineTextAlignment(.center).font(.headline)
            Spacer()
            HStack{
            Spacer()
            Button(action: {
                self.isServer = true
                self.wasIsServerSet.toggle()
                self.onSelected()
            }){
                Text("Start a Party").foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width/2 - 40, height: 80, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 10).fill().foregroundColor(.blue))
            }
            .compositingGroup()
            .shadow(color: .black, radius: 3)
            Spacer()
            Button(action: {
                self.isServer = false
                self.wasIsServerSet.toggle()
                self.onSelected()
            }){
                Text("Join a Party").foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width/2 - 40, height: 80, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 10).fill().foregroundColor(.blue))
            }
            .compositingGroup()
            .shadow(color: .black, radius: 3)
            Spacer()
            }
            Spacer()
        }.padding()
    }
}
