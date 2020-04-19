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
    @Published var showMusicPicker = false
    @Published var showAlertView = false
    @Published var currentHost:MCPeerID?
}
