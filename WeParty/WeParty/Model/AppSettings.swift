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

class AppSettings:ObservableObject{
    public static var current = AppSettings()
    @Published var hasMusicInLib = false
    @Published var hasAppleMusic = false
    @Published var hasInternetConnection = false
    @Published var name = ""
    @Published var hasPremium = true
    private let monitor = NWPathMonitor()
    var musicQueueingMode:QueueMode = .append
    private init(){
        self.requestMusicCapabilities(){ result in }
        monitor.pathUpdateHandler = self.pathUpdateHandler(path:)
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        let settings = Storage.restoreOldAppSettings(settings: self)
        self.name = settings.name
        print(name)
        self.musicQueueingMode = settings.musicQueueingMode
        print(musicQueueingMode)
    }
    func saveSettings(){
        Storage.storeAppSettings(settings: self)
        print("Saved")
    }
    deinit {
        self.saveSettings()
        monitor.cancel()
    }
    private func pathUpdateHandler(path:NWPath){
        DispatchQueue.main.async {
            if path.status == .satisfied{
                self.hasInternetConnection = true
            }else{
                self.hasInternetConnection = false
            }
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
                    hasmusic = true
                    DispatchQueue.main.async {
                        self.hasMusicInLib = true
                        print("HAS SONGS")
                    }
                }

                if !capability.contains(SKCloudServiceCapability.musicCatalogSubscriptionEligible) {
                    hasmusic = true
                    DispatchQueue.main.async {
                        self.hasAppleMusic = true
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
    case append = "append",prepend = "prepend",appendHostPrepend = "Only party-host prepend",prependHostAppend = "Only party-host append"
}
class Storage{
    private static let store = UserDefaults.standard
    static func storeAppSettings(settings:AppSettings){
        let index = QueueMode.allCases.index(of: settings.musicQueueingMode)
        store.set(index, forKey: "QueueingType")
        store.set(settings.name, forKey: "Displayname")
        print("saving")
    }
    static func restoreOldAppSettings(settings:AppSettings) -> AppSettings{
        settings.name = store.string(forKey: "Displayname") ?? ""
        let index = store.integer(forKey: "QueueingType") ?? 0
        settings.musicQueueingMode = QueueMode.allCases[index]
        return settings
    }
    static func hasAlreadyBeenOpened() -> Bool{
        let wasopened = store.bool(forKey: "opened")
        return wasopened
    }
    static func wasOpened(){
        store.set(true, forKey: "opened")
    }
}
