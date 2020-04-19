//
//  TableView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 18.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct TableView<T:View,S:Identifiable>: View {
    @Binding var deleteOption:Bool
    var content:(S) -> T
    @Binding var list:[S]
    var deletedAt:(IndexSet) -> ()
    init(deleteOption:Binding<Bool>,deletedAt:@escaping(IndexSet) -> (),list:Binding<[S]>,content: @escaping (S) -> T){
        self.deletedAt = deletedAt
        self.content = content
        self._deleteOption = deleteOption
        self._list = list
    }
    
    var body: some View {
        VStack{
            if self.deleteOption{
                    ForEach(self.list,id: \.id){ item in
                        self.content(item)
                    }.onDelete(perform: deleteRow(at:))
            }else{
                    ForEach(self.list,id: \.id){ item in
                        self.content(item)
                    }
            }
        }
    }
    private func deleteRow(at indexSet: IndexSet) {
        self.list.remove(atOffsets: indexSet)
        self.deletedAt(indexSet)
    }
}
