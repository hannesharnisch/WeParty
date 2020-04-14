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
import StoreKit

class WePartyState:ObservableObject{
    @Published var isServer = false
    @Published var playing = false
    @Published var discoveredPeers:[MCPeerID] = []
    @Published var connectedPeers:[MCPeerID] = []
    @Published var queue:[Song] = []
    @Published var nowPlaying:Song?
    @Published var showMusicPicker = false
    @Published var showAlertView = false
    @Published var hasMusicInLib = false
    @Published var hasAppleMusic = false
    @Published var currentHost:MCPeerID?
    
    func requestCapabilities(){
            SKCloudServiceController().requestCapabilities { (capability:SKCloudServiceCapability, err:Error?) in
                guard err == nil else {
                    print("error in capability check is \(err!)")
                    return
                }

                if capability.contains(SKCloudServiceCapability.musicCatalogPlayback) {
                    DispatchQueue.main.async {
                        self.hasMusicInLib = true
                        print("HAS SONGS")
                    }
                }

                if !capability.contains(SKCloudServiceCapability.musicCatalogSubscriptionEligible) {
                    DispatchQueue.main.async {
                        self.hasAppleMusic = true
                        print("HAS APPLE MUSIC")
                    }
                }
            }
    }
}
