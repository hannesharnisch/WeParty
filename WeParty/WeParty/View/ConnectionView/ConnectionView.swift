//
//  ConnectionView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 13.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity

struct ConnectionView: View {
    @EnvironmentObject var state:WePartyState
    var model:WePartyConnection?
    @State var wasIsServerSet = false
    var body: some View {
        NavigationView{
            VStack{
                if !wasIsServerSet{
                    AskingView(wasIsServerSet: $wasIsServerSet, isServer: self.$state.isServer, onSelected: {
                        self.model?.start(isServer: self.state.isServer)
                    })
                }else{
                    ConnectingView(discoveredPeers: self.$state.discoveredPeers, connectedPeers: self.$state.connectedPeers, isServer: self.$state.isServer, currentHost: self.$state.currentHost,connectivity: model)
                }
            }.navigationBarTitle(Text("Connection \(wasIsServerSet ? self.state.isServer ? "Partyhost" : "Join" : "")"))
        }
    }
}
//<T:ConnectivityEnabled>
struct ConnectingView<T:ConnectivityEnabled>: View {
    @Binding var discoveredPeers:[MCPeerID]
    @Binding var connectedPeers:[MCPeerID]
    @Binding var isServer:Bool
    @Binding var currentHost:MCPeerID?
    var connectivity:T?
    var body: some View {
        ScrollView(.vertical){
            Divider()
            VStack(alignment: .leading){
            HStack{
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                Text("Searching for \(self.isServer ? "People" : "Party-hosts")").font(.headline)
            }.padding(.horizontal).padding(.bottom, 4).padding(.top)
            HStack{
                Text("Me: ")
                Spacer()
                Text("\(UIDevice.current.name)")
            }.padding()
            Divider()
            if self.connectedPeers.count != 0 && !self.isServer{
                Text("Partyhost:").font(.caption).padding(.horizontal)
                Text("\(self.currentHost?.displayName ?? "")").padding()
                Divider()
            }
            if self.connectedPeers.count != 0{
                Text("Connected People").font(.caption).padding(.horizontal)
                ForEach(self.connectedPeers, id:\.self){ peer in
                    VStack(alignment:.leading){
                        Divider()
                        HStack{
                            Text(peer.displayName).padding(.horizontal)
                            Spacer()
                            if self.isServer{
                                Button(action:{
                                    self.connectivity?.disconnectPeer(peer: peer)
                                }){
                                    Image(systemName: "xmark.circle").foregroundColor(.red)
                                }
                            }
                        }.padding()
                    }
                }
            }
                if self.discoveredPeers.count != 0{
                if !self.isServer{
                    Divider()
                    Text("Discovered \(self.isServer ? "People" : "Party-hosts")").font(.caption).padding(.horizontal)
                    ForEach(self.discoveredPeers, id:\.self){ peer in
                        VStack(alignment:.leading){
                            Divider()
                            HStack{
                                Text(peer.displayName)
                                Spacer()
                                    Button(action:{
                                        self.connectivity?.connectTo(peer: peer)
                                    }){
                                        Text("Connect")
                                    }.disabled(self.connectedPeers.count != 0)
                            }.padding()
                        }
                    }
                    }
                }
            }
        }
    }
}
protocol ConnectivityEnabled {
    func start(isServer:Bool)
    func stop(isServer:Bool)
    func connectTo(peer:MCPeerID)
    func connection(accept:Bool,peer:MCPeerID)
    func reset()
    func disconnectPeer(peer:MCPeerID)
}
struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

