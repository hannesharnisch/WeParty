//
//  StartUpView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 26.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct StartUpView: View {
    @State var presented = 0
    @Binding var isLoadingScreenShown:Bool
    @State var opacity = 0.0
    @State var backgroundOpacity = 1.0
    @State var oldView = 0
    var body: some View {
        ZStack{
            Rectangle().foregroundColor(.white).edgesIgnoringSafeArea(.bottom).opacity(backgroundOpacity)
        VStack{
            if presented == 0{
                IntroductionView()
            }else if presented == 1{
                ExplainationView()
            }else{
                LoadingScreen(isLoadingScreenShown: $isLoadingScreenShown).onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.backgroundOpacity = 0.0
                        Storage.wasOpened()
                    }
                }
            }
            if presented != 2{
            Spacer()
            HStack{
                Button(action:{
                    self.oldView = self.presented
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.presented -= 1
                    }
                }){
                    Text("back").padding()
                }.disabled(self.presented < 1)
                Spacer()
                Button(action:{
                    self.oldView = self.presented
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.presented += 1
                    }
                }){
                    Text("Continue").padding()
                }
            }
            }
        }.opacity(opacity).onAppear {
            withAnimation(.easeInOut(duration:0.5)) {
                self.opacity = 1.0
            }
            }
        }
    }
}
struct SizedImage:View{
    var name:String
    var body: some View {
        Image(systemName: name).resizable().frame(width:40,height: 40).foregroundColor(.black)
    }
}

struct StartUpView_Previews: PreviewProvider {
    static var previews: some View {
        StartUpView(isLoadingScreenShown: .constant(true))
    }
}
