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
        GeometryReader{ geometry in
        ZStack(alignment: .bottom){
            NavigationView{
                VStack{
                    if self.state.queue.count == 0 && self.state.isServer{
                    Button(action: {
                        self.selectMusik = true
                    }){
                        Text(NSLocalizedString("selectMusic", comment:"select Music button")).padding()
                    }
                }
                    QueueView(connectivity:self.connectivity).sheet(isPresented: self.$selectMusik, onDismiss: {
                    DispatchQueue.main.async {
                        self.state.closedMusicPicker()
                    }
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
                }.navigationBarTitle(Text("\((String(self.state.currentHost?.displayName.split(separator: "-")[0] ?? Substring(NSLocalizedString("my", comment:"My word"))))) \(NSLocalizedString("music", comment:"music word"))")).navigationBarItems(leading: self.state.isServer ? EditButton() : nil,trailing:
                    Button(action: {
                        self.selectMusik.toggle()
                    }) {
                        Image(systemName: "rectangle.stack.fill.badge.plus").resizable().frame(width: 30, height: 30, alignment: .trailing)
                    }.disabled(self.state.queue.count == 0 && !self.state.isServer)
                )
                    .environment(\.editMode, self.$editMode)
            }
            
            NowPlayingInfoView(showMusikPlaying: self.$showMusikPlaying , controller: self.connectivity, nowPlaying: self.$state.nowPlaying,current: self.$state.currentPosition,total: self.$state.endPostition, enabled: self.$state.isServer, playing: self.$state.playing).frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        }
        }
    }
}


