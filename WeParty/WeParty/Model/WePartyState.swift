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
    
    private var semaphore = DispatchSemaphore(value: 0)
    private var alertQueue = DispatchQueue(label: "alertWaiting")
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
    func closedMusicPicker(){
        print("semaphore signal")
        if self.discoveredPeers.count > 0{
            self.semaphore.signal()
        }
    }
    func showAlert(){
        print("show alert")
        alertQueue.async {
            if self.showMusicPicker{
                print("semaphore wait")
                self.semaphore.wait(timeout: .distantFuture)
                print("semaphore weiter")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.showAlertView  = true
                })
            }
            DispatchQueue.main.async {
                 self.showAlertView = true
            }
        }
    }
}
