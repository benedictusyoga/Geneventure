//
//  Level7.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class Level7Scene: GameScene {
    private struct Round {
        let answer1: Genotype
        let answer2: Genotype
        var offspringColors: [ColorPhenotype] {
            monohybridCross(answer1, answer2).map { ColorPhenotype.from($0) }
        }
    }

    private let rounds: [Round] = [
        Round(answer1: .BB, answer2: .BB),
        Round(answer1: .Bb, answer2: .Bb),
        Round(answer1: .Bb, answer2: .bb),
        Round(answer1: .bb, answer2: .bb)
    ]
    private var currentRound = 0

    private var centerX: CGFloat { size.width / 2 }
    private var centerY: CGFloat { size.height / 2 }

    private var rowInstruct: CGFloat { size.height * 0.74 }
    private var rowOffLabel: CGFloat { size.height * 0.63 }
    private var rowOffSlimes: CGFloat { size.height * 0.55 }
    private var rowSlots: CGFloat { size.height * 0.38 }
    private var rowSources: CGFloat { size.height * 0.20 }
    private var rowLabel: CGFloat { size.height * 0.05 }

    private var slot1: SlotNode!
    private var slot2: SlotNode!
    private var sourceSlimes: [SlimeNode] = []
    private let sourceGenotypes: [Genotype] = [.BB, .Bb, .bb]
    private var roundNodes: [SKNode] = []

    private var dragClone: SlimeNode?
    private var dragGenotype: Genotype?

    private var roundLabel: SKLabelNode!
    private var instructionPlate: SKSpriteNode!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        resetState()
        setupStaticUI()
        loadRound()
    }

    override func relayout() {
        resetState()
        setupStaticUI()
        loadRound()
    }

    private func resetState() {
        let hint = childNode(withName: "hintToken")
        hint?.removeFromParent()
        removeAllChildren()
        if let hint = hint { addChild(hint) }
        
        currentRound = 0
        slot1 = nil
        slot2 = nil
        sourceSlimes.removeAll()
        roundNodes.removeAll()
        dragClone = nil
        dragGenotype = nil
    }

    private func setupStaticUI() {
        let names = ["instructionPlate", "roundLabel", "slot1", "slot2", "crossSprite"]
        for name in names { enumerateChildNodes(withName: name) { node, _ in node.removeFromParent() } }

        let plateWidth = size.width * 0.85
        instructionPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        instructionPlate.name = "instructionPlate"
        instructionPlate.texture?.filteringMode = .nearest
        instructionPlate.size = CGSize(width: plateWidth, height: 120)
        instructionPlate.position = CGPoint(x: centerX, y: rowInstruct)
        addChild(instructionPlate)

        let instrLbl = SKLabelNode(text: "Look at the offspring. Drag the correct parents into the slots!")
        instrLbl.fontName = "AvenirNext-Medium"
        instrLbl.fontSize = 20
        instrLbl.fontColor = .black
        instrLbl.position = .zero
        instrLbl.verticalAlignmentMode = .center
        instrLbl.horizontalAlignmentMode = .center
        instrLbl.preferredMaxLayoutWidth = plateWidth * 0.85
        instrLbl.numberOfLines = 2
        instrLbl.zPosition = 1
        instrLbl.name = "instructionLabel"
        instructionPlate.addChild(instrLbl)

        roundLabel = SKLabelNode(text: "Round 1 / 4")
        roundLabel.name = "roundLabel"
        roundLabel.fontName = "AvenirNext-Bold"
        roundLabel.fontSize = 14
        roundLabel.fontColor = UIColor.systemGray
        roundLabel.position = CGPoint(x: centerX, y: rowLabel)
        roundLabel.verticalAlignmentMode = .center
        roundLabel.horizontalAlignmentMode = .center
        addChild(roundLabel)

        slot1 = SlotNode(label: "Parent 1")
        slot1.name = "slot1"
        slot1.position = CGPoint(x: centerX - size.width * 0.09, y: rowSlots)
        addChild(slot1)

        slot2 = SlotNode(label: "Parent 2")
        slot2.name = "slot2"
        slot2.position = CGPoint(x: centerX + size.width * 0.09, y: rowSlots)
        addChild(slot2)

        let crossTex = SKTexture(imageNamed: "cross")
        let crossRatio = crossTex.size().width / crossTex.size().height
        let crossH: CGFloat = min(32, size.width * 0.08)
        let crossSprite = SKSpriteNode(texture: crossTex)
        crossSprite.name = "crossSprite"
        crossSprite.texture?.filteringMode = .nearest
        crossSprite.size = CGSize(width: crossH * crossRatio, height: crossH)
        crossSprite.position = CGPoint(x: centerX, y: rowSlots)
        addChild(crossSprite)
    }

    private func loadRound() {
        enumerateChildNodes(withName: "roundDynamic") { node, _ in node.removeFromParent() }
        roundNodes.forEach { $0.removeFromParent() }
        roundNodes.removeAll()
        sourceSlimes.removeAll()
        slot1?.clear()
        slot2?.clear()

        let round = rounds[currentRound]
        roundLabel?.text = "Round \(currentRound + 1) / 4"

        let offLbl = makeLabel("Offspring:", fontSize: 24, at: CGPoint(x: centerX, y: rowOffLabel))
        offLbl.name = "roundDynamic"
        addChild(offLbl)
        roundNodes.append(offLbl)

        let colors = round.offspringColors.shuffled()
        let spacing: CGFloat = min(90, size.width * 0.20)
        let startX = centerX - spacing * 1.5
        for (i, color) in colors.enumerated() {
            let slime = SlimeNode(color: color, size: 100, isAnimated: false)
            slime.name = "roundDynamic"
            slime.position = CGPoint(x: startX + CGFloat(i) * spacing, y: rowOffSlimes)
            slime.alpha = 0
            addChild(slime)
            roundNodes.append(slime)
            slime.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.07),
                SKAction.fadeIn(withDuration: 0.25)
            ]))
        }

        let sourceSize: CGFloat = 110
        let srcSpacing: CGFloat = min(150, size.width * 0.26)
        let srcStartX = centerX - srcSpacing
        for (i, g) in sourceGenotypes.enumerated() {
            let color = ColorPhenotype.from(g)
            let slime = SlimeNode(color: color, size: sourceSize, isAnimated: true)
            slime.name = "roundDynamic"
            let pos = CGPoint(x: srcStartX + CGFloat(i) * srcSpacing, y: rowSources)
            slime.position = pos
            addChild(slime)
            sourceSlimes.append(slime)
            roundNodes.append(slime)

            let isPurple = (color == .purple)
            let cardTex = SKTexture(imageNamed: isPurple ? "genotype_card_purple" : "genotype_card_white")
            let cardRatio = cardTex.size().width / cardTex.size().height
            let cardH: CGFloat = 50
            let card = SKSpriteNode(texture: cardTex)
            card.name = "roundDynamic"
            card.texture?.filteringMode = .nearest
            card.size = CGSize(width: cardH * cardRatio, height: cardH)
            card.position = CGPoint(x: pos.x, y: pos.y - sourceSize * 0.82)
            addChild(card)
            roundNodes.append(card)

            let nameLbl = SKLabelNode(text: g.displayName)
            nameLbl.fontName = "AvenirNext-Bold"
            nameLbl.fontSize = 24
            nameLbl.fontColor = isPurple ? .white : .black
            nameLbl.verticalAlignmentMode = .center
            card.addChild(nameLbl)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)

        for (i, src) in sourceSlimes.enumerated() {
            if hit === src || hit.inParentHierarchy(src) {
                let g = sourceGenotypes[i]
                let clone = SlimeNode(color: ColorPhenotype.from(g), size: 110, isAnimated: false)
                clone.position = src.position
                clone.zPosition = 10
                addChild(clone)
                dragClone = clone
                dragGenotype = g
                return
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let clone = dragClone else { return }
        let loc = touch.location(in: self)
        clone.position = loc

        slot1.highlight(hypot(loc.x - slot1.position.x, loc.y - slot1.position.y) < 70 && slot1.placedGenotype == nil)
        slot2.highlight(hypot(loc.x - slot2.position.x, loc.y - slot2.position.y) < 70 && slot2.placedGenotype == nil)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first, let clone = dragClone, let g = dragGenotype else { return }
        let loc = touch.location(in: self)
        dragClone = nil
        dragGenotype = nil
        slot1.highlight(false)
        slot2.highlight(false)

        let d1 = hypot(loc.x - slot1.position.x, loc.y - slot1.position.y)
        let d2 = hypot(loc.x - slot2.position.x, loc.y - slot2.position.y)

        var placed = false
        if d1 <= d2, d1 < 70, slot1.placedGenotype == nil {
            slot1.place(genotype: g); placed = true
        } else if d2 < d1, d2 < 70, slot2.placedGenotype == nil {
            slot2.place(genotype: g); placed = true
        }
        clone.removeFromParent()

        if placed, let g1 = slot1.placedGenotype, let g2 = slot2.placedGenotype {
            checkAnswer(g1: g1, g2: g2)
        }
    }

    private func checkAnswer(g1: Genotype, g2: Genotype) {
        let round = rounds[currentRound]
        let expected = [round.answer1.rawValue, round.answer2.rawValue].sorted()
        let given    = [g1.rawValue, g2.rawValue].sorted()

        if given == expected {
            playCorrectSound()
            slot1.flash(correct: true)
            slot2.flash(correct: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.advanceRound()
            }
        } else {
            slot1.flash(correct: false)
            slot2.flash(correct: false)
            let r = rounds[currentRound]
            showWrongAnswer(explanation:
                "The offspring pattern fits \(r.answer1.displayName) × \(r.answer2.displayName).\n" +
                "Try a different parent combination!"
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.slot1.clear()
                self.slot2.clear()
            }
        }
    }

    private func advanceRound() {
        if currentRound < rounds.count - 1 {
            currentRound += 1
            loadRound()
        } else {
            completeLevel()
        }
    }

    private func makeLabel(_ text: String, fontSize: CGFloat, at position: CGPoint, color: UIColor = .darkGray, bold: Bool = false) -> SKLabelNode {
        let lbl = SKLabelNode(text: text)
        lbl.fontName = bold ? "AvenirNext-Bold" : "AvenirNext-Medium"
        lbl.fontSize = fontSize
        lbl.fontColor = color
        lbl.position = position
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center
        lbl.numberOfLines = 2
        return lbl
    }
}
