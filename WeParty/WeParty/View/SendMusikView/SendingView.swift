//
//  SendingView.swift
//  PartyCollaborate2
//
//  Created by Hannes Harnisch on 25.03.20.
//  Copyright © 2020 Hannes Harnisch. All rights reserved.
//

import SwiftUI

struct SendingView: View {
    var connectivity:WePartyModel?
    @EnvironmentObject var state:WePartyState
    @Binding var selectMusik:Bool
    @State var showMusikPlaying:CGFloat = 0
    var body: some View {
        ZStack{
            NavigationView{
                ScrollView(.vertical){
                    if self.state.queue.count == 0 && self.state.isServer{
                    Button(action: {
                        self.selectMusik = true
                    }){
                        Text("Select Music").padding()
                    }
                }
                QueueView().padding().frame(width:UIScreen.main.bounds.width).sheet(isPresented: self.$selectMusik, onDismiss: {
    
                }) {
                    VStack{
                        if AppSettings.current.hasMusicInLib {
                            SelectMusikView(connectivity: self.connectivity, shown:self.$selectMusik)
                        }else{
                            if AppSettings.current.hasInternetConnection{
                                SearchForSongView(connectivity: self.connectivity, shown: self.$selectMusik)
                            }else{
                                InputSongView(connectivity: self.connectivity, shown: self.$selectMusik)
                            }
                        }
                    }
                }
                }.navigationBarTitle(Text("\(self.state.currentHost?.displayName ?? "My") Music")).navigationBarItems(trailing:
                    Button(action: {
                        self.selectMusik.toggle()
                    }) {
                        Image(systemName: "rectangle.stack.fill.badge.plus").resizable().frame(width: 30, height: 30, alignment: .trailing)
                    }.disabled(self.state.queue.count == 0 && !self.state.isServer)
                )
            }
            NowPlayingInfoView(showMusikPlaying: self.$showMusikPlaying , controller: self.connectivity, nowPlaying: $state.nowPlaying, enabled: $state.isServer, playing: $state.playing)
        }
    }
}


