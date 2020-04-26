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
    var connectivity:WePartyModel?
    var body: some View {
        VStack(alignment: .leading){
            if self.state.queue.count != 0{
                Text("\(NSLocalizedString("nextSongs", comment:"next Songs label")):").font(.caption).padding()
                //Divider()
            }
            TableView(deleteOption: self.$state.isServer, deleted: { song in
                    print("DELETING \(song.title)")
                    self.connectivity?.removeFromQueue(song: song)
            }, moved: { source, destination in
                
            }, list: self.$state.queue) { song in
                HStack{
                    SongImageView(percentage: self.$percentage, songImage: song.getImage())
                    VStack(alignment: .leading){
                        Text(song.title)
                        Text(song.interpret)
                    }
                }.padding(2)
            }.frame(width:UIScreen.main.bounds.width)
            Spacer(minLength: 80)
            }
        }
}

