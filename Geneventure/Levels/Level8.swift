//
//  Level8.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class Level8Scene: GameScene {
    private struct Round {
        let knownParent: Genotype
        let mysteryParent: Genotype
        var ratioText: String {
            let r = phenotypeRatio(from: monohybridCross(knownParent, mysteryParent))
            if r.recessive == 0 { return "4 Purple : 0 White" }
            if r.dominant == 0 { return "0 Purple : 4 White" }
            return "\(r.dominant) Purple : \(r.recessive) White"
        }
    }
    private let rounds: [Round] = [
        Round(knownParent: .Bb, mysteryParent: .Bb),
        Round(knownParent: .Bb, mysteryParent: .bb),
        Round(knownParent: .Bb, mysteryParent: .BB)
    ]
    private var currentRound = 0
    private var isCompact: Bool { size.width < 500 }
    private var navbarHeight: CGFloat { isCompact ? 110 : 90 }
    private var contentWidth: CGFloat { min(size.width - 40, 500) }
    private var plateWidth: CGFloat { min(contentWidth, 700) }
    private var centerX: CGFloat { size.width / 2 }
    private var centerY: CGFloat { size.height / 2 }
    private var slimeSize: CGFloat { isCompact ? 70 : 110 }
    private var parentOffset: CGFloat { isCompact ? 62 : size.width * 0.09 }

    private var usableTop: CGFloat { size.height - navbarHeight }
    private var usableHeight: CGFloat { size.height - navbarHeight - 30 }
    private var groupCenterY: CGFloat { usableTop - usableHeight / 2 }

    private var rowInstruct: CGFloat { groupCenterY + 235 }
    private var rowRatioTitle: CGFloat { groupCenterY + 130 }
    private var rowRatioValue: CGFloat { groupCenterY + 95  }
    private var rowBar: CGFloat { groupCenterY + 57  }
    private var rowParents: CGFloat { groupCenterY - 30  }
    private var rowHint: CGFloat { groupCenterY - 154 }
    private var rowCards: CGFloat { groupCenterY - 209 }
    private var rowLabel: CGFloat { groupCenterY - 264 }

    private var knownSlime: SlimeNode!
    private var mysteryZone: SKSpriteNode!
    private var mysteryQuestionLabel: SKLabelNode!
    private var choiceCards: [GenotypeCardNode] = []
    private var cardHomes: [CGPoint] = []
    private var roundNodes: [SKNode] = []
    private var roundLabel: SKLabelNode!
    private var instructionPlate: SKSpriteNode!

    private var dragClone: GenotypeCardNode?
    private var dragGenotype: Genotype?

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
        knownSlime = nil
        mysteryZone = nil
        mysteryQuestionLabel = nil
        choiceCards.removeAll()
        cardHomes.removeAll()
        roundNodes.removeAll()
        dragClone = nil
        dragGenotype = nil
    }

    private func setupStaticUI() {
        let names = ["instructionPlate", "roundLabel", "crossSprite"]
        for name in names { enumerateChildNodes(withName: name) { node, _ in node.removeFromParent() } }

        instructionPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        instructionPlate.name = "instructionPlate"
        instructionPlate.texture?.filteringMode = .nearest
        instructionPlate.size = CGSize(width: plateWidth, height: isCompact ? 100 : 140)
        instructionPlate.position = CGPoint(x: centerX, y: rowInstruct)
        addChild(instructionPlate)

        let instrLbl = SKLabelNode(text: "Use the offspring ratio to deduce the mystery parent!")
        instrLbl.fontName = "AvenirNext-Medium"
        instrLbl.fontSize = isCompact ? 16 : 20
        instrLbl.fontColor = .black
        instrLbl.position = .zero
        instrLbl.verticalAlignmentMode = .center
        instrLbl.horizontalAlignmentMode = .center
        instrLbl.preferredMaxLayoutWidth = plateWidth * (isCompact ? 0.82 : 0.70)
        instrLbl.numberOfLines = 2
        instrLbl.zPosition = 1
        instrLbl.name = "instructionLabel"
        instructionPlate.addChild(instrLbl)

        roundLabel = SKLabelNode(text: "Round 1 / 3")
        roundLabel.name = "roundLabel"
        roundLabel.fontName = "AvenirNext-Bold"
        roundLabel.fontSize = 14
        roundLabel.fontColor = UIColor.systemGray
        roundLabel.position = CGPoint(x: centerX, y: rowLabel)
        roundLabel.verticalAlignmentMode = .center
        roundLabel.horizontalAlignmentMode = .center
        addChild(roundLabel)

        let crossTex = SKTexture(imageNamed: "cross")
        let crossRatio = crossTex.size().width / crossTex.size().height
        let crossH: CGFloat = min(32, size.width * 0.08)
        let crossSprite = SKSpriteNode(texture: crossTex)
        crossSprite.name = "crossSprite"
        crossSprite.texture?.filteringMode = .nearest
        crossSprite.size = CGSize(width: crossH * crossRatio, height: crossH)
        crossSprite.position = CGPoint(x: centerX, y: rowParents)
        addChild(crossSprite)
    }

    private func loadRound() {
        enumerateChildNodes(withName: "roundDynamic") { node, _ in node.removeFromParent() }
        roundNodes.forEach { $0.removeFromParent() }
        roundNodes.removeAll()
        choiceCards.removeAll()
        cardHomes.removeAll()

        let round = rounds[currentRound]
        roundLabel?.text = "Round \(currentRound + 1) / 3"

        knownSlime = SlimeNode(color: ColorPhenotype.from(round.knownParent), size: slimeSize, isAnimated: false)
        knownSlime.name = "roundDynamic"
        knownSlime.position = CGPoint(x: centerX - parentOffset, y: rowParents)
        addChild(knownSlime)
        roundNodes.append(knownSlime)

        addNameplate(genotype: round.knownParent, at: CGPoint(x: centerX - parentOffset, y: rowParents - slimeSize * 0.76))

        mysteryZone = SKSpriteNode(imageNamed: "slot_empty")
        mysteryZone.name = "mysteryZone"
        mysteryZone.texture?.filteringMode = .nearest
        let zoneSize: CGFloat = isCompact ? 80 : 120
        mysteryZone.size = CGSize(width: zoneSize, height: zoneSize)
        mysteryZone.color = .clear
        mysteryZone.colorBlendFactor = 0.0
        mysteryZone.position = CGPoint(x: centerX + parentOffset, y: rowParents)
        addChild(mysteryZone)
        roundNodes.append(mysteryZone)

        mysteryQuestionLabel = SKLabelNode(text: "??")
        mysteryQuestionLabel.name = "mysteryQuestion"
        mysteryQuestionLabel.fontName = "AvenirNext-Bold"
        mysteryQuestionLabel.fontSize = isCompact ? 28 : 40
        mysteryQuestionLabel.fontColor = UIColor.gray
        mysteryQuestionLabel.verticalAlignmentMode = .center
        mysteryZone.addChild(mysteryQuestionLabel)

        let mysteryTitle = makeLabel("Mystery", fontSize: isCompact ? 14 : 18, at: CGPoint(x: centerX + parentOffset, y: rowParents - slimeSize * 0.76), color: .gray)
        mysteryTitle.name = "roundDynamic"
        addChild(mysteryTitle)
        roundNodes.append(mysteryTitle)

        let ratioTitle = makeLabel("Offspring Ratio:", fontSize: isCompact ? 16 : 24, at: CGPoint(x: centerX, y: rowRatioTitle), bold: true)
        ratioTitle.name = "roundDynamic"
        addChild(ratioTitle)
        roundNodes.append(ratioTitle)

        let ratioValue = makeLabel(round.ratioText, fontSize: isCompact ? 22 : 32, at: CGPoint(x: centerX, y: rowRatioValue), bold: true)
        ratioValue.name = "roundDynamic"
        ratioValue.fontColor = UIColor(red: 0.3, green: 0.2, blue: 0.7, alpha: 1)
        addChild(ratioValue)
        roundNodes.append(ratioValue)

        let offspring = monohybridCross(round.knownParent, round.mysteryParent)
        let barW: CGFloat = isCompact ? 28 : 40
        let barH: CGFloat = isCompact ? 26 : 35
        let totalW = CGFloat(offspring.count) * barW
        let barStartX = centerX - totalW / 2
        for (i, g) in offspring.enumerated() {
            let seg = SKShapeNode(rectOf: CGSize(width: barW - 2, height: barH), cornerRadius: 4)
            seg.name = "roundDynamic"
            seg.fillColor = g.isDominant
                ? UIColor(red: 0.55, green: 0.27, blue: 0.88, alpha: 1)
                : UIColor(white: 0.85, alpha: 1)
            seg.strokeColor = UIColor(white: 0.6, alpha: 0.5)
            seg.lineWidth = 1
            seg.position = CGPoint(x: barStartX + CGFloat(i) * barW + barW / 2, y: rowBar)
            addChild(seg)
            roundNodes.append(seg)
        }

        let choiceHint = makeLabel("Drag your answer onto the ?? slot!", fontSize: isCompact ? 12 : 13, at: CGPoint(x: centerX, y: rowHint), color: .gray)
        choiceHint.name = "roundDynamic"
        addChild(choiceHint)
        roundNodes.append(choiceHint)

        let choices: [Genotype] = [.BB, .Bb, .bb]
        let cSpacing: CGFloat = isCompact ? min(90, contentWidth * 0.28) : min(100, size.width * 0.24)
        let cStartX = centerX - cSpacing
        let breathe = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.06, duration: 0.75),
            SKAction.scale(to: 0.94, duration: 0.75)
        ]))
        for (i, g) in choices.enumerated() {
            let card = GenotypeCardNode(genotype: g, height: isCompact ? 55 : 80)
            card.name = "roundDynamic"
            let pos = CGPoint(x: cStartX + CGFloat(i) * cSpacing, y: rowCards)
            card.position = pos
            cardHomes.append(pos)
            addChild(card)
            choiceCards.append(card)
            roundNodes.append(card)
            card.run(breathe)
        }
    }

    @discardableResult
    private func addNameplate(genotype: Genotype, at pos: CGPoint) -> SKSpriteNode {
        let isPurple = (ColorPhenotype.from(genotype) == .purple)
        let cardTex = SKTexture(imageNamed: isPurple ? "genotype_card_purple" : "genotype_card_white")
        let cardRatio = cardTex.size().width / cardTex.size().height
        let cardH: CGFloat = isCompact ? 36 : 50
        let card = SKSpriteNode(texture: cardTex)
        card.texture?.filteringMode = .nearest
        card.size = CGSize(width: cardH * cardRatio, height: cardH)
        card.position = pos
        addChild(card)
        roundNodes.append(card)

        let lbl = SKLabelNode(text: genotype.displayName)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = isCompact ? 18 : 24
        lbl.fontColor = isPurple ? .white : .black
        lbl.verticalAlignmentMode = .center
        card.addChild(lbl)
        return card
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)
        for card in choiceCards {
            if hit === card || hit.inParentHierarchy(card) {
                let clone = GenotypeCardNode(genotype: card.genotype, height: isCompact ? 55 : 80)
                clone.position = card.position
                clone.zPosition = 20
                addChild(clone)
                dragClone = clone
                dragGenotype = card.genotype
                return
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let clone = dragClone else { return }
        let loc = touch.location(in: self)
        clone.position = loc
        let dist = hypot(loc.x - mysteryZone.position.x, loc.y - mysteryZone.position.y)
        mysteryZone.texture = SKTexture(imageNamed: dist < 65 ? "slot_current" : "slot_empty")
        mysteryZone.texture?.filteringMode = .nearest
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first, let clone = dragClone, let g = dragGenotype else { return }
        let loc = touch.location(in: self)
        dragClone = nil
        dragGenotype = nil
        mysteryZone.texture = SKTexture(imageNamed: "slot_empty")
        mysteryZone.texture?.filteringMode = .nearest
        let dist = hypot(loc.x - mysteryZone.position.x, loc.y - mysteryZone.position.y)
        guard dist < 70 else { clone.removeFromParent(); return }
        checkAnswer(genotype: g, clone: clone)
    }

    private func checkAnswer(genotype: Genotype, clone: GenotypeCardNode) {
        let round = rounds[currentRound]
        if genotype == round.mysteryParent {
            playCorrectSound()
            playSlimeSound()
            clone.removeFromParent()
            mysteryQuestionLabel.removeFromParent()
            mysteryZone.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.25),
                SKAction.removeFromParent()
            ]))
            let revealSlime = SlimeNode(color: ColorPhenotype.from(genotype), size: slimeSize, isAnimated: false)
            revealSlime.alpha = 0
            revealSlime.setScale(0.2)
            revealSlime.position = CGPoint(x: centerX + parentOffset, y: rowParents)
            addChild(revealSlime)
            roundNodes.append(revealSlime)

            let np = addNameplate(genotype: genotype, at: CGPoint(x: centerX + parentOffset, y: rowParents - slimeSize * 0.76))
            np.alpha = 0

            revealSlime.run(SKAction.group([
                SKAction.fadeIn(withDuration: 0.35),
                SKAction.scale(to: 1.0, duration: 0.35)
            ]))
            np.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.fadeIn(withDuration: 0.3)
            ]))

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                self.advanceRound()
            }
        } else {
            clone.removeFromParent()
            let r = round
            let explanation: String
            switch r.mysteryParent {
            case .BB: explanation = "The ratio '\(r.ratioText)' means ALL offspring get a B.\nThe mystery parent must be BB — fully dominant!"
            case .Bb: explanation = "The ratio '\(r.ratioText)' is the classic 3:1.\nThe mystery parent must be Bb — one of each allele."
            case .bb: explanation = "The ratio '\(r.ratioText)' means half the offspring are White.\nThe mystery parent is bb — fully recessive."
            }
            showWrongAnswer(explanation: explanation)
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
        lbl.numberOfLines = 3
        return lbl
    }
}
