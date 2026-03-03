//
//  Level1.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class Level1Scene: GameScene {
    private let examples: [(ColorPhenotype, ColorPhenotype, ColorPhenotype)] = [
        (.purple, .purple, .purple),
        (.purple, .white, .purple),
        (.purple, .purple, .white)
    ]
    private var currentExample = 0
    
    private var parent1Slime: SlimeNode!
    private var parent2Slime: SlimeNode!
    private var offspringSlime: SlimeNode!
    private var captionLabel: SKLabelNode!
    private var captionPlate: SKSpriteNode!
    private var crossSprite: SKSpriteNode!
    private var arrowSprite: SKSpriteNode!
    private var p1Card: SKSpriteNode!
    private var p2Card: SKSpriteNode!
    private var offCard: SKSpriteNode!
    private var p1Label: SKLabelNode!
    private var p2Label: SKLabelNode!
    private var offLabel: SKLabelNode!
    private var pageIndicator: SKLabelNode!
    private var nextButton: SKSpriteNode!
    private var nextButtonLabel: SKLabelNode!
    private var nextButtonArrow: SKSpriteNode!
    
    private var centerY: CGFloat { size.height / 2 }
    private var parent1X: CGFloat { size.width * 0.35 }
    private var parent2X: CGFloat { size.width * 0.50 }
    private var offspringX: CGFloat { size.width * 0.65 }
    private var slimeSize: CGFloat { min(120, size.width * 0.22) }
    private var symbolFontSize: CGFloat { slimeSize * 0.30 }
    
    override func didMove(to view: SKView) {
        removeAllChildren()
        super.didMove(to: view)
        setupStaticLabels()
        setupNextButton()
        showExample(index: 0, animated: false)
    }
    
    override func relayout() {
        let preservedNodes = children.filter { $0.name == "hintToken" }
        removeAllChildren()
        preservedNodes.forEach { addChild($0) }
        
        parent1Slime = nil
        parent2Slime = nil
        offspringSlime = nil
        captionLabel = nil
        captionPlate = nil
        nextButton = nil
        
        setupStaticLabels()
        setupNextButton()
        showExample(index: currentExample, animated: false)
    }
    
    private func setupStaticLabels() {
        let uiNodeNames = ["crossSprite", "arrowSprite", "captionPlate", "p1Card", "p2Card", "offCard", "pageIndicator"]
        for nodeName in uiNodeNames {
            enumerateChildNodes(withName: nodeName) { node, _ in
                node.removeFromParent()
            }
        }
        
        let crossTex = SKTexture(imageNamed: "cross")
        let crossRatio = crossTex.size().width / crossTex.size().height
        crossSprite = SKSpriteNode(texture: crossTex)
        crossSprite.name = "crossSprite"
        crossSprite.texture?.filteringMode = .nearest
        crossSprite.size = CGSize(width: symbolFontSize * crossRatio, height: symbolFontSize)
        crossSprite.position = CGPoint(x: (parent1X + parent2X) / 2, y: centerY)
        addChild(crossSprite)
        
        let arrowTex = SKTexture(imageNamed: "arrow")
        let arrowRatio = arrowTex.size().width / arrowTex.size().height
        arrowSprite = SKSpriteNode(texture: arrowTex)
        arrowSprite.name = "arrowSprite"
        arrowSprite.texture?.filteringMode = .nearest
        let arrowHeight = symbolFontSize * 0.75
        arrowSprite.size = CGSize(width: arrowHeight * arrowRatio, height: arrowHeight)
        arrowSprite.position = CGPoint(x: (parent2X + offspringX) / 2, y: centerY)
        addChild(arrowSprite)
        
        captionPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        captionPlate.name = "captionPlate"
        captionPlate.texture?.filteringMode = .nearest
        captionPlate.position = CGPoint(x: size.width / 2, y: centerY - size.height * 0.18)
        addChild(captionPlate)
        
        captionLabel = nil
        
        for (text, nodeName) in [("Parent 1", "p1"), ("Parent 2", "p2"), ("Offspring", "off")] {
            let tex = SKTexture(imageNamed: "genotype_card_purple")
            let ratio = tex.size().width / tex.size().height
            let cardHeight: CGFloat = 46
            let card = SKSpriteNode(texture: tex)
            card.name = "\(nodeName)Card"
            card.texture?.filteringMode = .nearest
            card.size = CGSize(width: cardHeight * ratio, height: cardHeight)
            
            let xPos = (nodeName == "p1") ? parent1X : (nodeName == "p2") ? parent2X : offspringX
            card.position = CGPoint(x: xPos, y: centerY + size.height * 0.11)
            addChild(card)
            
            let lbl = SKLabelNode(text: text)
            lbl.fontName = "AvenirNext-Bold"
            lbl.fontSize = 18
            lbl.verticalAlignmentMode = .center
            card.addChild(lbl)
            
            if nodeName == "p1" { p1Card = card; p1Label = lbl } else if nodeName == "p2" { p2Card = card; p2Label = lbl } else { offCard = card; offLabel = lbl }
        }
        
        pageIndicator = SKLabelNode(text: "Round 1 / 3")
        pageIndicator.name = "pageIndicator"
        pageIndicator.fontName = "AvenirNext-Bold"
        pageIndicator.fontSize = 14
        pageIndicator.fontColor = UIColor.systemGray
        pageIndicator.position = CGPoint(x: size.width / 2, y: size.height * 0.05)
        pageIndicator.verticalAlignmentMode = .center
        addChild(pageIndicator)
    }
    
    private func setupNextButton() {
        enumerateChildNodes(withName: "nextButton") { node, _ in
            node.removeFromParent()
        }
        
        let tex = SKTexture(imageNamed: "genotype_card_purple_thin")
        nextButton = SKSpriteNode(texture: tex)
        nextButton.name = "nextButton"
        nextButton.texture?.filteringMode = .nearest
        
        let ratio = tex.size().width / tex.size().height
        let btnHeight: CGFloat = 80
        nextButton.size = CGSize(width: btnHeight * ratio, height: btnHeight)
        
        nextButton.name = "nextButton"
        nextButton.position = CGPoint(x: size.width / 2, y: centerY - size.height * 0.30)
        
        let shadow = SKSpriteNode(texture: tex)
        shadow.color = .black
        shadow.colorBlendFactor = 1.0
        shadow.alpha = 0.3
        shadow.size = nextButton.size
        shadow.position = CGPoint(x: 0, y: -4)
        shadow.zPosition = -1
        nextButton.addChild(shadow)
        
        addChild(nextButton)
        
        nextButtonLabel = SKLabelNode(text: "Next")
        nextButtonLabel.fontName = "AvenirNext-Bold"
        nextButtonLabel.fontSize = 18
        nextButtonLabel.fontColor = .white
        nextButtonLabel.verticalAlignmentMode = .center
        nextButtonLabel.horizontalAlignmentMode = .center
        nextButtonLabel.position = CGPoint(x: -12, y: 0)
        nextButtonLabel.name = "nextButton"
        nextButton.addChild(nextButtonLabel)
        
        let arrowTex = SKTexture(imageNamed: "arrow")
        nextButtonArrow = SKSpriteNode(texture: arrowTex)
        nextButtonArrow.texture?.filteringMode = .nearest
        let arrowHeight: CGFloat = 14
        let arrowRatio = arrowTex.size().width / arrowTex.size().height
        nextButtonArrow.size = CGSize(width: arrowHeight * arrowRatio, height: arrowHeight)
        nextButtonArrow.position = CGPoint(x: 55, y: -1)
        nextButtonArrow.name = "nextButton"
        nextButton.addChild(nextButtonArrow)
        
        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 0.95, duration: 0.8)
        ])
        nextButton.run(SKAction.repeatForever(breathe))
    }
    
    private func showExample(index: Int, animated: Bool) {
        let (p1Color, p2Color, offColor) = examples[index]
        
        parent1Slime?.removeFromParent()
        parent2Slime?.removeFromParent()
        offspringSlime?.removeFromParent()
        
        parent1Slime  = SlimeNode(color: p1Color, size: slimeSize, isAnimated: false)
        parent2Slime  = SlimeNode(color: p2Color, size: slimeSize, isAnimated: false)
        offspringSlime = SlimeNode(color: offColor, size: slimeSize * 0.8, isAnimated: false)
        
        parent1Slime.position  = CGPoint(x: parent1X, y: centerY)
        parent2Slime.position  = CGPoint(x: parent2X, y: centerY)
        offspringSlime.position = CGPoint(x: offspringX, y: centerY)
        
        if animated {
            for node in [parent1Slime!, parent2Slime!, offspringSlime!] {
                node.alpha = 0
                node.setScale(0.5)
                addChild(node)
                node.run(SKAction.group([
                    SKAction.fadeIn(withDuration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3)
                ]))
            }
        } else {
            addChild(parent1Slime)
            addChild(parent2Slime)
            addChild(offspringSlime)
        }
        
        let cards = [(p1Card, p1Label, p1Color), (p2Card, p2Label, p2Color), (offCard, offLabel, offColor)]
        for (card, label, color) in cards {
            let texName = "genotype_card_\(color.rawValue)"
            card?.texture = SKTexture(imageNamed: texName)
            card?.texture?.filteringMode = .nearest
            label?.text = color.rawValue.capitalized
            label?.fontColor = (color == .purple) ? .white : .black
        }
        
        let captions = [
            "Both parents are Purple — the offspring is Purple too.",
            "One Purple parent is enough — offspring is still Purple!",
            "Wait… two Purple parents made a White offspring?! How?!"
        ]
        
        let labelWidth = min(size.width * 0.9, 750)
        let labelHeight: CGFloat = (captions[index].count > 40) ? 120 : 95
        captionPlate.size = CGSize(width: labelWidth, height: labelHeight)
        
        captionPlate.enumerateChildNodes(withName: "captionLabel") { node, _ in
            node.removeFromParent()
        }
        captionLabel?.removeFromParent()
        
        let newLabel = SKLabelNode(text: captions[index])
        newLabel.name = "captionLabel"
        newLabel.fontName = "AvenirNext-Medium"
        newLabel.fontSize = 20
        newLabel.fontColor = .black
        newLabel.position = .zero
        newLabel.verticalAlignmentMode = .center
        newLabel.horizontalAlignmentMode = .center
        newLabel.preferredMaxLayoutWidth = size.width * 0.7
        newLabel.numberOfLines = 0
        newLabel.zPosition = 1
        
        captionPlate.addChild(newLabel)
        captionLabel = newLabel
        
        pageIndicator.text = "Round \(index + 1) / 3"
        
        if index == examples.count - 1 {
            nextButtonLabel.text = "Next"
            nextButton.texture = SKTexture(imageNamed: "genotype_card_purple_thin")
            nextButtonLabel.fontColor = .white
            nextButtonArrow.color = .white
            nextButtonArrow.colorBlendFactor = 1.0
            nextButtonLabel.position = CGPoint(x: -15, y: 0)
            nextButtonArrow.position = CGPoint(x: 35, y: -1)
        } else {
            nextButtonLabel.text = "Next"
            nextButton.texture = SKTexture(imageNamed: "genotype_card_purple_thin")
            nextButtonLabel.fontColor = .white
            nextButtonArrow.color = .white
            nextButtonArrow.colorBlendFactor = 1.0
            nextButtonLabel.position = CGPoint(x: -15, y: 0)
            nextButtonArrow.position = CGPoint(x: 35, y: -1)
        }
        nextButton.texture?.filteringMode = .nearest
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)
        
        if hit.name == "nextButton" {
            if currentExample < examples.count - 1 {
                currentExample += 1
                showExample(index: currentExample, animated: true)
            } else {
                completeLevel()
            }
        }
    }
}
