//
//  WePartyModel.swift
//  WeParty
//
//  Created by Hannes Harnisch on 13.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import Foundation
import MediaPlayer
import MultipeerConnectivity
import StoreKit

class WePartyModel:NSObject, MPMediaPickerControllerDelegate, PartyCollaborateMCConnectionDelegate{
    private var state:WePartyState
    var connection:WePartyConnection
    var musicPlayer = MusicPlayer()
    private var musicFinder = MusicFinder(fileName: "AuthKey_QH8XRCS4JS.p8", kid: "QH8XRCS4JS", iss: "AVT8X3595T")
    private var firstTimePlaying = true
    private var songLoadingQueue = DispatchQueue(label: "Song Loading")
    
    init(state:WePartyState){
        self.state = state
        self.connection = WePartyConnection(state: state)
        //self.connection = PartyCollaborateMCConnection(state: state)
        super.init()
        self.connection.delegate = self
        self.musicPlayer.delegate = self
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
    didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        print("RECIEVED MEDIAITEM")
        DispatchQueue.main.async {
            self.state.showMusicPicker = false
            if self.firstTimePlaying{
                self.state.nowPlaying = Song(title: "Loading...", interpret: "")
            }
        }
        songLoadingQueue.async {
            var songs = [Song]()
            let items = mediaItemCollection.items
            for item in items{
                songs.append(Song(song: item)!)
            }
            if self.state.isServer{
                if self.firstTimePlaying{
                    self.musicPlayer.setSongs(queue: mediaItemCollection)
                    self.musicPlayer.play()
                    self.firstTimePlaying = false
                }else{
                    DispatchQueue.main.async {
                        self.musicPlayer.addSongsToQueue(songs: mediaItemCollection)
                        self.state.queue.insert(contentsOf: songs, at: 0)
                        self.connection.send(data: MCSongContent.queue(songs: self.state.queue).toData()!, to: .all)
                    }
                }
            }else{
                    _ = self.connection.send(data: MCSongContent.queue(songs: songs).toData()!, to: .host)
            }
        }
    }
    func didInput(song:Song){
        DispatchQueue.main.async {
            self.state.showMusicPicker = false
        }
        _ = self.connection.send(data: MCSongContent.queue(songs: [song]).toData()!, to: .host)
    }
    func songsRecieved(songs: [Song]) {
        for song in songs{
            if song.appleMusicSongID != nil{
                musicPlayer.addSongsToQueue(songs: [song])
            }else{
                musicFinder.findSong(song: song) { (result) in
                    switch result{
                    case .success(let song):
                        self.state.queue.insert(song, at: 0)
                        self.musicPlayer.addSongsToQueue(songs: [song])
                    case .failure(let err):
                        print(err)
                    }
                }
            }
        }
    }
    
}
extension WePartyModel:MusicPlayerActionEnabled, MusicPlayerDelegate{
    func nowPlayingChanged(nowPlaying: MPMediaItem?) {
        print("STARTED Conn?")
        print(connection.hasStarted)
        if nowPlaying != nil && connection.hasStarted{
                let song = Song(song: nowPlaying!)
                print("Changing nowPlaying")
                DispatchQueue.main.async {
                    self.state.nowPlaying = song
                }
                if song != nil{
                    let data = MCSongContent.song(song: song!).toData()
                        _ = self.connection.send(data: data!, to: .all)
                }
        }
    }
    
    func queueDidChange(queue: [Song], type: QueueChangeType) {
        if connection.hasStarted{
        DispatchQueue.main.async {
            switch type{
                case .complete:
                    self.state.queue = queue
                _ = self.connection.send(data: MCSongContent.queue(songs: queue).toData()!, to: .all)
                case .nextSong:
                    DispatchQueue.main.async {
                        let element = self.state.queue.remove(at: 0)
                        self.state.queue.append(element)
                    }
                    _ = self.connection.send(data: MCSongContent.next.toData()!, to: .all)
                case .previousSong:
                    DispatchQueue.main.async {
                        let element = self.state.queue.removeLast()
                        self.state.queue.insert(element, at: 0)
                    }
                    _ = self.connection.send(data: MCSongContent.previous.toData()!, to: .all)
            }
        }
        }
    }
    
    func playingStateChanged(state: MPMusicPlaybackState) {
        if connection.hasStarted{
        var playing = false
        switch state {
            case .playing:
                DispatchQueue.main.async {
                    self.state.playing = true
                }
                playing = true
            default:
                DispatchQueue.main.async {
                    self.state.playing = false
                }
        }
        let data = MCSongContent.playing(isPlaying: playing).toData()
            _ = self.connection.send(data: data!, to: .all)
        }
    }
    
    func toggleAction(action: MusicPlayerAction) {
        switch action{
        case .play:
            if self.firstTimePlaying{
                DispatchQueue.main.async {
                    self.state.showMusicPicker = true
                }
            }else{
                self.musicPlayer.play()
            }
        case .pause:
            self.musicPlayer.pause()
        case .next:
            self.musicPlayer.foreward()
        case .previous:
            self.musicPlayer.backward()
            
        }
    }
}
