//
//  NowPlayingView.swift
//  PartyCollaborate2
//
//  Created by Hannes Harnisch on 27.03.20.
//  Copyright © 2020 Hannes Harnisch. All rights reserved.
//

import SwiftUI
import Foundation


struct NowPlayingInfoView<T:MusicPlayerActionEnabled>: View {
    @Binding var showMusikPlaying:CGFloat
    var controller:T?
    @Binding var nowPlaying:Song?
    @Binding var current:CGFloat
    @Binding var total:CGFloat
    @Binding var enabled:Bool
    @Binding var playing:Bool
    var body: some View {
        VStack{
        Spacer()
        ZStack{
            DraggableSmallRepresentationView(percentage: $showMusikPlaying, smallContent: {
                MusicControlSmall(playing: self.$playing, nowPlaying: $nowPlaying, enabled: $enabled, onPlayPause: { (play) in
                    if play{
                        self.controller?.toggleAction(action: .play)
                    }else{
                        self.controller?.toggleAction(action: .pause)
                    }
                }, onForward: {
                    self.controller?.toggleAction(action: .next)
                }).onDisappear {
                    self.controller?.changedStateTo(large: true)
                }
            }, largeContent: {
                VStack{
                MusicControlLarge(playing: self.$playing, nowPlaying: $nowPlaying,current: $current,total: $total, enabled: $enabled, onPlayPause: { (play) in
                   if play{
                    self.controller?.toggleAction(action: .play)
                    }else{
                    self.controller?.toggleAction(action: .pause)
                    }
                }, onForward: {
                    self.controller?.toggleAction(action: .next)
                }) {
                    self.controller?.toggleAction(action: .previous)
                }.onDisappear {
                    self.controller?.changedStateTo(large: false)
                }
                    if self.enabled{
                        MPVolumeViewRepresentable()
                    }
                    Spacer()
                }
            }) {
                VStack{
                    Spacer()
                    SongImageView(percentage: $showMusikPlaying, songImage: self.nowPlaying?.getImage())
                    Spacer()
                }
            }
        }
        }
    }
}
struct NowPlayingInfoView_Preview: PreviewProvider {
    static var previews: some View {
        TabView{
            ZStack{
                NavigationView{
                    Text("Hallo")
                    .navigationBarTitle(Text("TITLE"))
                }
                NowPlayingInfoView(showMusikPlaying: .constant(100),controller: WePartyModel(state: WePartyState()), nowPlaying: .constant(Song(title: "Halkld", interpret: "haldo")), current: .constant(5), total: .constant(40), enabled: .constant(true), playing: .constant(true))
            }
        }
    }
}
protocol MusicPlayerActionEnabled {
    func toggleAction(action:MusicPlayerAction)
    func changedStateTo(large:Bool)
}
enum MusicPlayerAction{
    case play
    case pause
    case next
    case previous
}

struct Blur: UIViewRepresentable {
    var effect: UIVisualEffect = UIBlurEffect(style: .systemThinMaterial)
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
