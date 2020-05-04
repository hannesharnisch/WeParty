//
//  SearchForSongView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 18.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI
import MediaPlayer

struct SearchForSongView<T:SearchForSongsDelegate>: View {
    var connectivity:T?
    @Binding var shown:Bool
    @State private var searchText : String = ""
    @State private var searchResults:[Song] = []
    @State var selectKeeper = Set<Song>()
    @State var percentage:CGFloat = 0.0
    
    init(connectivity:T?,shown:Binding<Bool>){
        self._shown = shown
        self.connectivity = connectivity
    }
    var body: some View {
        VStack(alignment:.center){
            HStack{
                Button(action:{
                    self.shown = false
                    self.searchText = ""
                    self.searchResults = []
                }){
                    Text("Cancel")
                }.padding()
                Spacer()
                Image(systemName: "minus").resizable().foregroundColor(Color(UIColor.lightGray)).frame(width:40,height:6).padding(.horizontal, 5).onTapGesture {
                    self.shown = false
                }
                Spacer()
                Button(action: {
                    self.shown = false
                    self.searchText = ""
                    self.searchResults = []
                    var items:[Song] = []
                    for item in self.selectKeeper{
                        items.append(item)
                    }
                    self.connectivity?.didInput(songs: items)
                }){
                    Text("Done")
                }.padding()
            }
            SearchBar(text: $searchText, textDidChange: { text in
                self.connectivity?.searchForSongs(with: text){ songs in
                    var items:[Song] = []
                    for item in self.selectKeeper{
                        items.append(item)
                    }
                    self.searchResults = items
                    self.searchResults.append(contentsOf: songs ?? [])
                }
            })
            if searchResults.count == 0{
                Spacer()
                Text("Search for a Song in Apple Music").font(.largeTitle).multilineTextAlignment(.center).padding().foregroundColor(.gray)
            }
            List(self.searchResults,id: \.self, selection: $selectKeeper){ song in
                HStack{
                    SongImageView(percentage: self.$percentage, songImage: song.getImage())
                    VStack(alignment: .leading){
                        Text(song.title)
                        Text(song.interpret)
                    }
                }
            }.environment(\.editMode, .constant(EditMode.active))
            Spacer()
        }
    }
}
protocol SearchForSongsDelegate {
    func searchForSongs(with name:String,callback:@escaping ([Song]?) -> Void)
    func didInput(songs:[Song])
}
