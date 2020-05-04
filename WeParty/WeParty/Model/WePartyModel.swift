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

class WePartyModel:NSObject, PartyCollaborateMCConnectionDelegate{
    private var state:WePartyState
    var connection:WePartyConnection
    var musicPlayer = MusicPlayer()
    private var musicFinder = MusicFinder(fileName: "AuthKey_QH8XRCS4JS.p8", kid: "QH8XRCS4JS", iss: "AVT8X3595T")
    private var firstTimePlaying = true
    private var songLoadingQueue = DispatchQueue(label: "Song Loading")
    
    init(state:WePartyState){
        self.state = state
        self.connection = WePartyConnection(state: state)
        super.init()
        self.connection.delegate = self
        self.musicPlayer.delegate = self
    }
    func songsRecieved(songs: [RecievedSong]) {
        for song in songs{
            if song.appleMusicSongID != nil{
                song.acceptFunc = { song in
                    self.songLoadingQueue.async {
                        self.addToQueue(songs: [song], from: false)
                    }
                    self.state.recievedSongs.removeAll { (recieved) -> Bool in
                        return recieved == song
                    }
                }
                song.declineFunc = { song in
                    self.state.recievedSongs.removeAll { (recieved) -> Bool in
                        return recieved == song
                    }
                }
                self.state.recievedSongs.insert(song, at: 0)
                if !AppSettings.current.hasPremium{
                    song.accept()
                }
            }else{
                musicFinder.findSong(song: song) { (result) in
                    switch result{
                    case .success(let ps):
                        let recievedSong = RecievedSong(song: ps, sender: song.sender!)
                        recievedSong.acceptFunc = { song in
                            self.songLoadingQueue.async {
                                self.addToQueue(songs: [song], from: false)
                            }
                            self.state.recievedSongs.removeAll { (recieved) -> Bool in
                                return recieved == song
                            }
                        }
                        recievedSong.declineFunc = { song in
                            self.state.recievedSongs.removeAll { (recieved) -> Bool in
                                return recieved == song
                            }
                        }
                        self.state.recievedSongs.insert(song, at: 0)
                        if !AppSettings.current.hasPremium{
                            recievedSong.accept()
                        }
                    case .failure(let err):
                        print(err)
                    }
                }
            }
            
        }
    }
    func removeFromQueue(song:Song){
        songLoadingQueue.async {
            self.musicPlayer.removeSongFromQueue(song: song)
        }
    }
    func moveSong(song:Song,to index:Int){
        
    }
    func addToQueue(songs:[Song],from host:Bool){
        switch AppSettings.current.musicQueueingMode {
        case .append:
            self.musicPlayer.addSongsToQueue(songs: songs)
        case .prepend:
            self.musicPlayer.prependSongsToQueue(songs: songs)
        case .appendHostPrepend:
            if host{
                self.musicPlayer.prependSongsToQueue(songs: songs)
            }else{
                self.musicPlayer.addSongsToQueue(songs: songs)
            }
        case .prependHostAppend:
            if host{
                self.musicPlayer.addSongsToQueue(songs: songs)
            }else{
                self.musicPlayer.prependSongsToQueue(songs: songs)
            }
        }
    }
    func addToQueue(songs:MPMediaItemCollection,from host:Bool){
        switch AppSettings.current.musicQueueingMode {
        case .append:
            self.musicPlayer.addSongsToQueue(songs: songs)
        case .prepend:
            self.musicPlayer.prependSongsToQueue(songs: songs)
        case .appendHostPrepend:
            if host{
                self.musicPlayer.prependSongsToQueue(songs: songs)
            }else{
                self.musicPlayer.addSongsToQueue(songs: songs)
            }
        case .prependHostAppend:
            if host{
                self.musicPlayer.addSongsToQueue(songs: songs)
            }else{
                self.musicPlayer.prependSongsToQueue(songs: songs)
            }
        }
    }
    
}

//Song input
extension WePartyModel:MPMediaPickerControllerDelegate,SearchForSongsDelegate{
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
    didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        print("RECIEVED MEDIAITEM")
        DispatchQueue.main.async {
            self.state.showMusicPicker = false
            if self.firstTimePlaying && self.state.isServer{
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
                        self.addToQueue(songs: mediaItemCollection, from: true)
                        var queue = self.state.queue
                        if queue.count > 4{
                            queue = Array(queue[0..<5])
                        }
                        self.connection.send(data: MCSongContent.queue(songs: queue).toData()!, to: .all)
                    }
                }
            }else{
                    _ = self.connection.send(data: MCSongContent.queue(songs: songs).toData()!, to: .host)
            }
        }
    }
    func searchForSongs(with name: String,callback:@escaping ([Song]?) -> Void) {
        var songs:[Song] = []
        self.musicFinder.getSearchResult(from: name) { (result) in
            switch result{
            case .success(let songs):
                callback(songs)
            case .failure(let err):
                callback(nil)
            }
        }
    }
    func didInput(songs:[Song]){
        DispatchQueue.main.async {
            self.state.showMusicPicker = false
        }
        if self.state.isServer{
            if self.firstTimePlaying{
                self.state.nowPlaying = Song(title: "Loading...", interpret: "")
            }
            songLoadingQueue.async {
                if self.firstTimePlaying{
                    self.musicPlayer.setSongs(queue: songs)
                    self.musicPlayer.play()
                    print("play")
                    self.firstTimePlaying = false
                }else{
                    DispatchQueue.main.async {
                        self.addToQueue(songs: songs, from: false)
                        var queue = self.state.queue
                        if queue.count > 4{
                            queue = Array(queue[0..<5])
                        }
                        self.connection.send(data: MCSongContent.queue(songs: queue).toData()!, to: .all)
                    }
                }
            }
        }else{
            _ = self.connection.send(data: MCSongContent.queue(songs: songs).toData()!, to: .host)
        }
    }
}
extension WePartyModel:MusicPlayerActionEnabled, MusicPlayerDelegate{
    func playHeadPositionChanged(current: Double, total: Double) {
        DispatchQueue.main.async {
            self.state.currentPosition = CGFloat(current)
            self.state.endPostition = CGFloat(total)
        }
    }
    
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
        print(queue)
        if connection.hasStarted{
        DispatchQueue.main.async {
            switch type{
                case .complete:
                    self.state.queue = queue
                    var sendQueue = queue
                    if sendQueue.count > 4{
                        sendQueue = Array(sendQueue[0..<5])
                    }
                    _ = self.connection.send(data: MCSongContent.queue(songs: sendQueue).toData()!, to: .all)
                case .nextSong:
                    DispatchQueue.main.async {
                        let element = self.state.queue.remove(at: 0)
                        self.state.queue.append(element)
                    }
                    var sendQueue = queue
                    if sendQueue.count > 4{
                        sendQueue = Array(sendQueue[0..<5])
                    }
                    _ = self.connection.send(data: MCSongContent.next(song: sendQueue.last!).toData()!, to: .all)
                case .previousSong:
                    DispatchQueue.main.async {
                        let element = self.state.queue.removeLast()
                        self.state.queue.insert(element, at: 0)
                    }
                    _ = self.connection.send(data: MCSongContent.previous(song: queue.first!).toData()!, to: .all)
                case .songsPrepended:
                    DispatchQueue.main.async {
                        self.state.queue.insert(contentsOf: queue, at: 0)
                        var sendQueue = self.state.queue
                        if sendQueue.count > 4{
                            sendQueue = Array(sendQueue[0..<5])
                        }
                        _ = self.connection.send(data: MCSongContent.queue(songs: sendQueue).toData()!, to: .all)
                    }
                case .songsAppended(let index):
                    DispatchQueue.main.async {
                        self.state.queue.insert(contentsOf: queue, at: index)
                        var sendQueue = self.state.queue
                        if sendQueue.count > 4{
                            sendQueue = Array(sendQueue[0..<5])
                        }
                        _ = self.connection.send(data: MCSongContent.queue(songs: sendQueue).toData()!, to: .all)
                    }
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
        let data = MCSongContent.isPlaying(playing: playing).toData()
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
    func changedStateTo(large:Bool){
        if large{
            self.musicPlayer.subscribeToPlayHead()
        }else{
            self.musicPlayer.cancelPlayHeadSubscription()
        }
    }
}
