//
//  ContentView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 13.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @State var isloadingScreenShown = true
    @State var selectedView = 0
    @EnvironmentObject var state:WePartyState
    @State var model:WePartyModel?
    @State var showMusikPlaying:CGFloat = 0
    var body: some View {
        VStack{
            if isloadingScreenShown{
                LoadingScreen(isLoadingScreenShown: $isloadingScreenShown)
            }else{
                TabView(selection: $selectedView){
                    ConnectionView(model: model?.connection).tabItem {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("Connect")
                    }.tag(0)
                    if self.state.connectedPeers.count != 0 || self.state.isServer{
                        SendingView(connectivity: self.model, selectMusik: self.$state.showMusicPicker).tabItem {
                            Image(systemName: "music.house")
                            Text("Music").onAppear {
                                if !self.state.isServer {
                                    self.selectedView = 1
                                }
                            }
                        }.tag(1)
                    }
                    Settings().tabItem {
                        Image(systemName: "gear")
                        Text("Settings").onAppear {
                            if !self.state.isServer {
                                self.selectedView = 1
                            }
                        }
                    }.tag(2)
                }.onAppear {
                    self.model = WePartyModel(state:self.state)
                    AppSettings.current.requestMusicCapabilities(){result in
                        
                    }
                }.alert(isPresented: $state.showAlertView) {
                    Alert(title: Text("Joining Request"), message: Text("\(self.state.discoveredPeers[0].displayName) wants to join the Party"), primaryButton: .default(Text("Connect")) {
                        self.model?.connection.connection(accept: true, peer: self.state.discoveredPeers[0])
                        }, secondaryButton: .cancel(){
                            self.model?.connection.connection(accept: false, peer: self.state.discoveredPeers[0])
                        })
                }
            }
        }
    }
}
