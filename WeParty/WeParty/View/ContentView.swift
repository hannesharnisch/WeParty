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
        ZStack{
                TabView(selection: $selectedView){
                    ConnectionView(model: model?.connection).tabItem {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text(NSLocalizedString("connect", comment:"connect word"))
                    }.tag(0).navigationViewStyle(StackNavigationViewStyle())
                    if self.state.connectedPeers.count != 0 || self.state.isServer{
                        SendingView(connectivity: self.model, selectMusik: self.$state.showMusicPicker).tabItem {
                            Image(systemName: "music.house")
                            Text(NSLocalizedString("music", comment:"music word")).onAppear {
                                if !self.state.isServer {
                                    self.selectedView = 1
                                }
                            }
                        }.tag(1).navigationViewStyle(StackNavigationViewStyle())
                    }
                    Settings().tabItem {
                        Image(systemName: "gear")
                        Text("Settings").onAppear {
                            if !self.state.isServer {
                                self.selectedView = 1
                            }
                        }
                    }.tag(2).navigationViewStyle(StackNavigationViewStyle())
                }.onAppear {
                    self.model = WePartyModel(state:self.state)
                }
            if isloadingScreenShown{
                LoadingScreen(isLoadingScreenShown: $isloadingScreenShown).onDisappear {
                        AppSettings.current.requestMusicCapabilities(){ result in
                            if !result{
                                AppSettings.current.requestMediaLibraryAccess { (success) in
                                    print("Success Connect: \(success)")
                                }
                            }
                        }
                }
            }
        }.alert(isPresented: $state.showAlertView) {
            Alert(title: Text("Joining Request"), message: Text("\(self.state.discoveredPeers[0].displayName) wants to join the Party"), primaryButton: .default(Text(NSLocalizedString("connect", comment:"connect word"))) {
                self.model?.connection.connection(accept: true, peer: self.state.discoveredPeers[0])
                }, secondaryButton: .cancel(){
                    self.model?.connection.connection(accept: false, peer: self.state.discoveredPeers[0])
                })
        }
    }
}
