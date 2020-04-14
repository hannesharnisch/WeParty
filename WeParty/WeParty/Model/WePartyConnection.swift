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
    private var host = MCHost(SERVICE_TYPE: "party")
    private var client = MCClient(SERVICE_TYPE: "party")
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
            self.state.requestCapabilities()
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
                self.delegate.songsRecieved(songs: [song])
            case .queue(let songs):
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
            case .playing(let playing):
                self.state.playing = playing
            case .queue(let songs):
                self.state.queue = songs
            case .none:
                return
            case .next:
                let element = self.state.queue.remove(at: 0)
                self.state.queue.append(element)
            case .previous:
                let element = self.state.queue.removeLast()
                self.state.queue.insert(element, at: 0)
                }
            }
        }
        }
    }
    
    func newConnection(from: MCPeerID) {
        connectionQueue.async {
        if self.state.nowPlaying != nil{
            _ = self.send(data: MCSongContent.song(song: self.state.nowPlaying!).toData()!, to: .withName(names: [from.displayName]))
            _ = self.send(data: MCSongContent.playing(isPlaying: self.state.playing).toData()!, to: .withName(names: [from.displayName]))
            _ = self.send(data: MCSongContent.queue(songs: self.state.queue).toData()!, to: .withName(names: [from.displayName]))
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
    case playing(isPlaying:Bool)
    case next
    case previous
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self){
            self = .playing(isPlaying: value)
        } else if let value = try? container.decode(Song.self){
            self = .song(song: value)
        } else if let value = try? container.decode([Song].self){
            self = .queue(songs: value)
        } else if let value = try? container.decode(String.self){
            if value == "next"{
                self = .next
            }else if value == "previous"{
                self = .previous
            }else{
                throw DecodingError.typeMismatch(MCSongContent.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a SongContent"))
            }
        } else{
            throw DecodingError.typeMismatch(MCSongContent.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a SongContent"))
        }
    }
    func toData() -> Data?{
        switch self {
        case .song(let song):
            return try! JSONEncoder().encode(song)
        case .queue(let songs):
            return try! JSONEncoder().encode(songs)
        case .playing(let isPlaying):
            return try! JSONEncoder().encode(isPlaying)
        case .next:
            return try! JSONEncoder().encode("next")
        case .previous:
            return try! JSONEncoder().encode("previous")
        }
    }
}
