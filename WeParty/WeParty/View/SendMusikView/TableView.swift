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
    var moved:(IndexSet,Int) -> ()
    init(deleteOption:Binding<Bool>,deletedAt:@escaping(IndexSet) -> (),moved:@escaping(IndexSet,Int) -> (),list:Binding<[S]>,content: @escaping (S) -> T){
        self.deletedAt = deletedAt
        self.content = content
        self._deleteOption = deleteOption
        self._list = list
        self.moved = moved
    }
    
    var body: some View {
        List{
            if self.deleteOption{
                    ForEach(self.list,id: \.id){ item in
                        self.content(item)
                    }.onMove(perform: move).onDelete(perform: deleteRow(at:))
            }else{
                    ForEach(self.list,id: \.id){ item in
                        self.content(item)
                    }
            }
        }.onAppear {
            UITableView.appearance().separatorStyle = .none
        }.onDisappear {
            UITableView.appearance().separatorStyle = .singleLine
        }
    }
    private func deleteRow(at indexSet: IndexSet) {
        self.list.remove(atOffsets: indexSet)
        self.deletedAt(indexSet)
    }
    private func move(from source: IndexSet, to destination: Int){
        self.list.move(fromOffsets: source, toOffset: destination)
        moved(source,destination)
    }
}
