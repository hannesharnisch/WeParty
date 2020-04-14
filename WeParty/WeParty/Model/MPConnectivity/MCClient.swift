//
//  MCClient.swift
//  PartyCollaborate
//
//  Created by Hannes Harnisch on 04.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MCClient:NSObject,MCSessionDelegate,MCNearbyServiceBrowserDelegate{
    var isRunning = false
    var mcSession:MCSession!
    var mcBrowser:MCNearbyServiceBrowser!
    var delegate:MCClientDelegate!
    var currentHost:MCPeerID!
    let me = MCPeerID(displayName: UIDevice.current.name)
    var SERVICE_TYPE:String
    var connections = [MCConnection](){
        didSet{
            let peers = MCConnection.getPeers(connections: connections)
            if self.delegate != nil{
                delegate.didUpdate(Connections: peers)
            }
        }
    }
    var discoveredPeers = [DiscoveredPeer](){
        didSet{
            let peers = DiscoveredPeer.getPeers(peers: discoveredPeers)
            if self.delegate != nil{
                delegate.didUpdate(foundPeers: peers)
            }
        }
    }
    init(SERVICE_TYPE:String){
        self.SERVICE_TYPE = SERVICE_TYPE
        super.init()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    @objc func appMovedToBackground(){
        print("KEEP ALIVE")
        if self.isRunning{
            self.send(data: "keepAlive".data(using: .utf8)!, to: .host)
            let con = self.connections.first { (con) -> Bool in
                return con.peerId == self.currentHost
            }
            if con != nil{
                con!.status = .keepAlive
            }
        }
    }
    deinit {
        print("DEINIT")
        self.send(data: "dis".data(using: .utf8)!, to: .host)
    }
    func start(){
        isRunning = true
        print("STARTING CLIENT")
        mcSession = MCSession(peer: self.me, securityIdentity: nil, encryptionPreference: .required);
        mcSession.delegate = self
        mcBrowser = MCNearbyServiceBrowser(peer: self.me, serviceType: SERVICE_TYPE)
        mcBrowser.delegate = self
        mcBrowser.startBrowsingForPeers()
    }
    func stop(){
        isRunning = false
        print("STOPPING CLIENT")
        mcBrowser.stopBrowsingForPeers()
        self.mcSession.disconnect()
        connections = []
        discoveredPeers = []
        currentHost = nil
    }
    func reset(){
        self.stop()
        self.start()
    }
    func invite(peer:String)->Bool{
        let peers = discoveredPeers.filter { (discovered) -> Bool in
            return peer == discovered.peerId.displayName
        }
        print("CONNECT TO")
        print(peers[0].peerId.displayName)
        return self.sendRequestToConnect(to: peers[0].peerId)
    }
    func sendRequestToConnect(to:MCPeerID) -> Bool{
        let index = self.discoveredPeers.lastIndex { (discovered) -> Bool in
            return discovered.peerId == to
        }
        if index != nil{
            self.mcBrowser.invitePeer(to, to: mcSession, withContext: nil, timeout: 99999)
            self.currentHost = to
            return true
        }else{
            return false
        }
    }
    func send(data:Data,to:MCPeerOptions) ->Bool{
        do{
            switch to{
            case .all:
                try self.mcSession.send(data, toPeers: MCConnection.getPeerIDs(from: nil, connections: self.connections), with: .reliable)
            case .withName(let names):
                try self.mcSession.send(data, toPeers: MCConnection.getPeerIDs(from: names, connections: self.connections), with: .reliable)
            case .host:
                try self.mcSession.send(data, toPeers: [self.currentHost], with: .reliable)
            }
            return true
        }catch(_){
            return false
        }
    }
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            self.connections.append(MCConnection(peerId: peerID, mcSession: self.mcSession))
            self.discoveredPeers.removeAll { (discovered) -> Bool in
                return discovered.peerId == peerID
            }
        case .connecting:
            print("connecting")
        default:
            print("Dis \(peerID.displayName)")
            self.connections.removeAll { (connection) -> Bool in
                return connection.peerId == peerID
            }
            if peerID == currentHost {
                self.reset()
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let text = String(data: data, encoding: .utf8)
        print("DID RECIEVE")
        if text == "exit"{
            print("RESET")
            self.reset()
        }else{
            if self.delegate != nil{
                self.delegate.didRecieve(data: data, from: peerID)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let index = self.discoveredPeers.lastIndex { (discoverd) -> Bool in
            return discoverd.peerId.displayName == peerID.displayName
        }
        if index == nil{
                self.discoveredPeers.append(DiscoveredPeer(peerId: peerID))
                print("ADDED PEER")
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.discoveredPeers.removeAll { (discovered) -> Bool in
            return discovered.peerId == peerID
        }
    }
    
    
}
protocol MCClientDelegate {
    func didUpdate(foundPeers to:[MCPeerID])
    func didUpdate(Connections to:[MCPeerID])
    func didRecieve(data:Data,from:MCPeerID)
}
