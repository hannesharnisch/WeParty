//
//  ConnectingView.swift
//  WeParty
//
//  Created by Hannes Harnisch on 25.04.20.
//  Copyright © 2020 hannes.harnisch. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity

struct ConnectingView<T:ConnectivityEnabled>: View {
    @Binding var discoveredPeers:[MCPeerID]
    @Binding var connectedPeers:[MCPeerID]
    @Binding var isServer:Bool
    @Binding var currentHost:MCPeerID?
    var connectivity:T?
    var body: some View {
        ZStack(alignment: .bottom){
        ScrollView(.vertical){
            Divider()
            VStack(alignment: .leading){
            HStack{
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                Text("\(NSLocalizedString("searchingFor", comment:"searching for text")) \(self.isServer ? NSLocalizedString("people", comment:"people word") : NSLocalizedString("PartyHost", comment:"PartyHost word"))").font(.headline)
            }.padding(.horizontal).padding(.bottom, 4).padding(.top)
            HStack{
                Text("\(NSLocalizedString("me", comment:"me word")): ")
                Spacer()
                Text("\(UIDevice.current.name)")
            }.padding()
            Divider()
            if self.connectedPeers.count != 0 && !self.isServer{
                Text("Partyhost:").font(.caption).padding(.horizontal)
                Text("\(self.currentHost?.displayName  ?? "")").padding()
                Divider()
            }
            if self.connectedPeers.count != 0{
                Text("\(NSLocalizedString("connected", comment:"connected word")) \(NSLocalizedString("people", comment:"people word"))").font(.caption).padding(.horizontal)
                ForEach(self.connectedPeers, id:\.self){ peer in
                    VStack(alignment:.leading){
                        Divider()
                        HStack{
                            Text(peer.displayName.split(separator: "-")[0]).padding(.horizontal)
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
                    Text("\(NSLocalizedString("discovered", comment:"discovered word")) \(NSLocalizedString("PartyHosts", comment:"PartyHosts word"))").font(.caption).padding(.horizontal)
                    ForEach(self.discoveredPeers, id:\.self){ peer in
                        VStack(alignment:.leading){
                            Divider()
                            HStack{
                                Text(peer.displayName.split(separator: "-")[0])
                                Spacer()
                                    Button(action:{
                                        self.connectivity?.connectTo(peer: peer)
                                    }){
                                        Text(NSLocalizedString("connect", comment:"connect word"))
                                    }.disabled(self.connectedPeers.count != 0)
                            }.padding()
                        }
                    }
                    }
                }
            }
        }
            Button(action: {
                self.connectivity?.reset()
            }){
                if self.isServer{
                    Text("Reset").padding().foregroundColor(.red)
                }else{
                    Text("Disconnect").padding().foregroundColor(.red)
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
