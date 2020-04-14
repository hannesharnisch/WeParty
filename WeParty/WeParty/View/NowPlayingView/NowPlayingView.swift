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
                })
            }, largeContent: {
                MusicControlLarge(playing: self.$playing, nowPlaying: $nowPlaying, enabled: $enabled, onPlayPause: { (play) in
                   if play{
                    self.controller?.toggleAction(action: .play)
                    }else{
                    self.controller?.toggleAction(action: .pause)
                    }
                }, onForward: {
                    self.controller?.toggleAction(action: .next)
                }) {
                    self.controller?.toggleAction(action: .previous)
                }
            }) {
                SongImageView(percentage: $showMusikPlaying, songImage: self.nowPlaying?.getImage())
            }
        }
        }
    }
}
protocol MusicPlayerActionEnabled {
    func toggleAction(action:MusicPlayerAction)
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
