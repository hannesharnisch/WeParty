//
//  Song.swift
//  WeParty
//
//  Created by Hannes Harnisch on 13.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import Foundation
import SwiftUI
import MediaPlayer
import MultipeerConnectivity

class Song:Codable,Identifiable{
    var id = UUID()
    var sender:String?
    var title:String
    var interpret:String
    var appleMusicSongID:String?
    var length:CGFloat?
    var image:Data?
    var imageURL:URL?
    
    func getImage() ->UIImage?{
        if image != nil{
            return UIImage(data: image!, scale: 1.0)
        }else{
            return nil
        }
    }
    init?(song:MPMediaItem){
        self.title = song.title ?? ""
        self.interpret = song.artist ?? ""
        self.appleMusicSongID = song.playbackStoreID
        self.image = song.artwork?.image(at: CGSize(width: 150, height: 150))?.pngData()
        self.length = CGFloat(song.playbackDuration)
        if title == ""{
            print("NO TITLE")
            return nil
        }
    }
    init(title:String,interpret:String,id:String,image:URL){
        self.title = title
        self.interpret = interpret
        self.appleMusicSongID = id
        self.imageURL = image
        ImageLoader.load(url: self.imageURL!) { (data) in
            print("Image Loaded")
            print(self)
            self.image = data
        }
    }
    init(title:String,interpret:String){
        self.title = title
        self.interpret = interpret
    }
}

class ImageLoader{
    static func load(url:URL,callback:@escaping (Data?)->Void){
        print("LOADING IMAGE")
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else{
                callback(nil)
                return
            }
            guard data != nil else{
                callback(nil)
                return
            }
            callback(data!)
        }.resume()
    }
}
extension Song:Hashable,Equatable{
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.title == rhs.title && lhs.interpret == rhs.interpret && (rhs.appleMusicSongID ?? "1") == (lhs.appleMusicSongID ?? "0")
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(interpret)
        hasher.combine(id)
        hasher.combine(appleMusicSongID)
    }

}

class RecievedSong: Song{
    var status:RecievedSongStatus
    var acceptFunc:((Song)->Void)!
    var declineFunc:((Song)->Void)!
    init(song:Song,sender:String){
        self.status = .recieved
        super.init(title: song.title, interpret: song.interpret)
        self.sender = sender
        self.appleMusicSongID = song.appleMusicSongID
        self.image = song.image
        self.imageURL = song.imageURL
        self.length = song.length
        
    }
    func accept(){
        DispatchQueue.main.async {
            self.acceptFunc(self)
        }
    }
    func decline(){
        DispatchQueue.main.async {
            self.declineFunc(self)
        }
    }
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
enum RecievedSongStatus{
    case recieved, accepted, declined, removed
}
