//
//  ConnectionView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 13.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var state:WePartyState
    var model:WePartyConnection?
    @State var wasIsServerSet = false
    var body: some View {
        NavigationView{
            VStack{
                if !wasIsServerSet{
                    AskingView(wasIsServerSet: $wasIsServerSet, isServer: self.$state.isServer, onSelected: {
                        self.model?.start(isServer: self.state.isServer)
                    })
                }else{
                    ConnectingView(discoveredPeers: self.$state.discoveredPeers, connectedPeers: self.$state.connectedPeers, isServer: self.$state.isServer, currentHost: self.$state.currentHost,connectivity: model)
                }
            }.navigationBarTitle(Text("\(NSLocalizedString("connection", comment:"connection word")) \(wasIsServerSet ? self.state.isServer ? NSLocalizedString("PartyHost", comment:"PartyHost word") : NSLocalizedString("join", comment:"join word") : "")"))
        }
    }
}

