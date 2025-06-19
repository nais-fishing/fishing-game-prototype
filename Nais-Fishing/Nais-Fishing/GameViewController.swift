//
//  GameViewController.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 18/06/25.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cast view sebagai SKView
        if let skView = self.view as? SKView {
            
            // Buat scene dengan ukuran sama dengan view
            let scene = FishingScene(size: skView.bounds.size)
            
            // Set scale mode
            scene.scaleMode = .aspectFill
            
            // Present scene ke view
            skView.presentScene(scene)
            
            // Setting untuk development/debugging
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true           // Tampilkan FPS counter
            skView.showsNodeCount = true     // Tampilkan jumlah node
            
            print("🎮 GameViewController: Scene loaded successfully!")
        } else {
            print("❌ Error: View is not SKView!")
        }
    }

    // MARK: - Orientation Support
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown  // iPhone: semua kecuali terbalik
        } else {
            return .all              // iPad: semua orientasi
        }
    }

    // MARK: - Status Bar
    override var prefersStatusBarHidden: Bool {
        return true  // Sembunyikan status bar untuk full-screen game
    }
}
