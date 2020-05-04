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
    var deleted:(S) -> ()
    var moved:(IndexSet,Int) -> ()
    init(deleteOption:Binding<Bool>,deleted:@escaping(S) -> (),moved:@escaping(IndexSet,Int) -> (),list:Binding<[S]>,content: @escaping (S) -> T){
        self.deleted = deleted
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
                    }.onDelete(perform: deleteRow(at:))
                //.onMove(perform: move)
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
        for index in indexSet{
            self.deleted(self.list[index])
        }
        self.list.remove(atOffsets: indexSet)
    }
    private func move(from source: IndexSet, to destination: Int){
        self.list.move(fromOffsets: source, toOffset: destination)
        moved(source,destination)
    }
}
