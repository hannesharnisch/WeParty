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
    @State var showNameInput = false
    @ObservedObject var settings = AppSettings.current
    @State var selection = Int(QueueMode.allCases.firstIndex(of: AppSettings.current.musicQueueingMode)!)
    var body: some View {
        NavigationView{
            List{
                HStack{
                    Text("Displayname:")
                    Spacer()
                    Text(self.settings.name != "" ? self.settings.name:"No name specified")
                    Image(systemName:"arrowtriangle.right.circle")
                    
                }.padding(.horizontal).onTapGesture {
                    self.showNameInput = true
                }
                if self.state.isServer{
                    ExtendablePicker(text:"Music queueing type",data:{
                        var data = [String]()
                        for mode in QueueMode.allCases{
                            data.append(mode.rawValue)
                        }
                        return data
                    }(), selection: $selection){ selection in
                        self.settings.musicQueueingMode = QueueMode.init(rawValue: selection)!
                    }
                }
                SettingsInfoBitView(text:"Connected to the Internet",wert: settings.hasInternetConnection){
                    
                }
                //Divider()
                SettingsInfoBitView(text:"Connected to Music Library",wert: settings.hasMusicInLib){
                    self.settings.requestMediaLibraryAccess(){ success in
                        if !success{
                            self.alertText = "No Connnection to Music Library possible"
                            self.alertShown = true
                        }
                    }
                }
                //Divider()
                SettingsInfoBitView(text:"Connected to Apple Music",wert:settings.hasAppleMusic){
                    self.settings.requestMusicCapabilities(){ success in
                        if !success{
                            self.alertText = "No Connnection to Apple Music possible"
                            self.alertShown = true
                        }
                    }
                }
                Toggle(isOn: $settings.hasPremium) {
                    Text("Premium")
                }.padding(.horizontal)
                //Spacer()
            }.sheet(isPresented: $showNameInput, onDismiss: {
                AppSettings.current.name = self.settings.name
            }){
                NameInputView(name:self.$settings.name, shown: self.$showNameInput)
            }
                .navigationBarTitle(Text("Settings"))
        }.alert(isPresented: $alertShown) {
            Alert(title: Text("Failed to Connect"), message: Text(alertText), dismissButton: .default(Text("ok")))
        }.onDisappear {
            AppSettings.current.saveSettings()
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
            Image(systemName:"arrowtriangle.right.circle").rotationEffect(showPicker ? .init(degrees: 90):.zero)
        }.onTapGesture {
            self.showPicker.toggle()
            self.action(self.data[self.selection])
        }
        if self.showPicker{
            Picker(selection: $selection, label: Text("")) {
                ForEach(0..<data.count){
                    Text(self.data[$0])
                }
            }
        }
        }.padding(.horizontal).onDisappear {
            self.action(self.data[self.selection])
        }
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
        }.padding(.horizontal)
    }
}
