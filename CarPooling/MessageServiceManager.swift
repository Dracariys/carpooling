//
//  MessageServiceManager.swift
//  
// a library to connect iPhone/AppleTV/MacOS
//
//  Created by Francesco M. Sacerdoti on 27/03/17.
//  Copyright © 2017 fms. All rights reserved.
//

import Foundation
import MultipeerConnectivity

//
// protocol
// 1) connectedDevicesChanged is called when a new device is connecting or a device exit from the connection
// 2) messageReceived is called when a new message is received
//
protocol MessageServiceManagerDelegate  {
    func connectedDevicesChanged(manager : MessageServiceManager, connectedDevices: [String])
    func messageReceived(manager : MessageServiceManager, message: String)
}

#if os(iOS) || os(watchOS) || os(tvOS)
    let myPeerName = UIDevice.current.name
#elseif os(OSX)
    let myPeerName = Host.current().localizedName ?? ""
#endif

//
//
//
class MessageServiceManager : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    //
    var messageServiceType = "MultiPeers"//Bundle.main.infoDictionary?["CFBundleName"] as! String
    let myPeerId = MCPeerID(displayName: myPeerName)
    var maxConnection = 1
    var isHost : Bool
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?
    
    var delegate : MessageServiceManagerDelegate?

    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    var peerNames: [String] {
        return session.connectedPeers.map{$0.displayName}
    }
    
    var userCount : Int {
        return session.connectedPeers.count 
    }
    /*
    init(serviceName: String , hosting : Bool) {
        if hosting {
            self.messageServiceType = serviceName
            self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: messageServiceType)
            self.isHost=true
            super.init()
            serviceBrowser?.delegate = self
            serviceBrowser?.startBrowsingForPeers()
        }
        else{
            self.messageServiceType = serviceName
            self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: messageServiceType)
            self.isHost=false
            super.init()
            
            serviceAdvertiser?.delegate = self
            serviceAdvertiser?.startAdvertisingPeer()
        }
    }
    */
    init(serviceName: String , hosting : Bool) {
        self.messageServiceType = serviceName
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: messageServiceType)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: messageServiceType)
        self.isHost=hosting
        super.init()
        serviceBrowser?.delegate = self
        serviceBrowser?.startBrowsingForPeers()
        serviceAdvertiser?.delegate = self
        serviceAdvertiser?.startAdvertisingPeer()
    }
    
    func stopAdvAndBrow(){
        serviceBrowser?.stopBrowsingForPeers()
        serviceAdvertiser?.stopAdvertisingPeer()
    }
    
    init(serviceName: String) {
            self.messageServiceType = serviceName
            self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: messageServiceType)
            self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: messageServiceType)
            self.isHost=true
            super.init()
            serviceBrowser?.delegate = self
            serviceBrowser?.startBrowsingForPeers()
            serviceAdvertiser?.delegate = self
            serviceAdvertiser?.startAdvertisingPeer()
    }

    func send(data: Data, toPeerNo peerNo: Int)-> Bool{
        let peers = session.connectedPeers
        if (peers.count > peerNo){
            let peer = [session.connectedPeers[peerNo]]
            do {
                try self.session.send(data, toPeers: peer, with: .reliable)
                return true
            }
            catch let error {
                print("Error \(error) sending to peer \(peerNo)")
            }
        }
        return false
    }
    
    func send(message: String, toPeerNo peerNo: Int)-> Bool{
        return send(data: message.data(using: .utf8)!, toPeerNo: peerNo)
    }
    
    func send(data: Data, toPeers peerNames: [String]) -> Bool{
        let peers = session.connectedPeers.filter {
            return peerNames.contains($0.displayName)
        }
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(data, toPeers: peers, with: .reliable)
                return true
            }
            catch let error {
                print("Error for sending: \(error)")
            }
        }
        return false
    }
    
    func send(message: String, toPeers: [String]) -> Bool {
        return send(data: message.data(using: .utf8)!, toPeers: toPeers)
    }
    
    
    func sendToAll(data : Data){
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                print("Error for sending: \(error)")
            }
        }
        
    }
    func sendToAll(message : String){
        sendToAll(data: message.data(using: .utf8)!)
    }
    
    deinit {
        self.serviceAdvertiser?.stopAdvertisingPeer()
        self.serviceBrowser?.stopBrowsingForPeers()
    }
    
}

extension MessageServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension MessageServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if peerID.displayName != self.myPeerId.displayName {
            print(peerID,myPeerId)
        print("foundPeer: \(peerID)")
        print("invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if peerID.displayName != self.myPeerId.displayName {
        print("lostPeer: \(peerID)")
        }
    }
    
}


extension MessageServiceManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.messageReceived(manager: self, message: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }
    
}
