//
//  Settings.swift
//  WeParty
//
//  Created by Hannes Harnisch on 18.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var state:WePartyState
    @State var alertShown = false
    @State var alertText = ""
    @State var selection = Int(QueueMode.allCases.firstIndex(of: AppSettings.current.musicQueueingMode)!)
    var body: some View {
        NavigationView{
            VStack{
                SettingsInfoBitView(text:"Connected to the Internet",wert: AppSettings.current.hasInternetConnection){
                    
                }
                if self.state.isServer{
                    Divider()
                    ExtendablePicker(text:"Music queueing type",data:{
                        var data = [String]()
                        for mode in QueueMode.allCases{
                            data.append(mode.rawValue)
                        }
                        return data
                    }(), selection: $selection){ selection in
                        AppSettings.current.musicQueueingMode = QueueMode.init(rawValue: selection)!
                    }
                }
                Divider()
                SettingsInfoBitView(text:"Connected to Music Library",wert: AppSettings.current.hasMusicInLib){
                    AppSettings.current.requestMediaLibraryAccess(){ success in
                        if !success{
                            self.alertText = "No Connnection to Music Library possible"
                            self.alertShown = true
                        }
                    }
                }
                Divider()
                SettingsInfoBitView(text:"Connected to Apple Music",wert:AppSettings.current.hasAppleMusic){
                    AppSettings.current.requestMusicCapabilities(){ success in
                        if !success{
                            self.alertText = "No Connnection to Apple Music possible"
                            self.alertShown = true
                        }
                    }
                }
                Spacer()
            }.padding()
                .navigationBarTitle(Text("Settings"))
        }.alert(isPresented: $alertShown) {
            Alert(title: Text("Failed to Connect"), message: Text(alertText), dismissButton: .default(Text("ok")))
        }
    }
}
struct ExtendablePicker:View{
    var text:String
    var data:[String]
    @Binding var selection:Int
    @State var showPicker = false
    var action:(String)->()
    var body: some View {
        VStack{
        HStack{
            Text(text)
            Spacer()
            Text(data[selection])
            Button(action:{
                self.showPicker.toggle()
                self.action(self.data[self.selection])
            }){
                if showPicker {
                    Text("Hide Picker")
                }else{
                    Text("Show Picker")
                }
            }
        }
        if self.showPicker{
            Picker(selection: $selection, label: Text("")) {
                ForEach(0..<data.count){
                    Text(self.data[$0])
                }
            }
        }
        }.padding()
    }
}
struct SettingsInfoBitView: View {
    var text:String
    var wert:Bool
    var action:()->()
    var body: some View {
        HStack{
            Text(text)
            Spacer()
            if wert{
                Text("yes").foregroundColor(.green)
            }else{
                Button(action:{
                    self.action()
                }){
                    Text("Try to connect").foregroundColor(.red)
                }
            }
        }.padding()
    }
}
