//
//  ExplainationView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 26.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct ExplainationView: View {
    let songs = [Song(title: "Hello", interpret: "Hannes"),Song(title: "Shake it off", interpret: "Taylor Swift")]
    @State var percentage:CGFloat = 0.0
    var body: some View {
        VStack{
            Image( "170622kategorie-party-und-events-header_mini").resizable().scaledToFill().frame(width:UIScreen.main.bounds.width).edgesIgnoringSafeArea([.top,.bottom])
            VStack{
                NavigationView{
                    ZStack{
                        List{
                            ForEach(songs,id:\.id){ song in
                            HStack{
                                SongImageView(percentage: self.$percentage, songImage: song.getImage())
                                VStack(alignment: .leading){
                                    Text(song.title)
                                    Text(song.interpret)
                                }
                            }.padding(2)
                            }
                        }.onAppear {
                            UITableView.appearance().separatorStyle = .none
                        }.onDisappear {
                            UITableView.appearance().separatorStyle = .singleLine
                        }
                        //NowPlayingInfoView(showMusikPlaying: .constant(0.0), controller:WePartyModel(state: WePartyState()), nowPlaying: .constant(nil), current: .constant(30), total: .constant(300), enabled: .constant(false), playing: .constant(false))
                    }
                    .navigationBarTitle("My Music")
                        .navigationBarItems(leading: EditButton().disabled(true), trailing: Button(action:{
                            
                        }){
                           Image(systemName: "rectangle.stack.fill.badge.plus")
                        })
                }.environment(\.colorScheme, .light)
                }.frame(width: 250, height: 400).background(BackgroundRectView()).offset(y:-300)
                .padding(.bottom, -300)
            VStack{
                Text("Starting a Party Playlist is as easy as opening this app, selecting if you want to be the party host or if you want to join the party and your good to go!").foregroundColor(.black).padding().multilineTextAlignment(.center)
                Text("Now you only need to select Music").foregroundColor(.black).padding()
            }
        }
    }
}
struct BackgroundRectView:View{
    var body: some View {
        ZStack{
            Rectangle().cornerRadius(20).foregroundColor(.white).shadow(color: .gray, radius: 4, x: 0, y: -4)
        }
    }
}
struct ExplainationView_Previews: PreviewProvider {
    static var previews: some View {
        ExplainationView()
    }
}
