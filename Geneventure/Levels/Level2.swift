//
//  Level2.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class Level2Scene: GameScene {
    private let rounds: [(Genotype, Genotype)] = [
        (.BB, .BB),
        (.BB, .Bb),
        (.Bb, .bb),
        (.bb, .bb)
    ]
    private var currentRound = 0
    
    private var parent1Slime: SlimeNode!
    private var parent2Slime: SlimeNode!
    private var choiceSlimes: [SlimeNode] = []
    private var dropZone: SKSpriteNode!
    private var dropZoneLabel: SKLabelNode!
    private var instructionLabel: SKLabelNode!
    private var instructionPlate: SKSpriteNode!
    private var roundLabel: SKLabelNode!
    private var crossSprite: SKSpriteNode!
    
    private var draggingSlime: SlimeNode?
    private var dragOrigin: CGPoint = .zero
    
    private var isCompact: Bool { size.width < 500 }
    private var navbarHeight: CGFloat { isCompact ? 110 : 90 }
    private var centerX: CGFloat { size.width / 2 }
    private var contentWidth: CGFloat { min(size.width - 40, 500) }

    private var parentSize: CGFloat { min(isCompact ? 75 : 100, contentWidth * 0.20) }
    private var parentGap: CGFloat { contentWidth * 0.20 }
    private var choiceSize: CGFloat { min(isCompact ? 80 : 120, contentWidth * 0.22) }
    private var choiceSpacing: CGFloat { contentWidth * 0.42 }
    private var plateWidth: CGFloat { min(contentWidth, 700) }

    private var usableTop: CGFloat { size.height - navbarHeight }
    private var usableHeight: CGFloat { size.height - navbarHeight - 30 }

    private var rowInstruct: CGFloat { usableTop - usableHeight * 0.12 }
    private var rowParents: CGFloat { usableTop - usableHeight * 0.35 }
    private var rowDrop: CGFloat { usableTop - usableHeight * 0.57 }
    private var rowChoices: CGFloat { usableTop - usableHeight * 0.79 }
    private var rowLabel: CGFloat { usableTop - usableHeight * 0.97 }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        resetState()
        setupStaticUI()
        loadRound(animated: false)
    }

    override func relayout() {
        resetState()
        setupStaticUI()
        loadRound(animated: false)
    }

    private func resetState() {
        let hint = childNode(withName: "hintToken")
        hint?.removeFromParent()
        removeAllChildren()
        if let hint = hint { addChild(hint) }
        
        currentRound = 0
        parent1Slime = nil
        parent2Slime = nil
        choiceSlimes.removeAll()
        draggingSlime = nil
    }
    
    private func setupStaticUI() {
        let names = ["instructionPlate", "crossSprite", "dropZone", "dropZoneLabel", "roundLabel"]
        for name in names { enumerateChildNodes(withName: name) { node, _ in node.removeFromParent() } }

        instructionPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        instructionPlate.name = "instructionPlate"
        instructionPlate.texture?.filteringMode = .nearest
        instructionPlate.position = CGPoint(x: centerX, y: rowInstruct)
        instructionPlate.size = CGSize(width: plateWidth, height: 110)
        addChild(instructionPlate)

        instructionLabel = SKLabelNode(text: "Drag the correct offspring Slime into the zone!")
        instructionLabel.fontName = "AvenirNext-Medium"
        instructionLabel.fontSize = isCompact ? 16 : 20
        instructionLabel.fontColor = .black
        instructionLabel.position = .zero
        instructionLabel.verticalAlignmentMode = .center
        instructionLabel.horizontalAlignmentMode = .center
        instructionLabel.preferredMaxLayoutWidth = plateWidth * 0.80
        instructionLabel.numberOfLines = 2
        instructionLabel.zPosition = 1
        instructionPlate.addChild(instructionLabel)

        let crossTex = SKTexture(imageNamed: "cross")
        let crossRatio = crossTex.size().width / crossTex.size().height
        let crossHeight: CGFloat = min(45, size.width * 0.12)
        crossSprite = SKSpriteNode(texture: crossTex)
        crossSprite.name = "crossSprite"
        crossSprite.texture?.filteringMode = .nearest
        crossSprite.size = CGSize(width: crossHeight * crossRatio, height: crossHeight)
        crossSprite.position = CGPoint(x: centerX, y: rowParents)
        addChild(crossSprite)

        let dzSize: CGFloat = min(110, size.width * 0.28)
        dropZone = SKSpriteNode(imageNamed: "slot_empty")
        dropZone.texture?.filteringMode = .nearest
        dropZone.size = CGSize(width: dzSize, height: dzSize)
        dropZone.name = "dropZone"
        dropZone.position = CGPoint(x: centerX, y: rowDrop)
        addChild(dropZone)

        dropZoneLabel = SKLabelNode(text: "Drop here")
        dropZoneLabel.name = "dropZoneLabel"
        dropZoneLabel.fontName = "AvenirNext-Bold"
        dropZoneLabel.fontSize = 16
        dropZoneLabel.fontColor = .darkGray
        dropZoneLabel.verticalAlignmentMode = .center
        dropZoneLabel.position = CGPoint(x: centerX, y: rowDrop - dzSize * 0.62)
        addChild(dropZoneLabel)

        roundLabel = SKLabelNode(text: "Round 1 / 4")
        roundLabel.name = "roundLabel"
        roundLabel.fontName = "AvenirNext-Bold"
        roundLabel.fontSize = 14
        roundLabel.fontColor = UIColor.systemGray
        roundLabel.position = CGPoint(x: centerX, y: rowLabel)
        roundLabel.verticalAlignmentMode = .center
        addChild(roundLabel)
    }
    
    private func loadRound(animated: Bool) {
        parent1Slime?.removeFromParent()
        parent2Slime?.removeFromParent()
        choiceSlimes.forEach { $0.removeFromParent() }
        choiceSlimes.removeAll()
        enumerateChildNodes(withName: "choicePurple") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "choiceWhite") { node, _ in node.removeFromParent() }

        dropZoneLabel?.isHidden = false
        dropZone?.texture = SKTexture(imageNamed: "slot_empty")
        dropZone?.texture?.filteringMode = .nearest
        
        let (g1, g2) = rounds[currentRound]
        roundLabel?.text = "Round \(currentRound + 1) / 4"
        
        let ps = parentSize
        let gap = parentGap
        parent1Slime = SlimeNode(color: ColorPhenotype.from(g1), size: ps, isAnimated: false)
        parent1Slime.position = CGPoint(x: centerX - gap, y: rowParents)
        parent1Slime.name = "parent1"
        addNameplate(to: parent1Slime, isTop: true)
        parent2Slime = SlimeNode(color: ColorPhenotype.from(g2), size: ps, isAnimated: false)
        parent2Slime.position = CGPoint(x: centerX + gap, y: rowParents)
        parent2Slime.name = "parent2"
        addNameplate(to: parent2Slime, isTop: true)

        let offspring = monohybridCross(g1, g2)
        let hasAnyDominant = offspring.contains { $0.isDominant }
        let hasAnyRecessive = offspring.contains { !$0.isDominant }

        var choices: [ColorPhenotype] = []
        if hasAnyDominant && hasAnyRecessive {
            choices = [.purple, .white].shuffled()
        } else if hasAnyDominant {
            choices = [.purple, .white]
        } else {
            choices = [.white, .purple]
        }

        let cs = choiceSize
        let spacing = choiceSpacing
        let startX = centerX - spacing / 2
        for (i, color) in choices.enumerated() {
            let slime = SlimeNode(color: color, size: cs, isAnimated: true)
            slime.position = CGPoint(x: startX + CGFloat(i) * spacing, y: rowChoices)
            slime.name = color == .purple ? "choicePurple" : "choiceWhite"
            addNameplate(to: slime, isTop: false)
            addChild(slime)
            choiceSlimes.append(slime)
        }
        
        addChild(parent1Slime)
        addChild(parent2Slime)
        
        if animated {
            [parent1Slime, parent2Slime].forEach { node in
                node?.alpha = 0
                node?.run(SKAction.fadeIn(withDuration: 0.3))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        for slime in choiceSlimes {
            if slime.contains(loc) || slime.frame.contains(loc) {
                draggingSlime = slime
                dragOrigin = slime.position
                slime.zPosition = 10
                slime.run(SKAction.scale(to: 1.15, duration: 0.1))
                return
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let slime = draggingSlime else { return }
        slime.position = touch.location(in: self)
        
        let dzPos = dropZone.position
        let dist = hypot(slime.position.x - dzPos.x, slime.position.y - dzPos.y)
        dropZone.texture = SKTexture(imageNamed: dist < 85 ? "slot_current" : "slot_empty")
        dropZone.texture?.filteringMode = .nearest
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let slime = draggingSlime else { return }
        draggingSlime = nil
        slime.run(SKAction.scale(to: 1.0, duration: 0.1))
        
        let dzPos = dropZone.position
        let dist = hypot(slime.position.x - dzPos.x, slime.position.y - dzPos.y)
        
        if dist < 85 {
            checkAnswer(slime: slime)
        } else {
            dropZone.texture = SKTexture(imageNamed: "slot_empty")
            dropZone.texture?.filteringMode = .nearest
            slime.run(SKAction.move(to: dragOrigin, duration: 0.25))
        }
    }
    
    private func checkAnswer(slime: SlimeNode) {
        let (g1, g2) = rounds[currentRound]
        let offspring = monohybridCross(g1, g2)
        let hasAnyDominant = offspring.contains { $0.isDominant }
        
        let isCorrect: Bool
        let wrongExplanation: String
        
        if hasAnyDominant {
            isCorrect = slime.colorPhenotype == .purple
            wrongExplanation = "At least one parent has a dominant \"B\" allele, all offspring with \"B\" will be Purple. \"B\" always wins!"
        } else {
            isCorrect = slime.colorPhenotype == .white
            wrongExplanation = "Both parents are \"bb\" — there are no \"B\", so every offspring turns White."
        }
        
        if isCorrect {
            playCorrectSound()
            playSlimeSound()
            slime.position = dropZone.position
            dropZone.texture = SKTexture(imageNamed: "slot_filled")
            dropZone.texture?.filteringMode = .nearest
            dropZoneLabel.isHidden = true
            slime.playCorrectAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.advanceRound()
                }
            }
        } else {
            dropZone.texture = SKTexture(imageNamed: "slot_empty")
            dropZone.texture?.filteringMode = .nearest
            slime.playWrongAnimation { [slime] in
                slime.run(SKAction.move(to: self.dragOrigin, duration: 0.25))
            }
            showWrongAnswer(explanation: wrongExplanation)
        }
    }
    
    private func advanceRound() {
        if currentRound < rounds.count - 1 {
            currentRound += 1
            loadRound(animated: true)
        } else {
            completeLevel()
        }
    }

    private func addNameplate(to slime: SlimeNode, isTop: Bool = true) {
        let color = slime.colorPhenotype
        let tex = SKTexture(imageNamed: "genotype_card_\(color.rawValue)")
        let ratio = tex.size().width / tex.size().height
        let cardHeight: CGFloat = 46
        let card = SKSpriteNode(texture: tex)
        card.name = "nameplate"
        card.texture?.filteringMode = .nearest
        card.size = CGSize(width: cardHeight * ratio, height: cardHeight)
        card.position = CGPoint(x: 0, y: isTop ? 75 : -70)
        card.zPosition = 5
        let lbl = SKLabelNode(text: color.rawValue.capitalized)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = 18
        lbl.fontColor = (color == .purple) ? .white : .black
        lbl.verticalAlignmentMode = .center
        card.addChild(lbl)
        slime.addChild(card)
    }
}
