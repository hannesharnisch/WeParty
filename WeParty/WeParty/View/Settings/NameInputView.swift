//
//  NameInputView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 26.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct NameInputView: View {
    @Binding var name:String
    @Binding var shown:Bool
    var body: some View {
        VStack{
            Image(systemName:"person.crop.circle").resizable().scaledToFit().padding([.horizontal,.top],50)
            Text(name)
            Spacer()
            TextField("Displayname", text: $name).padding()
            Button(action:{
                self.shown = false
            }){
                Text("Finish")
            }
            Spacer()
        }
    }
}

struct NameInputView_Previews: PreviewProvider {
    static var previews: some View {
        NameInputView(name: .constant("HAllop"), shown: .constant(true))
    }
}
