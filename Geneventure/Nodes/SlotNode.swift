//
//  SlotNode.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class SlotNode: SKNode {
    private var background: SKSpriteNode!
    private var titleLabel: SKLabelNode!
    private var slimePreview: SlimeNode?
    private(set) var placedGenotype: Genotype?
    private let originalLabel: String
    private let boxSize: CGFloat

    init(label: String, size: CGFloat = 120) {
        self.originalLabel = label
        self.boxSize = size
        super.init()
        background = SKSpriteNode(imageNamed: "slot_empty")
        background.texture?.filteringMode = .nearest
        background.size = CGSize(width: boxSize, height: boxSize)
        background.color = .clear
        background.colorBlendFactor = 0.0
        addChild(background)

        titleLabel = SKLabelNode(text: label)
        titleLabel.fontName = "AvenirNext-Medium"
        titleLabel.fontSize = 12
        titleLabel.fontColor = .gray
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: -(size / 2) - 14)
        addChild(titleLabel)
    }

    required init?(coder: NSCoder) { fatalError("Error Encountered!") }

    func highlight(_ on: Bool) {
        background.color = on ? .yellow : .clear
        background.colorBlendFactor = on ? 0.3 : 0.0
    }

    func place(genotype: Genotype) {
        AudioManager.shared.playSFX("slime")
        placedGenotype = genotype
        slimePreview?.removeFromParent()

        let slime = SlimeNode(color: ColorPhenotype.from(genotype), size: boxSize * 0.75, isAnimated: false)
        slime.zPosition = 1
        addChild(slime)
        slimePreview = slime

        titleLabel.text = genotype.displayName
        titleLabel.fontName = "AvenirNext-Black"
        titleLabel.fontSize = 16
        titleLabel.fontColor = .black
    }

    func clear() {
        placedGenotype = nil
        slimePreview?.removeFromParent()
        slimePreview = nil
        background.colorBlendFactor = 0.0
        background.color = .clear

        titleLabel.text = originalLabel
        titleLabel.fontName = "AvenirNext-Medium"
        titleLabel.fontSize = 12
        titleLabel.fontColor = .gray
    }

    func flash(correct: Bool) {
        let flashColor: UIColor = correct ? UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0) : UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)

        let action = SKAction.sequence([
            SKAction.run {
                self.background.color = flashColor
                self.background.colorBlendFactor = 0.5
            },
            SKAction.wait(forDuration: 0.3),
            SKAction.run {
                self.background.colorBlendFactor = 0.0
                self.background.color = .clear
            }
        ])
        background.run(action)
    }
}
