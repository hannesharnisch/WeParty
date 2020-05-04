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
    @State var showHelp = false
    var onSelected:() -> ()
    var body: some View {
        VStack{
            Spacer()
            Text(NSLocalizedString("startingorJoiningParyQuestion", comment:"party start or join Question")).multilineTextAlignment(.center).font(.headline)
            Spacer()
            HStack{
            Spacer()
                VStack(alignment:.center){
            Button(action: {
                self.isServer = true
                self.wasIsServerSet.toggle()
                self.onSelected()
            }){
                Text(NSLocalizedString("startParty", comment:"party start")).foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width/2 - 40, height: 80, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 10).fill().foregroundColor(.blue))
            }
                }
            .compositingGroup()
            .shadow(color: .black, radius: 3)
            Spacer()
            Button(action: {
                self.isServer = false
                self.wasIsServerSet.toggle()
                self.onSelected()
            }){
                Text(NSLocalizedString("joinParty", comment:"party join")).foregroundColor(.white)
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
