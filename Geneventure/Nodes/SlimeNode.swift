//
//  SlimeNode.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class SlimeNode: SKNode {
    var colorPhenotype: ColorPhenotype {
        didSet { updateSprite() }
    }
    var shapePhenotype: ShapePhenotype {
        didSet { updateSprite() }
    }
    
    private var sprite: SKSpriteNode!
    
    private let targetSize: CGFloat
    
    init(color: ColorPhenotype, shape: ShapePhenotype = .round, size: CGFloat = 60, isAnimated: Bool = true) {
        self.colorPhenotype = color
        self.shapePhenotype = shape
        self.targetSize = size
        super.init()
        
        setupSprite()
        if isAnimated {
            startIdleAnimation()
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("Not Implemented") }
    
    private func setupSprite() {
        let imageName = imageNameFor(color: colorPhenotype, shape: shapePhenotype)
        sprite = SKSpriteNode(imageNamed: imageName)
        sprite.texture?.filteringMode = .nearest
        sprite.size = CGSize(width: targetSize, height: targetSize)
        
        let eyeSize = shapePhenotype == .spiky
            ? CGSize(width: sprite.size.width * 0.28, height: sprite.size.height * 0.28)
            : CGSize(width: sprite.size.width * 0.4, height: sprite.size.height * 0.4)
        let eyeYOffset = shapePhenotype == .spiky
            ? sprite.size.height * -0.12
            : sprite.size.height * 0.2
        let eyeXOffset = sprite.size.width * 0.18
        
        let leftEye = SKSpriteNode(imageNamed: "eye")
        leftEye.texture?.filteringMode = .nearest
        leftEye.size = eyeSize
        leftEye.position = CGPoint(x: -eyeXOffset, y: eyeYOffset)
        leftEye.zPosition = 1
        
        let rightEye = SKSpriteNode(imageNamed: "eye")
        rightEye.texture?.filteringMode = .nearest
        rightEye.size = eyeSize
        rightEye.position = CGPoint(x: eyeXOffset, y: eyeYOffset)
        rightEye.zPosition = 1
        
        sprite.addChild(leftEye)
        sprite.addChild(rightEye)
        addChild(sprite)
    }
    
    private func updateSprite() {
        guard sprite != nil else { return }
        
        let imageName = imageNameFor(color: colorPhenotype, shape: shapePhenotype)
        sprite.texture = SKTexture(imageNamed: imageName)
 
        sprite.texture?.filteringMode = .nearest
    }
    
    private func imageNameFor(color: ColorPhenotype, shape: ShapePhenotype) -> String {
        switch (color, shape) {
        case (.purple, .round): return "slime_purple"
        case (.purple, .spiky): return "slime_purple_spiky"
        case (.white, .round): return "slime_white"
        case (.white, .spiky): return "slime_white_spiky"
        }
    }
    
    private func startIdleAnimation() {
        let scaleUp = SKAction.scale(to: 1.08, duration: 0.6)
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.6)
        let wobble = SKAction.sequence([scaleUp, scaleDown])
        run(SKAction.repeatForever(wobble))
    }
    
    func playCorrectAnimation(completion: (() -> Void)? = nil) {
        let jump = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 0.15),
            SKAction.moveBy(x: 0, y: -20, duration: 0.15)
        ])
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        run(SKAction.group([jump, flash])) { completion?() }
    }
    
    func playWrongAnimation(completion: (() -> Void)? = nil) {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -8, y: 0, duration: 0.05),
            SKAction.moveBy(x: 8, y: 0, duration: 0.05),
            SKAction.moveBy(x: -8, y: 0, duration: 0.05),
            SKAction.moveBy(x: 8, y: 0, duration: 0.05)
        ])
        run(shake) { completion?() }
    }
}
