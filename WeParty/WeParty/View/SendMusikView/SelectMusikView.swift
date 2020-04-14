//
//  SelectMusikView.swift
//  PartyCollaborate2
//
//  Created by Hannes Harnisch on 29.03.20.
//  Copyright © 2020 Hannes Harnisch. All rights reserved.
//

import SwiftUI
import MediaPlayer

struct SelectMusikView<T:MPMediaPickerControllerDelegate>: UIViewControllerRepresentable {
    var connectivity:T?
    @Binding var shown:Bool
    init(connectivity:T?,shown:Binding<Bool>){
        self._shown = shown
        self.connectivity = connectivity
    }
    func makeUIViewController(context: Context) -> UIViewController {
        
        let controller = MPMediaPickerController(mediaTypes: .music)
        controller.delegate = connectivity!
        controller.prompt = "Pick a song to Send"
        controller.showsCloudItems = true
        controller.allowsPickingMultipleItems = true
        return controller
    }
    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        
    }
}
