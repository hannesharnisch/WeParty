//
//  MusicPlayer.swift
//  WeParty
//
//  Created by Hannes Harnisch on 13.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import Foundation
import MediaPlayer

class MusicPlayer{
    private var musicPlayer = MPMusicPlayerController.systemMusicPlayer
    var delegate:MusicPlayerDelegate?
    private var queue:[Song]!
    private var indexNowPlayingItem:Int?
    
    init(){
        musicPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendNowPlayingChange(_:)), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendChangedQueue(_:)), name: .MPMusicPlayerControllerQueueDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendPlaybackState(_:)), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        musicPlayer.repeatMode = .all
        musicPlayer.shuffleMode = .off
    }
    func setSongs(queue:MPMediaItemCollection){
        musicPlayer.setQueue(with: queue)
        self.queue = []
        for item in queue.items{
            self.queue.append(Song(song: item)!)
        }
        musicPlayer.prepareToPlay()
    }
    func addSongsToQueue(songs: MPMediaItemCollection){
        let descriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: songs)
        musicPlayer.prepend(descriptor)
    }
    func addSongsToQueue(songs:[Song]){
        var ids = [String]()
        for song in songs{
            ids.append(song.appleMusicSongID!)
        }
        let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: ids)
        musicPlayer.prepend(descriptor)
    }
    @objc private func sendNowPlayingChange(_ notification: Notification){
        print("SENDing NOW")
        let index = musicPlayer.indexOfNowPlayingItem
        if delegate != nil {
            if indexNowPlayingItem != nil && (indexNowPlayingItem ?? 0 < queue.count + 10){
            if index == (indexNowPlayingItem! - 1){
                self.delegate!.queueDidChange(queue: self.getCurrentQueue(), type: .previousSong)
            } else if index == (indexNowPlayingItem! + 1){
                self.delegate!.queueDidChange(queue: self.getCurrentQueue(), type: .nextSong)
            } else{
                self.delegate!.queueDidChange(queue: self.getCurrentQueue(), type: .complete)
            }
        }
            self.indexNowPlayingItem = index
            self.delegate!.nowPlayingChanged(nowPlaying: musicPlayer.nowPlayingItem)
        }
    }
    func getCurrentQueue() -> [Song]{
        let items = queue!
        let index = musicPlayer.indexOfNowPlayingItem
        var queue = [Song]()
        for i in ((index + 1)..<items.count){
            queue.append(items[i])
        }
        for a in 0...index{
            queue.append(items[a])
        }
        return queue
    }
    @objc private func sendChangedQueue(_ notification: Notification){
        print("SENDing QUEUE")
        if delegate != nil && queue != nil{
            self.delegate!.queueDidChange(queue: self.getCurrentQueue(),type: .complete)
        }
    }
    @objc private func sendPlaybackState(_ notification: Notification){
        print("SENDing STATE")
        if delegate != nil {
            self.delegate!.playingStateChanged(state: musicPlayer.playbackState)
        }
    }
    
    func play(){
        self.sendPlaybackState(Notification(name: .MPMusicPlayerControllerPlaybackStateDidChange))
        musicPlayer.play()
    }
    func pause(){
        musicPlayer.pause()
    }
    func foreward(){
        musicPlayer.skipToNextItem()
    }
    func backward(){
        musicPlayer.skipToPreviousItem()
    }
}
protocol MusicPlayerDelegate {
    func nowPlayingChanged(nowPlaying:MPMediaItem?)
    func queueDidChange(queue:[Song],type:QueueChangeType)
    func playingStateChanged(state: MPMusicPlaybackState)
}
enum QueueChangeType{
    case complete
    case nextSong
    case previousSong
}
