//
//  SystemSettings.swift
//  WeParty
//
//  Created by Hannes Harnisch on 18.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import Foundation
import StoreKit
import Network
import MediaPlayer

class AppSettings{
    public static var current = AppSettings()
    var hasMusicInLib = false
    var hasAppleMusic = false
    let monitor = NWPathMonitor()
    var hasInternetConnection = false
    var musicQueueingMode:QueueMode = .append
    private init(){
        self.requestMusicCapabilities(){ result in }
        monitor.pathUpdateHandler = self.pathUpdateHandler(path:)
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    deinit {
        monitor.cancel()
    }
    private func pathUpdateHandler(path:NWPath){
        if path.status == .satisfied{
            hasInternetConnection = true
        }else{
            hasInternetConnection = false
        }
    }
    func requestMusicCapabilities(callback:@escaping (Bool) -> Void){
            SKCloudServiceController().requestCapabilities { (capability:SKCloudServiceCapability, err:Error?) in
                guard err == nil else {
                    callback(false)
                    //print("error in capability check is \(err!)")
                    return
                }
                var hasmusic = false
                if capability.contains(SKCloudServiceCapability.musicCatalogPlayback) {
                    DispatchQueue.main.async {
                        self.hasMusicInLib = true
                        hasmusic = true
                        print("HAS SONGS")
                    }
                }

                if !capability.contains(SKCloudServiceCapability.musicCatalogSubscriptionEligible) {
                    DispatchQueue.main.async {
                        self.hasAppleMusic = true
                        hasmusic = true
                        print("HAS APPLE MUSIC")
                    }
                }
                callback(hasmusic)
            }
    }
    func requestMediaLibraryAccess(callback:@escaping (Bool) -> Void){
        MPMediaLibrary.requestAuthorization() { status in
            if status == .authorized {
                self.requestMusicCapabilities(){ result in
                    callback(result)
                }
            }else{
                callback(false)
            }
        }
    }
}

enum QueueMode:String,CaseIterable{
    case append,prepend,appendHostPrepend,prependHostAppend
}
