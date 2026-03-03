//
//  GameScene.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit
import SwiftUI

class GameScene: SKScene {
    var levelData: LevelData!
    var onLevelComplete: (() -> Void)?
    var onShowHint: ((HintType) -> Void)?
    var onWrongAnswer: ((String) -> Void)?
    
    private var hintToken: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupHintToken()
    }

    func relayout() {}

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, size.height > 0, oldSize != size else { return }
        hintToken?.position = CGPoint(x: size.width - 50, y: 60)
        relayout()
    }
    
    private func setupHintToken() {
        let tex = SKTexture(imageNamed: "slot_current")
        let token = SKSpriteNode(texture: tex)
        token.texture?.filteringMode = .nearest
        token.size = CGSize(width: 50, height: 50)
        token.name = "hintToken"
        
        let lbl = SKLabelNode(text: "?")
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = 28
        lbl.fontColor = .black
        lbl.verticalAlignmentMode = .center
        lbl.name = "hintToken"
        token.addChild(lbl)
        
        token.position = CGPoint(x: size.width - 50, y: 60)
        addChild(token)
        hintToken = token
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)
        
        if hit == hintToken || hit.parent == hintToken {
            triggerHint()
        }
    }
    
    private func triggerHint() {
        guard let hint = levelData?.hints.first else { return }
        onShowHint?(hint)
    }
    
    func completeLevel() {
        playLevelCompleteSound()
        GameState.shared.markCompleted(levelData.id)
        run(SKAction.wait(forDuration: 1.0)) { [weak self] in
            self?.onLevelComplete?()
        }
    }
    
    func showWrongAnswer(explanation: String) {
        playWrongSound()
        onWrongAnswer?(explanation)
    }

    func playCorrectSound() {
        AudioManager.shared.playSFX("correct")
    }

    func playWrongSound() {
        AudioManager.shared.playSFX("wrong")
    }

    func playLevelCompleteSound() {
        AudioManager.shared.playSFX("level_complete")
    }

    func playSlimeSound() {
        AudioManager.shared.playSFX("slime")
    }
}
