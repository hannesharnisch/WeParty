//
//  RecievedSongsView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 27.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct RecievedSongsView: View {
    @Binding var recievedSongs:[RecievedSong]
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                ZStack{
                if self.recievedSongs.count == 0{
                    Text("No Recieved Songs Currently").font(.largeTitle).foregroundColor(.gray).multilineTextAlignment(.center)
                }else{
                    VStack{
                        Spacer()
                    HStack{
                        Button(action:{
                            self.recievedSongs.last!.decline()
                            self.selectionFeedbackGenerator.selectionChanged()
                        }){
                            Image(systemName: "xmark").resizable().frame(width:geometry.size.width*0.05,height:geometry.size.width*0.05).foregroundColor(.red)
                        }
                        Spacer()
                        Button(action:{
                            self.selectionFeedbackGenerator.selectionChanged()
                            self.recievedSongs.last!.accept()
                        }){
                            Image(systemName: "checkmark").resizable().frame(width:geometry.size.width*0.05,height:geometry.size.width*0.05).foregroundColor(.green)
                        }
                    }.padding()
                    }
                }
                ForEach(self.recievedSongs,id: \.id){ song in
                    RecievedSongSheet(receivedSong: song,index: self.recievedSongs.lastIndex(where: { (recsong) -> Bool in
                        return recsong.id == song.id
                    })!,oftotal:self.recievedSongs.count,onDelete: { index in
                        self.selectionFeedbackGenerator.selectionChanged()
                        withAnimation {
                            self.recievedSongs[index].decline()
                        }
                    },onAccept: { index in
                        self.selectionFeedbackGenerator.selectionChanged()
                        withAnimation {
                            self.recievedSongs[index].accept()
                        }
                    }).frame(width: geometry.size.width - 80, height: geometry.size.height - 140).padding(.bottom)
                }
            }
            }
            .navigationBarTitle(Text("Recieved Songs"))
        }
    }
}
struct RecievedSongsView_Previews: PreviewProvider {
    static var previews: some View {
        RecievedSongsView(recievedSongs: .constant([RecievedSong(song: Song(title: "Hello", interpret: "May"), sender:  "Hannes"),RecievedSong(song: Song(title: "Hello", interpret: "May"), sender: "Hannes"),RecievedSong(song: Song(title: "Hello", interpret: "May"), sender:  "Hannes"),RecievedSong(song: Song(title: "Hello", interpret: "May"), sender: "Hannes")]))
    }
}
