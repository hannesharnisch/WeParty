//
//  SearchBar.swift
//  WeParty
//
//  Created by Hannes Harnisch on 18.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var textDidChange:(String) -> ()
    
    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String
        var textDidChange:(String) -> ()
        
        init(text: Binding<String>,textDidChange:@escaping (String) -> ()) {
            _text = text
            self.textDidChange = textDidChange
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            //self.textDidChange(searchText)
        }
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            self.textDidChange(self.text)
            searchBar.resignFirstResponder()
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, textDidChange: textDidChange)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
