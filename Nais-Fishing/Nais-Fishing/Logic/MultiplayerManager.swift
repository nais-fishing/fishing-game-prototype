//
//  MultiplayerManager.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 25/06/25.
//

import Foundation
import MultipeerConnectivity

struct GameMessage: Codable {
    let type: String
    let value: String?
}

//protokol untuk memberi tahu class lain seperti FishingScene saat skor pemain lain diterima.
protocol MultiplayerManagerDelegate: AnyObject {
    func playerScoreUpdated(peerID: MCPeerID, newScore: Int)
    func gameDidStart()
}

class MultiplayerManager: NSObject, ObservableObject {
//  nama unik untuk membedakan dari aplikasi lain yang juga memakai MultipeerConnectivity.
    private let serviceType = "nais-fishing"
    
//  identitas perangkat ini dalam jaringan peer.
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
//  objek utama yang mengatur komunikasi dengan peer lain.
    private var session: MCSession
    
//  digunakan saat menjadi host
    private var advertiser: MCNearbyServiceAdvertiser?

//  digunakan saat kita mencari host untuk join.
    private var browser: MCNearbyServiceBrowser?
    
    weak var delegate: MultiplayerManagerDelegate?
  
//  MCSession untuk mengelola koneksi dan data antar peer.
//  encryptionPreference: .required berarti semua data terenkripsi.
    override init() {
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }
    
//  startHosting(): membuat perangkat kita terlihat oleh peer lain.
    func startHosting() {
        stopBrowsing()
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        print("🔵 Hosting started")
    }
    
    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        print("🔴 Hosting stopped")
    }

//  startBrowsing(): mulai mencari host untuk di-invite.
    func startBrowsing() {
        stopHosting()
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        print("🟢 Browsing started")
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        print("🔴 Browsing stopped")
    }
    
    func disconnect() {
        session.disconnect()
        stopHosting()
        stopBrowsing()
        print("🔌 Disconnected session")
    }
    
    func sendScoreUpdate(score: Int) {
        let message = GameMessage(type: "scoreUpdate", value: "\(score)")
        if let data = try? JSONEncoder().encode(message) {
            sendData(data)
        }
    }
    
    func sendData(_ data: Data) {
        guard !session.connectedPeers.isEmpty else {
            print("⚠️ No peers connected. Data not sent.")
            return
        }

        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("📤 Data sent to peers")
        } catch {
            print("❌ Failed to send data: \(error)")
        }
    }

}

extension MultiplayerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("🔄 Peer \(peerID.displayName) changed state: \(state.rawValue)")
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = try? JSONDecoder().decode(GameMessage.self, from: data) {
            if message.type == "gameStart" {
                DispatchQueue.main.async {
                    self.delegate?.gameDidStart()
                }
            } else if message.type == "scoreUpdate", let value = message.value, let score = Int(value) {
                DispatchQueue.main.async {
                    self.delegate?.playerScoreUpdated(peerID: peerID, newScore: score)
                }
            }
        }
    }

    func session(_: MCSession, didReceive _: InputStream, withName _: String, fromPeer _: MCPeerID) {}
    func session(_: MCSession, didStartReceivingResourceWithName _: String, fromPeer _: MCPeerID, with _: Progress) {}
    func session(_: MCSession, didFinishReceivingResourceWithName _: String, fromPeer _: MCPeerID, at _: URL?, withError _: Error?) {}
}

// Saat ada pemain join, undangan otomatis diterima (invitationHandler(true, session)).
extension MultiplayerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("📥 Received invitation from: \(peerID.displayName)")
        invitationHandler(true, session)
    }
}

//foundPeer: saat browser menemukan host, langsung kirim undangan untuk gabung.
extension MultiplayerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String: String]?) {
        print("👀 Found peer: \(peerID.displayName)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

//lostPeer: logika opsional saat peer hilang dari radar.
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("❌ Lost peer: \(peerID.displayName)")
    }
}
