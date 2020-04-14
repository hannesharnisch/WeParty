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

class Song:Codable,Equatable{
    var id = UUID()
    var title:String
    var interpret:String
    var appleMusicSongID:String?
    var spotifyURL:URL?
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
        self.interpret = song.albumArtist ?? ""
        self.appleMusicSongID = String(song.persistentID)
        self.image = song.artwork?.image(at: CGSize(width: 150, height: 150))?.pngData()
        if title == ""{
            print("NO TITLE")
            return nil
        }
        print(self.appleMusicSongID)
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
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.title == rhs.title && lhs.interpret == rhs.interpret
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
