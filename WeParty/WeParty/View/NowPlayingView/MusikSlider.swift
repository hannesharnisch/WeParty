//
//  MusikSlider.swift
//  PartyCollaborate2
//
//  Created by Hannes Harnisch on 28.03.20.
//  Copyright © 2020 Hannes Harnisch. All rights reserved.
//

import SwiftUI

struct MusikSlider: View {
    @State var value:CGFloat
    
    var body: some View {
        Slider(value: Binding(
            get: {
                self.value
            },
            set: {(newValue) in
                  self.value = newValue
                print(self.value)
            }
            )).foregroundColor(.black).accentColor(.gray).shadow(radius: 5)
    }
}
