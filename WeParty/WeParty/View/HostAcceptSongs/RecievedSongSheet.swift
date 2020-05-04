//
//  RecievedSongSheet.swift
//  WeParty
//
//  Created by Hannes Harnisch on 27.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct RecievedSongSheet: View {
    var recievedSong:RecievedSong
    var index:Int
    var oftotal:Int
    var onDelete:(Int)->Void
    var onAccept:(Int)->Void
    @State private var translation: CGSize = .zero
    private var thresholdPercentage: CGFloat = 0.5
    public init(receivedSong:RecievedSong,index:Int,oftotal:Int,onDelete:@escaping (Int)->Void,onAccept:@escaping (Int)->Void){
        self.recievedSong = receivedSong
        self.index = index
        self.oftotal = oftotal
        self.onAccept = onAccept
        self.onDelete = onDelete
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment:.center){
                VStack(alignment:.leading){
                if self.recievedSong.image != nil {
                    Image(uiImage: self.recievedSong.getImage()!).resizable().aspectRatio(contentMode: .fill).frame(width: geometry.size.width , height: geometry.size.height * 0.7).clipped()
                }else{
                    Image(systemName: "music.note").resizable().aspectRatio(contentMode: .fill).frame(width: geometry.size.width, height: geometry.size.height * 0.7).clipped()
                }
                Spacer()
                VStack(alignment: .leading) {
                        Text("\(self.recievedSong.title)")
                            .font(.headline).foregroundColor(.black)
                            .bold()
                        Text(self.recievedSong.interpret)
                            .font(.subheadline).foregroundColor(.black)
                                .bold()
                        Spacer()
                        Text("From: \(String(self.recievedSong.sender!.split(separator: "-")[0]))")
                            .font(.subheadline)
                                .foregroundColor(.gray)
                    }.padding([.horizontal,.bottom])
                }
                Color.green.opacity(Double((self.translation.width/400)))
                Color.red.opacity(Double((-self.translation.width/400)))
            }.frame(width: geometry.size.width - CGFloat((self.oftotal - 1 - self.index) * 10), height: geometry.size.height).cornerRadius(10).background(Color.white.cornerRadius(10)).shadow(radius: 10).offset(x: self.translation.width, y: ((CGFloat(self.oftotal - 1 - self.index) * 10)+(abs(self.translation.width)/15))).rotationEffect(.degrees(Double(self.translation.width/10))).gesture(
                    DragGesture()
                    .onChanged { value in
                        self.translation = value.translation
                    }.onEnded { value in
                        if abs(self.getGesturePercentage(geometry, from: value)) > self.thresholdPercentage {
                            if value.translation.width > 0{
                                self.onAccept(self.index)
                            }else{
                                self.onDelete(self.index)
                            }
                            print("remove")
                        } else {
                            self.translation = .zero
                        }
                    }
            ).onAppear {
                print(self.oftotal)
                print(self.index)
            }
        }
    }
    private func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
}
