//
//  DraggableSmallRepresentationView.swift
//  PartyCollaborate2
//
//  Created by Hannes Harnisch on 29.03.20.
//  Copyright © 2020 Hannes Harnisch. All rights reserved.
//

import SwiftUI

struct DraggableSmallRepresentationView<T:View,L:View,S:View>: View {
    var smallContent:T
    var largeContent:L
    var content:S
    @GestureState private var dragOffset = CGSize.zero
    @Binding var percentage:CGFloat
    init(percentage:Binding<CGFloat>,smallContent:() -> T,largeContent:() -> L,content: () -> S){
        self.content = content()
        self.smallContent  = smallContent()
        self.largeContent  = largeContent()
        self._percentage   = percentage
    }
    var body: some View {
        VStack(alignment: .center){
            if percentage != 0{
                HStack{
                    Spacer()
                    Image(systemName: "minus").resizable().foregroundColor(Color(UIColor.lightGray)).frame(width:40,height:6).padding([.bottom,.horizontal],5).padding(.top, 3)
                    Spacer()
                }.contentShape(Rectangle()).onTapGesture {
                        self.percentage = 0
                }
                    Spacer()
            }
            HStack(alignment:.center){
                content
                if percentage == 0{
                    smallContent
                }
            }.padding(.bottom, 3).padding(.horizontal, 5).padding(.top, 6).onTapGesture {
                if self.percentage == 0{
                    self.percentage = 100
                }
            }
            if percentage != 0{
                Spacer()
                largeContent
            }
            Spacer()
        }.padding(6).frame(width: UIScreen.main.bounds.width,height: (75 + (((percentage/100) * (UIScreen.main.bounds.height - 180)) - CGFloat(self.dragOffset.height)))).gesture(
            DragGesture()
            .updating($dragOffset, body: { (value, state, transaction) in
                state = value.translation
            })
            .onEnded({ value in
                if (CGFloat(value.translation.height)*2 >= UIScreen.main.bounds.height/2){
                self.percentage = 0
            }else{
                self.percentage = 100
            }
        })).background(Blur().onTapGesture {
            if self.percentage == 0{
                self.percentage = 100
            }
        }.gesture(
            DragGesture()
            .updating($dragOffset, body: { (value, state, transaction) in
                state = value.translation
            })
            .onEnded({ value in
                if (CGFloat(value.translation.height)*2 >= UIScreen.main.bounds.height/2){
                self.percentage = 0
            }else{
                self.percentage = 100
            }
        }))).cornerRadius(self.percentage != 0 ? 20 : 0).shadow(radius: 10).animation(.linear)
    }
}
