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
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        ZStack{
            NavigationView{
                VStack{
                    if self.state.queue.count == 0 && self.state.isServer{
                    Button(action: {
                        self.selectMusik = true
                    }){
                        Text(NSLocalizedString("selectMusic", comment:"select Music button")).padding()
                    }
                }
                QueueView(connectivity:connectivity).sheet(isPresented: self.$selectMusik, onDismiss: {
    
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
                }.navigationBarTitle(Text("\(self.state.currentHost?.displayName ?? NSLocalizedString("my", comment:"My word")) \(NSLocalizedString("music", comment:"music word"))")).navigationBarItems(leading: self.state.isServer ? EditButton() : nil,trailing:
                    Button(action: {
                        self.selectMusik.toggle()
                    }) {
                        Image(systemName: "rectangle.stack.fill.badge.plus").resizable().frame(width: 30, height: 30, alignment: .trailing)
                    }.disabled(self.state.queue.count == 0 && !self.state.isServer)
                )
                .environment(\.editMode, $editMode)
            }
            NowPlayingInfoView(showMusikPlaying: self.$showMusikPlaying , controller: self.connectivity, nowPlaying: $state.nowPlaying,current: $state.currentPosition,total: $state.endPostition, enabled: $state.isServer, playing: $state.playing)
        }
    }
}


