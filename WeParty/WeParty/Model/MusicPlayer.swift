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
    private var currentPlaybackTime:Double?
    var playHeadTimer:Timer? = nil {
        willSet {
            playHeadTimer?.invalidate()
        }
    }
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
    func subscribeToPlayHead(){
        playHeadTimer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(self.playHeadChangeTimer), userInfo: nil, repeats: true)
    }
    func cancelPlayHeadSubscription(){
        playHeadTimer?.invalidate()
        playHeadTimer = nil
    }
    @objc func playHeadChangeTimer(){
        if Double(musicPlayer.currentPlaybackTime) != self.currentPlaybackTime || self.currentPlaybackTime == nil {
            self.currentPlaybackTime = Double(musicPlayer.currentPlaybackTime)
            if self.delegate != nil{
                delegate?.playHeadPositionChanged(current: Double(musicPlayer.currentPlaybackTime), total: Double(musicPlayer.nowPlayingItem?.playbackDuration ?? 0))
            }
        }
    }
    func setSongs(queue:MPMediaItemCollection){
        musicPlayer.setQueue(with: queue)
        self.queue = []
        for item in queue.items{
            self.queue.append(Song(song: item)!)
        }
        musicPlayer.prepareToPlay()
    }
    func setSongs(queue:[Song]){
        var ids = [String]()
        for song in queue{
            if song.appleMusicSongID != nil{
                ids.append(song.appleMusicSongID!)
            }
        }
        self.queue = queue
        musicPlayer.setQueue(with: MPMusicPlayerStoreQueueDescriptor(storeIDs: ids))
        print("SET SONGS")
        musicPlayer.prepareToPlay()
    }
    func addSongsToQueue(songs: MPMediaItemCollection){
        let descriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: songs)
        musicPlayer.append(descriptor)
        var songsson = [Song]()
        for song in songs.items{
            songsson.append(Song(song: song)!)
        }
        self.delegate?.queueDidChange(queue: songsson, type: .songsAppended(afterIndex: ((queue.count-1) - (indexNowPlayingItem ?? 0))))
        self.queue.append(contentsOf: songsson)
    }
    func addSongsToQueue(songs:[Song]){
        var ids = [String]()
        for song in songs{
            ids.append(song.appleMusicSongID!)
        }
        let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: ids)
        musicPlayer.append(descriptor)
        self.delegate?.queueDidChange(queue: songs, type: .songsAppended(afterIndex: ((queue.count-1) - (indexNowPlayingItem ?? 0))))
        self.queue.append(contentsOf: songs)
    }
    func prependSongsToQueue(songs: MPMediaItemCollection){
        let descriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: songs)
        musicPlayer.prepend(descriptor)
        var songsson = [Song]()
        for song in songs.items{
            songsson.append(Song(song: song)!)
        }
        self.queue = insertAtNowPlayingItem(queue: queue, songs: songsson)
        self.delegate?.queueDidChange(queue: songsson, type: .songsPrepended)
    }
    func prependSongsToQueue(songs:[Song]){
        self.queue = insertAtNowPlayingItem(queue: queue, songs: songs)
        musicPlayer.prepend(self.queueDescriptorFrom(songs: songs))
        self.delegate?.queueDidChange(queue: songs, type: .songsPrepended)
    }
    private func insertAtNowPlayingItem(queue:[Song],songs:[Song])->[Song]{
        let index = musicPlayer.indexOfNowPlayingItem
        var newQueue = [Song]()
        for i in (0...index){
            newQueue.append(queue[i])
        }
        newQueue.append(contentsOf: songs)
        if index != queue.count{
            for a in (index + 1)..<queue.count{
                newQueue.append(queue[a])
            }
        }
        return newQueue
    }
    func removeSongFromQueue(song:Song){
        print("REMOVing \(song.title)")
        guard var queue = getCurrentQueue() else{
            print("ERROR loading QUEUE")
            return
        }
        let element = queue.removeLast()
        queue.insert(element, at: 0)
        queue.removeAll { (song1) -> Bool in
            return song1 == song
        }
        let state = musicPlayer.playbackState
        let playbackTime = musicPlayer.currentPlaybackTime
        let isNowPlayingBeeingDeleted = Song(song: musicPlayer.nowPlayingItem!) == song
        self.queue = queue
        musicPlayer.prepareToPlay()
        musicPlayer.setQueue(with: self.queueDescriptorFrom(songs: queue))
        //musicPlayer.prepareToPlay()
        if state == .playing{
            musicPlayer.play()
        }
        if !isNowPlayingBeeingDeleted{
            setNowPlayingPosition(position: playbackTime)
        }
    }
    func setNowPlayingPosition(position:TimeInterval){
        guard musicPlayer.nowPlayingItem?.playbackDuration ?? 0.0 > position else{
            return
        }
        musicPlayer.currentPlaybackTime = position
    }
    func queueDescriptorFrom(songs:[Song])->MPMusicPlayerStoreQueueDescriptor{
        var ids = [String]()
        for song in songs{
            ids.append(song.appleMusicSongID!)
        }
        return MPMusicPlayerStoreQueueDescriptor(storeIDs: ids)
    }
    @objc private func sendNowPlayingChange(_ notification: Notification){
        print("SENDing NOW")
        let index = musicPlayer.indexOfNowPlayingItem
        if delegate != nil {
            if indexNowPlayingItem != nil && (indexNowPlayingItem ?? 0 < queue?.count ?? 0 + 10){
            if index == (indexNowPlayingItem! - 1){
                self.delegate!.queueDidChange(queue: self.getCurrentQueue()!, type: .previousSong)
            } else if index == (indexNowPlayingItem! + 1){
                self.delegate!.queueDidChange(queue: self.getCurrentQueue()!, type: .nextSong)
            } else{
                let queue = self.getCurrentQueue()
                if queue != nil{
                    self.delegate!.queueDidChange(queue: queue!,type: .complete)
                }else{
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                        guard let queue = self.getCurrentQueue() else{
                            return
                        }
                        self.delegate!.queueDidChange(queue: queue,type: .complete)
                    }
                }
            }
        }
            self.playHeadChangeTimer()
            self.indexNowPlayingItem = index
            self.delegate!.nowPlayingChanged(nowPlaying: musicPlayer.nowPlayingItem)
        }
    }
    func getCurrentQueue() -> [Song]?{
        let items = queue!
        let index = musicPlayer.indexOfNowPlayingItem
        var queue = [Song]()
        if items.count == 1{
            queue.append(items[0])
        }else if index >= items.count{
            return nil
        }else{
            if index < items.count - 1 {
                for i in (index + 1..<items.count){
                    queue.append(items[i])
                }
            }
            for a in 0...index{
                queue.append(items[a])
            }
        }
        return queue
    }
    @objc private func sendChangedQueue(_ notification: Notification){
        print("SENDing QUEUE")
        let queue = self.getCurrentQueue()
        if delegate != nil && queue != nil{
            if queue != nil{
                self.delegate!.queueDidChange(queue: queue!,type: .complete)
            }else{
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    guard let queue = self.getCurrentQueue() else{
                        return
                    }
                    self.delegate!.queueDidChange(queue: queue,type: .complete)
                }
            }
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
    func playHeadPositionChanged(current:Double,total:Double)
}
enum QueueChangeType{
    case complete
    case nextSong
    case previousSong
    case songsPrepended
    case songsAppended(afterIndex:Int)
}
