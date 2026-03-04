//
//  Level4.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class Level4Scene: GameScene {
    private let slimeSetup: [(ColorPhenotype, Genotype)] = [
        (.purple, .BB),
        (.purple, .Bb),
        (.white, .bb)
    ]
    private var isCompact: Bool { size.width < 500 }
    private var centerX: CGFloat { size.width / 2 }
    private var centerY: CGFloat { size.height / 2 }
    private var contentWidth: CGFloat { min(size.width - 40, 500) }
    private var plateWidth: CGFloat { min(contentWidth, 700) }
    private var slimeSize: CGFloat { min(120, size.width * 0.22) }
    private var slimeSpacing: CGFloat { min(180, size.width * 0.28) }

    private var rowInstruct: CGFloat { size.height * 0.74 }
    private var rowSlimes: CGFloat { size.height * 0.28 }
    private var rowCrack: CGFloat { size.height * 0.54 }
    private var rowCards: CGFloat { size.height * 0.54 }

    private var phase = 1
    private var slimeNodes: [SlimeNode] = []
    private var homePositions: [CGPoint] = []
    private var crackedFlags = [false, false, false]
    private var crackedCount = 0
    private var crackZone: SKSpriteNode!
    private var namePlates: [SKSpriteNode] = []

    private var cards: [GenotypeCardNode] = []
    private var cardHomes: [CGPoint] = []
    private var matchedCount = 0

    private var draggingSlime: SlimeNode?
    private var draggingSlimeIndex = -1
    private var draggingCard: GenotypeCardNode?
    private var draggingCardIndex = -1

    private var instructionPlate: SKSpriteNode!
    private var instructionLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        resetState()
        setupPhase1()
    }

    override func relayout() {
        resetState()
        setupPhase1()
    }

    private func resetState() {
        let hint = childNode(withName: "hintToken")
        hint?.removeFromParent()
        removeAllChildren()
        if let hint = hint { addChild(hint) }
        
        phase = 1
        slimeNodes.removeAll()
        homePositions.removeAll()
        crackedFlags = [false, false, false]
        crackedCount = 0
        cards.removeAll()
        cardHomes.removeAll()
        matchedCount = 0
        namePlates.removeAll()
        
        draggingSlime = nil
        draggingSlimeIndex = -1
        draggingCard = nil
        draggingCardIndex = -1
    }

    private func setupInstructionPlate(text: String) {
        instructionPlate?.removeFromParent()
        instructionPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        instructionPlate.texture?.filteringMode = .nearest
        instructionPlate.size = CGSize(width: plateWidth, height: isCompact ? 100 : 140)
        instructionPlate.position = CGPoint(x: centerX, y: rowInstruct)
        addChild(instructionPlate)

        instructionLabel = SKLabelNode(text: text)
        instructionLabel.fontName = "AvenirNext-Medium"
        instructionLabel.fontSize = isCompact ? 16 : 20
        instructionLabel.fontColor = .black
        instructionLabel.position = .zero
        instructionLabel.verticalAlignmentMode = .center
        instructionLabel.horizontalAlignmentMode = .center
        instructionLabel.preferredMaxLayoutWidth = plateWidth * (isCompact ? 0.82 : 0.70)
        instructionLabel.numberOfLines = 2
        instructionLabel.zPosition = 1
        instructionPlate.addChild(instructionLabel)
    }

    private func setupPhase1() {
        setupInstructionPlate(text: "Crack each Slime open to reveal its genotype!")

        let dz: CGFloat = min(100, size.width * 0.24)
        crackZone = SKSpriteNode(imageNamed: "slot_empty")
        crackZone.texture?.filteringMode = .nearest
        crackZone.size = CGSize(width: dz, height: dz)
        crackZone.position = CGPoint(x: centerX, y: rowCrack)
        crackZone.name = "crackZone"
        addChild(crackZone)

        let czLbl = SKLabelNode(text: "Crack!")
        czLbl.fontName = "AvenirNext-Bold"
        czLbl.fontSize = 14
        czLbl.fontColor = .darkGray
        czLbl.verticalAlignmentMode = .center
        czLbl.horizontalAlignmentMode = .center
        czLbl.position = CGPoint(x: centerX, y: rowCrack - dz * 0.62)
        czLbl.name = "crackLabel"
        addChild(czLbl)

        let sp = slimeSpacing
        let startX = centerX - sp
        let _: [UIColor] = [
            UIColor(red: 0.55, green: 0.27, blue: 0.88, alpha: 1),
            UIColor(red: 0.55, green: 0.27, blue: 0.88, alpha: 1),
            UIColor(white: 0.85, alpha: 1)
        ]

        for (i, (color, _)) in slimeSetup.enumerated() {
            let pos = CGPoint(x: startX + CGFloat(i) * sp, y: rowSlimes)
            homePositions.append(pos)

            let slime = SlimeNode(color: color, size: slimeSize, isAnimated: true)
            slime.position = pos
            slime.name = "slime_\(i)"
            addChild(slime)
            slimeNodes.append(slime)

            let q = SKLabelNode(text: "?")
            q.fontName = "AvenirNext-Black"
            q.fontSize = 20
            q.fontColor = .darkGray
            q.verticalAlignmentMode = .center
            q.horizontalAlignmentMode = .center
            q.position = CGPoint(x: pos.x, y: pos.y - slimeSize * 0.72)
            q.name = "q_\(i)"
            addChild(q)

            let colorName = (color == .purple) ? "Purple" : "White"
            let cardTex = SKTexture(imageNamed: color == .purple ? "genotype_card_purple" : "genotype_card_white")
            let cardRatio = cardTex.size().width / cardTex.size().height
            let cardH: CGFloat = 46
            let card = SKSpriteNode(texture: cardTex)
            card.texture?.filteringMode = .nearest
            card.size = CGSize(width: cardH * cardRatio, height: cardH)
            card.position = CGPoint(x: pos.x, y: rowSlimes + slimeSize * 0.90)
            addChild(card)
            namePlates.append(card)

            let nameLbl = SKLabelNode(text: colorName)
            nameLbl.fontName = "AvenirNext-Bold"
            nameLbl.fontSize = 18
            nameLbl.fontColor = color == .purple ? .white : .black
            nameLbl.verticalAlignmentMode = .center
            card.addChild(nameLbl)
        }
    }

    private func crack(index: Int) {
        guard !crackedFlags[index] else { return }
        crackedFlags[index] = true
        crackedCount += 1

        let slime = slimeNodes[index]
        let genotype = slimeSetup[index].1

        playSlimeSound()
        crackZone.texture = SKTexture(imageNamed: "slot_current")
        crackZone.texture?.filteringMode = .nearest

        let crackAnim = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.10),
            SKAction.scale(to: 0.9, duration: 0.09),
            SKAction.scale(to: 1.0, duration: 0.07)
        ])

        let crackPos = homePositions[index]
        slime.run(SKAction.group([
            crackAnim,
            SKAction.move(to: crackPos, duration: 0.2)
        ])) { [weak self] in
            guard let self = self, index < self.crackedFlags.count else { return }
            slime.childNode(withName: "q_\(index)")?.removeFromParent()
            self.children
                .compactMap { $0 as? SKLabelNode }
                .filter { $0.name == "q_\(index)" }
                .forEach { $0.removeFromParent() }

            let gLabel = SKLabelNode(text: genotype.displayName)
            gLabel.fontName = "AvenirNext-Black"
            gLabel.fontSize = 26
            gLabel.fontColor = .black
            gLabel.verticalAlignmentMode = .center
            gLabel.horizontalAlignmentMode = .center
            gLabel.alpha = 0
            gLabel.position = CGPoint(x: crackPos.x, y: crackPos.y - self.slimeSize * 0.78)
            self.addChild(gLabel)
            gLabel.run(SKAction.fadeIn(withDuration: 0.25))

            self.crackZone.texture = SKTexture(imageNamed: "slot_empty")
            self.crackZone.texture?.filteringMode = .nearest

            if self.crackedCount == 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { self.beginPhase2() }
            }
        }
    }

    private func beginPhase2() {
        phase = 2
        setupInstructionPlate(text: "Now drag the label cards onto the matching Slimes!")

        crackZone.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        childNode(withName: "crackLabel")?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))

        let shuffled: [Genotype] = [.BB, .Bb, .bb].shuffled()
        let sp = slimeSpacing
        let startX = centerX - sp

        for (i, g) in shuffled.enumerated() {
            let card = GenotypeCardNode(genotype: g, height: 80)
            let pos = CGPoint(x: startX + CGFloat(i) * sp, y: rowCards)
            card.position = pos
            card.alpha = 0
            cardHomes.append(pos)
            addChild(card)
            cards.append(card)

            card.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.1),
                SKAction.fadeIn(withDuration: 0.3)
            ]))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        let hit = atPoint(loc)
        if phase == 1 {
            for (i, slime) in slimeNodes.enumerated() {
                guard i < crackedFlags.count, !crackedFlags[i] else { continue }
                if hit === slime || hit.inParentHierarchy(slime) {
                    draggingSlime = slime
                    draggingSlimeIndex = i
                    slime.zPosition = 10
                    return
                }
            }
        } else {
            for (i, card) in cards.enumerated() where !card.isPlaced {
                if hit === card || hit.inParentHierarchy(card) {
                    draggingCard = card
                    draggingCardIndex = i
                    card.zPosition = 10
                    return
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        if let slime = draggingSlime {
            slime.position = loc
            if let cz = crackZone, cz.parent != nil {
                let dist = hypot(loc.x - cz.position.x, loc.y - cz.position.y)
                cz.texture = SKTexture(imageNamed: dist < 70 ? "slot_current" : "slot_empty")
                cz.texture?.filteringMode = .nearest
            }
        }
        draggingCard?.position = loc
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        if let slime = draggingSlime {
            let i = draggingSlimeIndex
            draggingSlime = nil
            draggingSlimeIndex = -1
            slime.zPosition = 0

            if i >= 0, i < slimeNodes.count, let cz = crackZone, i < homePositions.count {
                if hypot(loc.x - cz.position.x, loc.y - cz.position.y) < 70 {
                    crack(index: i)
                } else {
                    cz.texture = SKTexture(imageNamed: "slot_empty")
                    cz.texture?.filteringMode = .nearest
                    slime.run(SKAction.move(to: homePositions[i], duration: 0.2))
                }
            }
        }

        if let card = draggingCard {
            let ci = draggingCardIndex
            draggingCard = nil
            draggingCardIndex = -1
            card.zPosition = 0

            var bestIndex = -1
            var bestDist: CGFloat = .infinity
            for (si, slime) in slimeNodes.enumerated() {
                let d = hypot(loc.x - slime.position.x, loc.y - slime.position.y)
                if d < bestDist { bestDist = d; bestIndex = si }
            }

            if bestIndex >= 0, bestDist < 90 {
                let expected = slimeSetup[bestIndex].1
                if card.genotype == expected {
                    playCorrectSound()
                    playSlimeSound()
                    card.isPlaced = true
                    let target = CGPoint(x: slimeNodes[bestIndex].position.x, y: slimeNodes[bestIndex].position.y - slimeSize * 0.85)
                    card.run(SKAction.move(to: target, duration: 0.2))
                    slimeNodes[bestIndex].playCorrectAnimation()
                    matchedCount += 1
                    if matchedCount == 3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.completeLevel() }
                    }
                } else {
                    card.run(SKAction.move(to: cardHomes[ci], duration: 0.25))
                    let explanation: String
                    switch expected {
                    case .BB: explanation = "Match the card to the Slime's genotype. This one should be BB"
                    case .Bb: explanation = "Match the card to the Slime's genotype. This one should be Bb"
                    case .bb: explanation = "Match the card to the Slime's genotype. This one should be bb"
                    }
                    showWrongAnswer(explanation: explanation)
                }
            } else {
                card.run(SKAction.move(to: cardHomes[ci], duration: 0.25))
            }
        }
    }
}

private extension UIColor {
    var isDark: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r * 299 + g * 587 + b * 114) / 1000 < 0.5
    }
}
