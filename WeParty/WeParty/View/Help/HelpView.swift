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
    @State var selected:Int
    var model = WePartyModel(state: WePartyState())
    var body: some View {
            ZStack{
                if selected == 0{
                    AskingView(wasIsServerSet: .constant(false), isServer: .constant(false), onSelected: {
                    
                    }).padding(.vertical,30)
                }else if selected == 1{
                    ConnectingView(discoveredPeers: .constant([MCPeerID(displayName: "Max Mustermann"),MCPeerID(displayName: "Hallo Hammer")]), connectedPeers: .constant([MCPeerID(displayName: "Iphone from Max")]), isServer: .constant(false), currentHost: .constant(MCPeerID(displayName: "Iphone from Muster")) ,connectivity: model.connection).padding(.vertical,30)
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
                    Spacer()
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


struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(selected:0)
    }
}
