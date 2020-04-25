//
//  AskingViewHelp.swift
//  WeParty
//
//  Created by Hannes Harnisch on 25.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct AskingViewHelp: View {
    var body: some View {
        VStack{
            Text(" 1. First Select if you want to join or start a party").padding().multilineTextAlignment(.center)
            Spacer()
            Text("Start a party if you want to be the one who plays the music").font(.caption).padding().multilineTextAlignment(.center)
            Text("Join a party if you want to send music to someone who plays music with WeParty").font(.caption).multilineTextAlignment(.center).padding()
            Spacer()
            Spacer()
        }
    }
}
