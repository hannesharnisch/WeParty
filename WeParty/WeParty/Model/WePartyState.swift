//
//  WePartyState.swift
//  WeParty
//
//  Created by Hannes Harnisch on 13.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import Foundation
import Combine
import MultipeerConnectivity

class WePartyState:ObservableObject{
    @Published var isServer = false
    @Published var playing = false
    @Published var discoveredPeers:[MCPeerID] = []
    @Published var connectedPeers:[MCPeerID] = []
    @Published var queue:[Song] = []
    @Published var nowPlaying:Song?
    @Published var currentPosition:CGFloat = 0.0
    @Published var endPostition:CGFloat = 0.0
    @Published var showMusicPicker = false
    @Published var showAlertView = false
    @Published var currentHost:MCPeerID?
    var timer:Timer?
    
    func startIncrementingCurrent(){
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(self.incrementTime), userInfo: nil, repeats: true)
    }
    @objc private func incrementTime(){
        self.currentPosition += 0.8
    }
    func stopIncrementingCurrent(){
        timer?.invalidate()
        timer = nil
    }
}
