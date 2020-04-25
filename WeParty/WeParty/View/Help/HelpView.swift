//
//  HelpView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 23.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity

struct HelpView: View {
    var model = WePartyModel(state: WePartyState())
    @State var selected = 0
    var body: some View {
            ZStack{
                if selected == 0{
                    AskingView(wasIsServerSet: .constant(false), isServer: .constant(false), onSelected: {
                    
                    }).padding(.vertical,30)
                }else if selected == 1{
                    ConnectingView(discoveredPeers: .constant([MCPeerID(displayName: "Max Mustermann"),MCPeerID(displayName: "Hallo Hammer")]), connectedPeers: .constant([MCPeerID(displayName: "Iphone from Max")]), isServer: .constant(false), currentHost: .constant(MCPeerID(displayName: "Iphone from Muster")) ,connectivity: model.connection)
                }else{
                    SendingView(connectivity: self.model, selectMusik: .constant(false)).padding(.vertical,30)
                }
                Blur().opacity(0.5).edgesIgnoringSafeArea([.top,.bottom])
                VStack{
                    if selected == 0{
                        AskingViewHelp()
                    }else if selected == 1{
                        ConnectionViewHelp()
                    }
                    HStack{
                        if selected != 0{
                            Button(action:{
                                self.selected -= 1
                            }){
                                Text("previous").padding()
                            }
                        }
                            Spacer()
                            Button(action:{
                                self.selected += 1
                            }){
                                Text("Next").padding()
                            }
                    }
                }.padding(.vertical,30)
            }.edgesIgnoringSafeArea([.top,.bottom])
    }
}

struct AskingViewHelp: View {
    var body: some View {
        VStack{
            Text(" 1. First Select if you want to join or start a party").padding().multilineTextAlignment(.center)
            Spacer()
            Text("Start a party if you want to be the one who plays the music").font(.caption).padding().multilineTextAlignment(.center)
            Text("Join a party if you want to send music to someone who plays music with WeParty").font(.caption).multilineTextAlignment(.center).padding()
            Spacer()
            Spacer()
        }
    }
}
struct ConnectionViewHelp: View {
    var body: some View {
        VStack{
            Text(" 1. First Select if you want to join or start a party").padding().multilineTextAlignment(.center)
            Spacer()
            Text("Start a party if you want to be the one who plays the music").font(.caption).padding().multilineTextAlignment(.center)
            Text("Join a party if you want to send music to someone who plays music with WeParty").font(.caption).multilineTextAlignment(.center).padding()
            Spacer()
            Spacer()
        }
    }
}


struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
