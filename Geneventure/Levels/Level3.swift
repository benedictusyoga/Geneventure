//
//  Level3.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class Level3Scene: GameScene {
    private var isCompact: Bool { size.width < 500 }
    private var navbarHeight: CGFloat { isCompact ? 110 : 90 }
    private var centerX: CGFloat { size.width / 2 }

    private var contentWidth: CGFloat { min(size.width - 40, 500) }
    private var parentGap: CGFloat { contentWidth * 0.20 }

    private var parentSlimeSize: CGFloat { min(isCompact ? 75 : 90, contentWidth * 0.18) }

    private var offspringSpacing4: CGFloat { min(140, contentWidth * 0.28) }
    private var offspringSize4: CGFloat { min(100, contentWidth * 0.20) }

    private var gridColSpacing: CGFloat { contentWidth * 0.36 }
    private var offspringSize2x2: CGFloat { min(70, contentWidth * 0.18) }

    private var plateWidth: CGFloat { min(contentWidth, 700) }

    private var usableTop: CGFloat { size.height - navbarHeight }
    private var usableHeight: CGFloat { size.height - navbarHeight - 30 }

    private var rowInstruct: CGFloat { usableTop - usableHeight * 0.10 }
    private var rowParents: CGFloat { usableTop - usableHeight * 0.32 }
    private var rowDrop: CGFloat { usableTop - usableHeight * 0.52 }
    private var rowOffspring: CGFloat { usableTop - usableHeight * 0.79 }
    private var rowOffspringTop: CGFloat { usableTop - usableHeight * 0.70 }
    private var rowOffspringBot: CGFloat { usableTop - usableHeight * 0.87 }

    private var parent1: SlimeNode!
    private var parent2: SlimeNode!
    private var offspringSlimes: [SlimeNode] = []
    private var dropZone: SKSpriteNode!
    private var dropZoneLabel: SKLabelNode!
    private var instructionPlate: SKSpriteNode!
    private var instructionLabel: SKLabelNode!
    private var ratioBar: SKNode?
    private var cliffhangerLabel: SKLabelNode!

    private var answered = false
    private var draggingSlime: SlimeNode?
    private var dragOrigin: CGPoint = .zero

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        resetState()
        setupInstruction()
        setupParents()
        setupOffspring()
        setupDropZone()
    }

    override func relayout() {
        resetState()
        setupInstruction()
        setupParents()
        setupOffspring()
        setupDropZone()
    }

    private func resetState() {
        let hint = childNode(withName: "hintToken")
        hint?.removeFromParent()
        removeAllChildren()
        if let hint = hint { addChild(hint) }
        
        answered = false
        parent1 = nil
        parent2 = nil
        offspringSlimes.removeAll()
        ratioBar = nil
        draggingSlime = nil
    }

    private func setupInstruction() {
        enumerateChildNodes(withName: "instructionPlate") { node, _ in node.removeFromParent() }

        instructionPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        instructionPlate.name = "instructionPlate"
        instructionPlate.texture?.filteringMode = .nearest
        instructionPlate.position = CGPoint(x: centerX, y: rowInstruct)
        instructionPlate.size = CGSize(width: plateWidth, height: isCompact ? 100 : 140)
        addChild(instructionPlate)

        instructionLabel = SKLabelNode(text: "Which one is the odd one out? Drag it to the zone!")
        instructionLabel.fontName = "AvenirNext-Medium"
        instructionLabel.fontSize = isCompact ? 16 : 20
        instructionLabel.fontColor = .black
        instructionLabel.position = .zero
        instructionLabel.verticalAlignmentMode = .center
        instructionLabel.horizontalAlignmentMode = .center
        instructionLabel.preferredMaxLayoutWidth = plateWidth * (isCompact ? 0.82 : 0.70)
        instructionLabel.numberOfLines = 2
        instructionLabel.zPosition = 1
        instructionLabel.name = "instructionLabel"
        instructionPlate.addChild(instructionLabel)
    }

    private func setupParents() {
        enumerateChildNodes(withName: "parent1") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "parent2") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "crossSprite") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "colorCard") { node, _ in node.removeFromParent() }

        let ps = parentSlimeSize
        let gap = parentGap

        parent1 = SlimeNode(color: .purple, size: ps, isAnimated: false)
        parent1.position = CGPoint(x: centerX - gap, y: rowParents)
        parent1.name = "parent1"
        parent2 = SlimeNode(color: .purple, size: ps, isAnimated: false)
        parent2.position = CGPoint(x: centerX + gap, y: rowParents)
        parent2.name = "parent2"
        addChild(parent1)
        addChild(parent2)

        let crossTex = SKTexture(imageNamed: "cross")
        let crossRatio = crossTex.size().width / crossTex.size().height
        let crossH: CGFloat = min(40, size.width * 0.10)
        let crossSprite = SKSpriteNode(texture: crossTex)
        crossSprite.name = "crossSprite"
        crossSprite.texture?.filteringMode = .nearest
        crossSprite.size = CGSize(width: crossH * crossRatio, height: crossH)
        crossSprite.position = CGPoint(x: centerX, y: rowParents)
        addChild(crossSprite)

        addNameplate(to: parent1, isTop: true)
        addNameplate(to: parent2, isTop: true)
    }

    private func setupOffspring() {
        let colors: [ColorPhenotype] = [.purple, .purple, .purple, .white].shuffled()

        if isCompact {
            let os = offspringSize2x2
            let colSpacing = gridColSpacing
            let rows: [CGFloat] = [rowOffspringTop, rowOffspringBot]
            let cols: [CGFloat] = [centerX - colSpacing / 2, centerX + colSpacing / 2]

            for (i, color) in colors.enumerated() {
                let row = rows[i / 2]
                let col = cols[i % 2]
                let slime = SlimeNode(color: color, size: os, isAnimated: true)
                slime.position = CGPoint(x: col, y: row)
                slime.name = color == .white ? "oddSlime" : "purpleSlime\(i)"
                addNameplate(to: slime, isTop: false, yOverride: -50)
                addChild(slime)
                offspringSlimes.append(slime)
            }
        } else {
            let os = offspringSize4
            let spacing = offspringSpacing4
            let totalWidth = spacing * CGFloat(colors.count - 1)
            let startX = centerX - totalWidth / 2

            for (i, color) in colors.enumerated() {
                let slime = SlimeNode(color: color, size: os, isAnimated: true)
                slime.position = CGPoint(x: startX + CGFloat(i) * spacing, y: rowOffspring)
                slime.name = color == .white ? "oddSlime" : "purpleSlime\(i)"
                addNameplate(to: slime, isTop: false)
                addChild(slime)
                offspringSlimes.append(slime)
            }
        }
    }

    private func setupDropZone() {
        enumerateChildNodes(withName: "dropZone") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "dropZoneLabel") { node, _ in node.removeFromParent() }

        let dz: CGFloat = min(110, size.width * 0.26)
        dropZone = SKSpriteNode(imageNamed: "slot_empty")
        dropZone.texture?.filteringMode = .nearest
        dropZone.size = CGSize(width: dz, height: dz)
        dropZone.name = "dropZone"
        dropZone.position = CGPoint(x: centerX, y: rowDrop)
        addChild(dropZone)

        dropZoneLabel = SKLabelNode(text: "Odd one out?")
        dropZoneLabel.name = "dropZoneLabel"
        dropZoneLabel.fontName = "AvenirNext-Bold"
        dropZoneLabel.fontSize = 14
        dropZoneLabel.fontColor = .darkGray
        dropZoneLabel.verticalAlignmentMode = .center
        dropZoneLabel.position = CGPoint(x: centerX, y: rowDrop - dz * 0.62)
        addChild(dropZoneLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard !answered else { return }
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        for slime in offspringSlimes {
            if slime.contains(loc) {
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
        let dist = hypot(slime.position.x - dropZone.position.x, slime.position.y - dropZone.position.y)
        dropZone.texture = SKTexture(imageNamed: dist < 80 ? "slot_current" : "slot_empty")
        dropZone.texture?.filteringMode = .nearest
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        if answered {
            let hit = atPoint(loc)
            if hit.name == "continueBtn" { completeLevel() }
            return
        }

        guard let slime = draggingSlime else { return }
        draggingSlime = nil
        slime.run(SKAction.scale(to: 1.0, duration: 0.1))

        let dist = hypot(slime.position.x - dropZone.position.x, slime.position.y - dropZone.position.y)
        if dist < 80 {
            evaluateDrop(slime: slime)
        } else {
            dropZone.texture = SKTexture(imageNamed: "slot_empty")
            dropZone.texture?.filteringMode = .nearest
            slime.run(SKAction.move(to: dragOrigin, duration: 0.25))
        }
    }

    private func evaluateDrop(slime: SlimeNode) {
        if slime.colorPhenotype == .white {
            playCorrectSound()
            playSlimeSound()
            answered = true
            slime.position = dropZone.position
            slime.zPosition = 2
            dropZone.texture = SKTexture(imageNamed: "slot_filled")
            dropZone.texture?.filteringMode = .nearest
            dropZoneLabel.isHidden = true
            slime.playCorrectAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.transitionToResultRound()
                }
            }
        } else {
            dropZone.texture = SKTexture(imageNamed: "slot_empty")
            dropZone.texture?.filteringMode = .nearest
            slime.playWrongAnimation { [slime] in
                slime.run(SKAction.move(to: self.dragOrigin, duration: 0.25))
            }
            showWrongAnswer(explanation: "That Slime is Purple. Try to find the odd one out in this example!")
        }
    }

    private func transitionToResultRound() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        children.filter { $0.name != "hintToken" }.forEach { $0.run(fadeOut) }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.children.filter { $0.name != "hintToken" }.forEach { $0.removeFromParent() }
            self.showRatioRound()
        }
    }

    private func showRatioRound() {
        let plateY: CGFloat
        let barY: CGFloat
        let cliffY: CGFloat
        let btnY: CGFloat

        if isCompact {
            plateY = usableTop - usableHeight * 0.10
            barY   = usableTop - usableHeight * 0.45
            cliffY = usableTop - usableHeight * 0.65
            btnY   = usableTop - usableHeight * 0.88
        } else {
            plateY = usableTop - usableHeight * 0.35
            barY   = plateY - 150   
            cliffY = barY - 80    
            btnY   = cliffY - 110   
        }

        let plate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        plate.texture?.filteringMode = .nearest
        plate.size = CGSize(width: plateWidth, height: isCompact ? 100 : 140)
        plate.position = CGPoint(x: centerX, y: plateY)
        plate.alpha = 0
        addChild(plate)

        let instrLbl = SKLabelNode(text: "The ratio of offspring is 3 Purple : 1 White!")
        instrLbl.fontName = "AvenirNext-Medium"
        instrLbl.fontSize = isCompact ? 16 : 20
        instrLbl.fontColor = .black
        instrLbl.position = .zero
        instrLbl.verticalAlignmentMode = .center
        instrLbl.horizontalAlignmentMode = .center
        instrLbl.preferredMaxLayoutWidth = plateWidth * (isCompact ? 0.85 : 0.70)
        instrLbl.numberOfLines = 2
        instrLbl.zPosition = 1
        plate.addChild(instrLbl)

        plate.run(SKAction.fadeIn(withDuration: 0.4))

        let segWidth: CGFloat = 60
        let segHeight: CGFloat = 36
        let segments: [(UIColor, String)] = [
            (UIColor(red: 0.55, green: 0.27, blue: 0.88, alpha: 1), "Purple"),
            (UIColor(red: 0.55, green: 0.27, blue: 0.88, alpha: 1), ""),
            (UIColor(red: 0.55, green: 0.27, blue: 0.88, alpha: 1), ""),
            (UIColor(white: 0.85, alpha: 1), "White")
        ]
        let totalBarW = segWidth * CGFloat(segments.count)
        let barStartX = centerX - totalBarW / 2

        for (i, (color, labelText)) in segments.enumerated() {
            let seg = SKShapeNode(rectOf: CGSize(width: segWidth, height: segHeight))
            seg.fillColor = color
            seg.strokeColor = .darkGray
            seg.lineWidth = 1
            seg.position = CGPoint(x: barStartX + CGFloat(i) * segWidth + segWidth / 2, y: barY)
            seg.alpha = 0
            addChild(seg)

            if !labelText.isEmpty {
                let lbl = SKLabelNode(text: labelText)
                lbl.fontName = "AvenirNext-Medium"
                lbl.fontSize = 12
                lbl.fontColor = .darkGray
                lbl.position = CGPoint(x: 0, y: -segHeight / 2 - 16)
                lbl.verticalAlignmentMode = .top
                seg.addChild(lbl)
            }

            seg.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.4 + Double(i) * 0.12),
                SKAction.fadeIn(withDuration: 0.3)
            ]))
        }

        let cliffhanger = SKLabelNode(text: "\"There's something hidden inside each Slime…\"")
        cliffhanger.fontName = "AvenirNext-MediumItalic"
        cliffhanger.fontSize = 16
        cliffhanger.fontColor = UIColor.systemPurple
        cliffhanger.position = CGPoint(x: centerX, y: cliffY)
        cliffhanger.verticalAlignmentMode = .center
        cliffhanger.horizontalAlignmentMode = .center
        cliffhanger.preferredMaxLayoutWidth = plateWidth * 0.90
        cliffhanger.numberOfLines = 2
        cliffhanger.alpha = 0
        addChild(cliffhanger)
        cliffhanger.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.2),
            SKAction.fadeIn(withDuration: 0.5)
        ]))

        let tex = SKTexture(imageNamed: "genotype_card_purple_thin")
        let ratio = tex.size().width / tex.size().height
        let btnHeight: CGFloat = 80
        let btn = SKSpriteNode(texture: tex)
        btn.texture?.filteringMode = .nearest
        btn.size = CGSize(width: btnHeight * ratio, height: btnHeight)
        btn.name = "continueBtn"
        btn.position = CGPoint(x: centerX, y: btnY)
        btn.alpha = 0
        addChild(btn)

        let arrowTex = SKTexture(imageNamed: "arrow")
        let arrowRatio = arrowTex.size().width / arrowTex.size().height
        let arrowH: CGFloat = 14
        let arrowSprite = SKSpriteNode(texture: arrowTex)
        arrowSprite.texture?.filteringMode = .nearest
        arrowSprite.size = CGSize(width: arrowH * arrowRatio, height: arrowH)
        arrowSprite.position = CGPoint(x: 55, y: -1)
        arrowSprite.name = "continueBtn"
        btn.addChild(arrowSprite)

        let btnLbl = SKLabelNode(text: "Next")
        btnLbl.fontName = "AvenirNext-Bold"
        btnLbl.fontSize = 18
        btnLbl.fontColor = .white
        btnLbl.verticalAlignmentMode = .center
        btnLbl.position = CGPoint(x: -15, y: 0)
        btnLbl.name = "continueBtn"
        btn.addChild(btnLbl)

        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 0.95, duration: 0.8)
        ])
        btn.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.6),
            SKAction.fadeIn(withDuration: 0.4),
            SKAction.repeatForever(breathe)
        ]))
    }

    private func addNameplate(to slime: SlimeNode, isTop: Bool = true, yOverride: CGFloat? = nil) {
        let color = slime.colorPhenotype
        let tex = SKTexture(imageNamed: "genotype_card_\(color.rawValue)")
        let ratio = tex.size().width / tex.size().height
        let cardHeight: CGFloat = 46
        let card = SKSpriteNode(texture: tex)
        card.name = "nameplate"
        card.texture?.filteringMode = .nearest
        card.size = CGSize(width: cardHeight * ratio, height: cardHeight)
        card.position = CGPoint(x: 0, y: yOverride ?? (isTop ? 75 : -70))
        card.zPosition = 5
        let lbl = SKLabelNode(text: color.rawValue.capitalized)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = isCompact ? 14 : 18
        lbl.fontColor = (color == .purple) ? .white : .black
        lbl.verticalAlignmentMode = .center
        card.addChild(lbl)
        slime.addChild(card)
    }
}
