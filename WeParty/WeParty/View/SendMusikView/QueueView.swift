//
//  QueueView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 13.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct QueueView: View {
    @EnvironmentObject var state:WePartyState
    @State var percentage:CGFloat = 0.0
    var body: some View {
        VStack(alignment: .leading){
            Text("Next Songs:").font(.caption).padding()
            Divider()
                ForEach(self.state.queue,id: \.id){ song in
                    VStack(alignment: .leading){
                    HStack{
                        SongImageView(percentage: self.$percentage, songImage: song.getImage())
                        VStack(alignment: .leading){
                            Text(song.title)
                            Text(song.interpret)
                        }
                    }
                    Divider()
                    }
                }
            Spacer(minLength: 80)
            }
        }
    }

