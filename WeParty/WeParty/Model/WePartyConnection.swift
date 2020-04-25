//
//  WePartyConnection.swift
//  WeParty
//
//  Created by Hannes Harnisch on 13.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class WePartyConnection:NSObject,ConnectivityEnabled,MCHostDelegate,MCClientDelegate{
    private var connectionQueue = DispatchQueue(label: "Connection")
    private var state:WePartyState
    private var host = MCHost(SERVICE_TYPE: "WeParty-app")
    private var client = MCClient(SERVICE_TYPE: "WeParty-app")
    var hasStarted = false
    var delegate:PartyCollaborateMCConnectionDelegate!
    
    init(state:WePartyState){
        self.state = state
        super.init()
        self.client.delegate = self
        self.host.delegate = self
    }
    //ConnectivityEnabled
    func start(isServer: Bool) {
        connectionQueue.async {
            AppSettings.current.requestMusicCapabilities(){ result in
                
            }
            if isServer{
                self.host.start()
            }else{
                self.client.start()
            }
            print("HAS STARTED")
            self.hasStarted = true
        }
    }
    func stop(isServer: Bool) {
        self.hasStarted = false
        connectionQueue.async {
            if isServer{
                self.host.stop()
            }else{
                self.client.stop()
            }
        }
    }
    
    func connectTo(peer: MCPeerID) {
        connectionQueue.async {
            self.client.sendRequestToConnect(to: peer)
        }
    }
    
    func connection(accept: Bool, peer: MCPeerID) {
        connectionQueue.async {
            self.host.connection(accept: accept, peer: peer)
        }
    }
    
    func reset() {
        connectionQueue.async {
            if self.state.isServer{
                self.host.stop()
                self.host.start()
            }else{
                self.client.stop()
                self.client.start()
            }
        }
    }
    
    func disconnectPeer(peer: MCPeerID) {
        self.host.disconnectPeer(peer: peer.displayName)
    }
    
    
    
    
    func didUpdate(Invitations to: [MCPeerID]) {
        print("Invitation")
        DispatchQueue.main.async {
            self.state.discoveredPeers = to
            if to.count > 0{
                self.state.showAlertView = true
            }
        }
    }
    
    func didUpdate(Connections to: [MCPeerID]) {
        DispatchQueue.main.async {
            self.state.connectedPeers = to
            if !self.state.isServer{
                self.state.currentHost = self.client.currentHost
            }
            if to.count == 0{
                self.state.queue = []
                self.state.nowPlaying = nil
                self.state.playing = false
            }
        }
    }
    
    func didRecieve(data: Data, from: MCPeerID) {
        connectionQueue.async {
        var content:MCSongContent!
        do{
            content = try JSONDecoder().decode(MCSongContent.self, from: data)
        }catch(let err){
            print("ERROR: \(err)")
            return;
        }
        if self.state.isServer{
            DispatchQueue.main.async {
            switch content {
            case .song(let song):
                print("SOng recieved")
                self.delegate.songsRecieved(songs: [song])
            case .queue(let songs):
                print("SOngs recieved")
                self.delegate.songsRecieved(songs: songs)
            default:
                return
            }
            }
        }else{
            DispatchQueue.main.async {
            switch content {
            case .song(let song):
                self.state.nowPlaying = song
                self.state.currentPosition = 0.0
                self.state.endPostition = song.length ?? 0.0
                print("END \(self.state.endPostition)")
            case .isPlaying(let playing):
                self.state.playing = playing
                if playing{
                    self.state.startIncrementingCurrent()
                }else{
                    self.state.stopIncrementingCurrent()
                }
            case .queue(let songs):
                self.state.queue = songs
            case .none:
                return
            case .next(let song):
                self.state.queue.remove(at: 0)
                self.state.queue.append(song)
            case .previous(let song):
                self.state.queue.removeLast()
                self.state.queue.insert(song, at: 0)
                }
            }
        }
        }
    }
    
    func newConnection(from: MCPeerID) {
        connectionQueue.async {
        if self.state.nowPlaying != nil{
            _ = self.send(data: MCSongContent.song(song: self.state.nowPlaying!).toData()!, to: .withName(names: [from.displayName]))
            _ = self.send(data: MCSongContent.isPlaying(playing: self.state.playing).toData()!, to: .withName(names: [from.displayName]))
            var queue = self.state.queue
            if queue.count > 4{
                queue = Array(queue[..<5])
            }
            _ = self.send(data: MCSongContent.queue(songs: queue).toData()!, to: .withName(names: [from.displayName]))
        }
        }
    }
    func send(data:Data ,to:MCPeerOptions){
        connectionQueue.async {
        if self.state.isServer{
            _ = self.host.send(data: data, to: to)
        }else{
            _ = self.client.send(data: data, to: to)
        }
        }
    }
    func didUpdate(foundPeers to: [MCPeerID]) {
        DispatchQueue.main.async {
            self.state.discoveredPeers = to
        }
    }
}
protocol PartyCollaborateMCConnectionDelegate {
    func songsRecieved(songs:[Song])
}

enum MCSongContent:Decodable{
    case song(song:Song)
    case queue(songs:[Song])
    case next(song:Song)
    case previous(song:Song)
    case isPlaying(playing:Bool)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(MCTupelObject.self){
            switch  value.type {
            case "song":
                self = .song(song: value.songs[0])
            case "queue":
                self = .queue(songs: value.songs)
            case "next":
                self = .next(song: value.songs[0])
            case "previous":
                self = .previous(song: value.songs[0])
            default:
                throw DecodingError.typeMismatch(MCSongContent.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a SongContent"))
            }
        }else if let value = try? container.decode(Bool.self){
            self = .isPlaying(playing: value)
        }else{
            throw DecodingError.typeMismatch(MCSongContent.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a SongContent"))
        }
    }
    func toData() -> Data?{
        switch self {
        case .song(let song):
            let tupel = MCTupelObject(type: "song", songs: [song])
            return try! JSONEncoder().encode(tupel)
        case .queue(let songs):
            let tupel = MCTupelObject(type: "queue", songs: songs)
            return try! JSONEncoder().encode(tupel)
        case .isPlaying(let playing):
            return try! JSONEncoder().encode(playing)
        case .next(let song):
            let tupel = MCTupelObject(type: "next", songs: [song])
            return try! JSONEncoder().encode(tupel)
        case .previous(let song):
            let tupel = MCTupelObject(type: "previous", songs: [song])
            return try! JSONEncoder().encode(tupel)
        }
    }
}
struct MCTupelObject:Decodable,Encodable{
    var type:String
    var songs:[Song]
}
