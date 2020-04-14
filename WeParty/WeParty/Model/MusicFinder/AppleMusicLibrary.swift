//
//  AppleMusicLibrary.swift
//  PartyCollaborate
//
//  Created by Hannes Harnisch on 06.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import Foundation
import StoreKit
import MediaPlayer

class AppleMusicLibrary{
    let developerToken:String
    var userToken:String?
    var controller:SKCloudServiceController!
    let urls:AppleMusicURLs!
    init(token:String){
        self.developerToken = token
        self.controller = SKCloudServiceController()
        self.urls = AppleMusicURLs(controller: controller)
        controller.requestUserToken(forDeveloperToken: developerToken) { (token, error) in
            print(error)
            guard error == nil && token != nil else{
                return
            }
            self.userToken = token
        }
    }
    func resolveRequestResult(data:Data)->Song?{
        print(String(data:data,encoding:.utf8))
        
        do{
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String:[String:AnyObject]]] else{
                return nil
            }
            guard let dataParts = (json["results"]!["songs"]!["data"]! as? [AnyObject])![0] as? [String:AnyObject] else{
                print("ERR")
                return nil
            }
            print(dataParts)
            guard let id = dataParts["id"] as? String else{
                print("COULDNT resolve data")
                return nil
            }
            //let artist = dataParts["artistName"] as? String
            guard let attrs = dataParts["attributes"] as? [String:AnyObject] else{
                print("COULDNT resolve attrs")
                return nil
            }
            guard let name = attrs["name"] as? String, let artist = attrs["artistName"] as? String else{
                print("EEERRR")
                return nil
            }
            print(id)
            print(name)
            print(artist)
            guard let artwork = attrs["artwork"] as? [String:AnyObject] else{
                print("EEERRR")
                return nil
            }
            guard var url = artwork["url"] as? String else{
                print("Couldnt resolve URL")
                return nil
            }
            url = url.replacingOccurrences(of: "{w}", with: "200")
            url = url.replacingOccurrences(of: "{h}", with: "200")
            print(url)
            return Song(title: name, interpret: artist, id: id, image: URL(string: url)!)
        }catch(let e){
            print(e)
            return nil
        }
    }
    func makeGETRequest(url:URL,callback:@escaping (Result<Song,MusicFinderError>) -> Void){
        let session = URLSession.shared
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        if self.userToken != nil{
            urlRequest.setValue(userToken, forHTTPHeaderField: "Music-User-Token")
            print("USER TOKEN ENAbled")
        }
        _ = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            print("RESPONSE")
            guard error == nil else{
                callback(.failure(.noFound))
                return
            }
            guard data != nil else{
                print("ERROR")
                return
            }
            guard let song = self.resolveRequestResult(data: data!) else{
                callback(.failure(.other))
                return
            }
            callback(.success(song))
            }).resume()
    }
    func getSongFrom(song:Song,callback:@escaping (Result<Song,MusicFinderError>) -> Void){
        let url = urls.buildSearchURL(term: "\(song.title)  \(song.interpret)", types: "songs")
        self.makeGETRequest(url: url){ result in
            callback(result)
        }
    }
}
class AppleMusicURLs{
    var searchURL = "https://api.music.apple.com/v1/catalog/<country>/search?term=<term>&limit=1&types=<types>"
    init(controller:SKCloudServiceController) {
        controller.requestStorefrontCountryCode { (code, error) in
            if error == nil{
                self.searchURL = self.searchURL.replacingOccurrences(of: "<country>", with: code!)
            }else{
                print("ERROR: \(error)")
            }
        }
    }
    func buildSearchURL(term:String,types:String) ->URL{
        let updatedTerm = term.replacingOccurrences(of: " ", with: "+")
        let url = searchURL.replacingOccurrences(of: "<term>", with: updatedTerm).replacingOccurrences(of: "<types>", with: types)
        return URL(string: url)!
    }
}
