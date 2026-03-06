//
//  Level10.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class Level10Scene: GameScene {
    private var isCompact: Bool { size.width < 500 }
    private var isShortScreen: Bool { size.height < 900 }
    private var useSmallUI: Bool { isCompact || isShortScreen }
    private var navbarHeight: CGFloat { isCompact ? 110 : 90 }
    private var contentWidth: CGFloat { min(size.width - 40, 500) }
    private var plateWidth: CGFloat { min(contentWidth, 700) }
    private var centerX: CGFloat { size.width / 2 }
    private var centerY: CGFloat { size.height / 2 }
    private var cellSpacing: CGFloat { useSmallUI ? 52 : 80 }

    private var usableTop: CGFloat { size.height - navbarHeight }
    private var usableHeight: CGFloat { size.height - navbarHeight - 30 }
    private var groupCenterY: CGFloat { usableTop - usableHeight / 2 }

    private var rowInstruct: CGFloat { useSmallUI ? groupCenterY + 184 : groupCenterY + 273 }
    private var rowCross: CGFloat { useSmallUI ? groupCenterY + 84 : groupCenterY + 133 }
    private var rowGridTop: CGFloat { useSmallUI ? groupCenterY + 13 : groupCenterY + 30  }
    private var rowButtonsTop: CGFloat { useSmallUI ? groupCenterY - 207 : groupCenterY - 303 }
    private var rowButtonsBot: CGFloat { useSmallUI ? groupCenterY - 289 : groupCenterY - 405 }
    private var rowHint: CGFloat { useSmallUI ? groupCenterY - 340 : groupCenterY - 469 }

    private var phase = 1

    private let phenotypeGrid: [[DihybridPhenotype]] = [
        [(.purple, .round), (.purple, .round), (.purple, .round), (.purple, .round)],
        [(.purple, .round), (.purple, .spiky), (.purple, .round), (.purple, .spiky)],
        [(.purple, .round), (.purple, .round), (.white, .round), (.white, .round)],
        [(.purple, .round), (.purple, .spiky), (.white, .round), (.white, .spiky)]
    ]

    private let blanks: [(row: Int, col: Int, pheno: DihybridPhenotype)] = [
        (0, 0, (.purple, .round)),
        (1, 1, (.purple, .spiky)),
        (2, 2, (.white, .round)),
        (3, 3, (.white, .spiky))
    ]
    private var filledBlanks = 0

    private var gridSlimes: [[SlimeNode?]] = []
    private var blankNodes: [String: SKShapeNode] = [:]
    private var phase1Nodes: [SKNode] = []
    private var phase2Nodes: [SKNode] = []

    private var mysteryZone: SKSpriteNode!
    private var choiceCards: [LabCardNode] = []
    private var dragCard: LabCardNode?

    private let phenoSources: [(ColorPhenotype, ShapePhenotype, String)] = [
        (.purple, .round, "Purple Round"),
        (.purple, .spiky, "Purple Spiky"),
        (.white, .round, "White Round"),
        (.white, .spiky, "White Spiky")
    ]
    private var sourceNodes: [SKNode] = []
    private var dragSlimeClone: SlimeNode?
    private var dragPheno: DihybridPhenotype?

    private var instructionPlate: SKSpriteNode!
    private var instructionLabel: SKLabelNode!
    private var headerLabel: SKLabelNode!
    private var headerCross: SKSpriteNode!
    private var parent1Card: SKSpriteNode!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        resetState()
        setupStaticUI()
        buildGrid()
        setupPhase1()
    }

    override func relayout() {
        resetState()
        setupStaticUI()
        buildGrid()
        setupPhase1()
    }

    private func resetState() {
        let hint = childNode(withName: "hintToken")
        hint?.removeFromParent()
        removeAllChildren()
        if let hint = hint { addChild(hint) }
        
        phase = 1
        filledBlanks = 0
        gridSlimes.removeAll()
        blankNodes.removeAll()
        phase1Nodes.removeAll()
        phase2Nodes.removeAll()
        sourceNodes.removeAll()
        choiceCards.removeAll()
        dragCard = nil
        dragSlimeClone = nil
        dragPheno = nil
    }

    private func setupStaticUI() {
        let names = ["instructionPlate", "p1Card", "headerCross"]
        for name in names { enumerateChildNodes(withName: name) { node, _ in node.removeFromParent() } }

        instructionPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        instructionPlate.name = "instructionPlate"
        instructionPlate.texture?.filteringMode = .nearest
        instructionPlate.size = CGSize(width: plateWidth, height: useSmallUI ? 100 : 140)
        instructionPlate.position = CGPoint(x: centerX, y: rowInstruct)
        addChild(instructionPlate)

        instructionLabel = SKLabelNode(text: "Step 1: Identify the mystery parent!")
        instructionLabel.fontName = "AvenirNext-Bold"
        instructionLabel.fontSize = useSmallUI ? 16 : 20
        instructionLabel.fontColor = .black
        instructionLabel.position = .zero
        instructionLabel.verticalAlignmentMode = .center
        instructionLabel.horizontalAlignmentMode = .center
        instructionLabel.preferredMaxLayoutWidth = plateWidth * 0.70
        instructionLabel.numberOfLines = 2
        instructionLabel.zPosition = 1
        instructionLabel.name = "instructionLabel"
        instructionPlate.addChild(instructionLabel)

        let cardTex = SKTexture(imageNamed: "genotype_card_purple")
        let cardRatio = cardTex.size().width / cardTex.size().height
        let cardH: CGFloat = useSmallUI ? 36 : 50
        let cardGap = useSmallUI ? size.width * 0.20 : size.width * 0.10

        parent1Card = SKSpriteNode(texture: cardTex)
        parent1Card.name = "p1Card"
        parent1Card.texture?.filteringMode = .nearest
        parent1Card.size = CGSize(width: cardH * cardRatio, height: cardH)
        parent1Card.position = CGPoint(x: centerX - cardGap, y: rowCross)
        addChild(parent1Card)

        let p1Lbl = SKLabelNode(text: "BbRr")
        p1Lbl.fontName = "AvenirNext-Bold"
        p1Lbl.fontSize = useSmallUI ? 18 : 24
        p1Lbl.fontColor = .white
        p1Lbl.verticalAlignmentMode = .center
        parent1Card.addChild(p1Lbl)

        let crossTex = SKTexture(imageNamed: "cross")
        let crossRatio = crossTex.size().width / crossTex.size().height
        let crossH: CGFloat = useSmallUI ? 30 : 44
        headerCross = SKSpriteNode(texture: crossTex)
        headerCross.name = "headerCross"
        headerCross.texture?.filteringMode = .nearest
        headerCross.size = CGSize(width: crossH * crossRatio, height: crossH)
        headerCross.position = CGPoint(x: centerX, y: rowCross)
        addChild(headerCross)
    }

    private func buildGrid() {
        enumerateChildNodes(withName: "gridSlime") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "blankZone") { node, _ in node.removeFromParent() }
        gridSlimes = Array(repeating: Array(repeating: nil, count: 4), count: 4)

        let slimeSize: CGFloat = useSmallUI ? 42 : 66
        let blankSize: CGFloat = useSmallUI ? 48 : 76
        let blankFont: CGFloat = useSmallUI ? 22 : 32

        for (row, rowData) in phenotypeGrid.enumerated() {
            for (col, pheno) in rowData.enumerated() {
                let isBlank = blanks.contains(where: { $0.row == row && $0.col == col })
                let pos = cellPos(row: row, col: col)

                if isBlank {
                    let zone = SKShapeNode(rectOf: CGSize(width: blankSize, height: blankSize), cornerRadius: 12)
                    zone.name = "blankZone"
                    zone.fillColor = UIColor(white: 0.86, alpha: 1)
                    zone.strokeColor = UIColor(white: 0.6, alpha: 1)
                    zone.lineWidth = 1.5
                    zone.position = pos
                    addChild(zone)
                    blankNodes["\(row)_\(col)"] = zone

                    let q = SKLabelNode(text: "?")
                    q.fontName = "AvenirNext-Bold"; q.fontSize = blankFont
                    q.fontColor = .gray; q.verticalAlignmentMode = .center
                    zone.addChild(q)
                } else {
                    let slime = SlimeNode(color: pheno.color, shape: pheno.shape, size: slimeSize, isAnimated: false)
                    slime.name = "gridSlime"
                    slime.position = pos
                    slime.alpha = 0
                    addChild(slime)
                    gridSlimes[row][col] = slime

                    slime.run(SKAction.sequence([
                        SKAction.wait(forDuration: Double(row * 4 + col) * 0.025),
                        SKAction.fadeIn(withDuration: 0.2)
                    ]))
                }
            }
        }
    }

    private func cellPos(row: Int, col: Int) -> CGPoint {
        CGPoint(
            x: centerX - cellSpacing * 1.5 + CGFloat(col) * cellSpacing,
            y: rowGridTop - CGFloat(row) * cellSpacing
        )
    }

    private func setupPhase1() {
        enumerateChildNodes(withName: "mysteryZone") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "phase1Hint") { node, _ in node.removeFromParent() }
        choiceCards.removeAll()

        let zoneSize: CGFloat = useSmallUI ? 70 : 100
        let cardGap = useSmallUI ? size.width * 0.20 : size.width * 0.10

        mysteryZone = SKSpriteNode(imageNamed: "slot_empty")
        mysteryZone.name = "mysteryZone"
        mysteryZone.texture?.filteringMode = .nearest
        mysteryZone.size = CGSize(width: zoneSize, height: zoneSize)
        mysteryZone.color = .clear
        mysteryZone.colorBlendFactor = 0.0
        mysteryZone.position = CGPoint(x: centerX + cardGap, y: rowCross)
        addChild(mysteryZone)
        phase1Nodes.append(mysteryZone)

        let qLbl = SKLabelNode(text: "???")
        qLbl.fontName = "AvenirNext-Bold"; qLbl.fontSize = useSmallUI ? 18 : 26
        qLbl.fontColor = .gray; qLbl.verticalAlignmentMode = .center
        mysteryZone.addChild(qLbl)

        let options = ["BBRr", "BbRr", "bbrr"]
        let cardH: CGFloat = useSmallUI ? 42 : 80
        let spacing: CGFloat = useSmallUI ? min(100, contentWidth * 0.28) : min(220, size.width * 0.35)
        let startX = centerX - spacing
        for (i, label) in options.enumerated() {
            let card = LabCardNode(text: label, height: cardH)
            card.name = "phase1Card"
            card.position = CGPoint(x: startX + CGFloat(i) * spacing, y: rowButtonsTop)
            addChild(card)
            choiceCards.append(card)
            phase1Nodes.append(card)

            let breathe = SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 0.8),
                SKAction.scale(to: 0.95, duration: 0.8)
            ]))
            card.run(breathe)
        }
    }

    private func setupPhase2() {
        instructionLabel.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.run {
                self.instructionLabel.text = "Step 2: Fill in the missing offspring!"
                self.instructionLabel.fontColor = UIColor(red: 0.3, green: 0.2, blue: 0.7, alpha: 1)
            },
            SKAction.fadeIn(withDuration: 0.2)
        ]))

        let btnW: CGFloat = useSmallUI ? 130 : 177
        let btnH: CGFloat = useSmallUI ? 65 : 87
        let colGap: CGFloat = useSmallUI ? min(140, size.width * 0.35) : min(220, size.width * 0.40)
        let cols: [CGFloat] = [centerX - colGap / 2, centerX + colGap / 2]
        let rows: [CGFloat] = [rowButtonsTop, rowButtonsBot]

        let breathe = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 0.95, duration: 0.8)
        ]))

        for (i, (color, shape, label)) in phenoSources.enumerated() {
            let col = i % 2
            let row = i / 2
            let tile = SKNode()
            let isPurple = (color == .purple)

            let cardTex = SKTexture(imageNamed: isPurple ? "genotype_card_purple" : "genotype_card_white")
            let bg = SKSpriteNode(texture: cardTex)
            bg.texture?.filteringMode = .nearest
            bg.size = CGSize(width: btnW, height: btnH)
            tile.addChild(bg)

            let lbl = SKLabelNode(text: label)
            lbl.fontName = "AvenirNext-Bold"; lbl.fontSize = useSmallUI ? 14 : 18
            lbl.fontColor = isPurple ? .white : UIColor.black
            lbl.verticalAlignmentMode = .center
            lbl.position = CGPoint(x: useSmallUI ? -18 : -26, y: 0)
            tile.addChild(lbl)

            let indSize: CGFloat = useSmallUI ? 38 : 55
            let indicator = SlimeNode(color: color, shape: shape, size: indSize, isAnimated: false)
            indicator.setScale(0.75)
            indicator.position = CGPoint(x: useSmallUI ? 36 : 52, y: 0)
            tile.addChild(indicator)

            tile.position = CGPoint(x: cols[col], y: rows[row])
            tile.name = "pheno_\(i)"
            addChild(tile)
            sourceNodes.append(tile)
            phase2Nodes.append(tile)

            tile.run(breathe)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)

        if phase == 1 {
            for card in choiceCards {
                if hit === card || hit.inParentHierarchy(card) {
                    let clone = LabCardNode(text: card.labelText, height: useSmallUI ? 42 : 80)
                    clone.position = card.position
                    clone.zPosition = 20
                    addChild(clone)
                    dragCard = clone
                    return
                }
            }
        } else {
            for (i, tile) in sourceNodes.enumerated() {
                if hit === tile || hit.inParentHierarchy(tile) {
                    let (color, shape, _) = phenoSources[i]
                    let clone = SlimeNode(color: color, shape: shape, size: useSmallUI ? 42 : 66, isAnimated: true)
                    clone.position = tile.position
                    clone.zPosition = 20
                    addChild(clone)
                    dragSlimeClone = clone
                    dragPheno = (color, shape)
                    return
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        dragCard?.position = loc
        dragSlimeClone?.position = loc

        for blank in blanks {
            let bPos = cellPos(row: blank.row, col: blank.col)
            let near = hypot(loc.x - bPos.x, loc.y - bPos.y) < cellSpacing * 0.6
            blankNodes["\(blank.row)_\(blank.col)"]?.strokeColor = near
                ? UIColor.systemYellow
                : UIColor(white: 0.6, alpha: 1)
        }

        if phase == 1 {
            let dist = hypot(loc.x - mysteryZone.position.x, loc.y - mysteryZone.position.y)
            mysteryZone.texture = SKTexture(imageNamed: dist < 50 ? "slot_current" : "slot_empty")
            mysteryZone.texture?.filteringMode = .nearest
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        for blank in blanks {
            blankNodes["\(blank.row)_\(blank.col)"]?.strokeColor = UIColor(white: 0.6, alpha: 1)
        }
        mysteryZone?.texture = SKTexture(imageNamed: "slot_empty")
        mysteryZone?.texture?.filteringMode = .nearest

        if phase == 1, let card = dragCard {
            dragCard = nil
            let dist = hypot(loc.x - mysteryZone.position.x, loc.y - mysteryZone.position.y)
            if dist < 55 {
                checkPhase1Answer(card: card)
            } else {
                card.removeFromParent()
            }
        }

        if phase == 2, let clone = dragSlimeClone, let pheno = dragPheno {
            dragSlimeClone = nil
            dragPheno = nil

            var bestBlank: (row: Int, col: Int, pheno: DihybridPhenotype)? = nil
            var bestDist = CGFloat.infinity
            for b in blanks {
                guard blankNodes["\(b.row)_\(b.col)"] != nil else { continue }
                let d = hypot(loc.x - cellPos(row: b.row, col: b.col).x, loc.y - cellPos(row: b.row, col: b.col).y)
                if d < bestDist { bestDist = d; bestBlank = b }
            }

            if let blank = bestBlank, bestDist < cellSpacing * 0.7 {
                checkPhase2Answer(clone: clone, droppedPheno: pheno, onto: blank)
            } else {
                clone.removeFromParent()
            }
        }
        
        let hit = atPoint(loc)
        if hit.name == "finishBtn" {
            completeLevel()
        }
    }

    private func checkPhase1Answer(card: LabCardNode) {
        if card.labelText == "BbRr" {
            playCorrectSound()
            playSlimeSound()
            card.removeFromParent()
            mysteryZone.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))

            let cardTex = SKTexture(imageNamed: "genotype_card_purple")
            let cardRatio = cardTex.size().width / cardTex.size().height
            let cardH: CGFloat = useSmallUI ? 36 : 50
            let cardGap = useSmallUI ? size.width * 0.20 : size.width * 0.10
            let mysteryCard = SKSpriteNode(texture: cardTex)
            mysteryCard.texture?.filteringMode = .nearest
            mysteryCard.size = CGSize(width: cardH * cardRatio, height: cardH)
            mysteryCard.position = CGPoint(x: centerX + cardGap, y: rowCross)
            mysteryCard.alpha = 0
            addChild(mysteryCard)

            let mLbl = SKLabelNode(text: "BbRr")
            mLbl.fontName = "AvenirNext-Bold"
            mLbl.fontSize = useSmallUI ? 18 : 24
            mLbl.fontColor = .white
            mLbl.verticalAlignmentMode = .center
            mysteryCard.addChild(mLbl)
            
            mysteryCard.run(SKAction.fadeIn(withDuration: 0.3))

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.phase1Nodes.forEach { $0.removeFromParent() }
                self.phase = 2
                self.setupPhase2()
            }
        } else {
            card.removeFromParent()
            showWrongAnswer(explanation:
                "The offspring show a 9:3:3:1 ratio — that's the signature of BbRr × BbRr!\n" +
                "Both parents must carry one dominant and one recessive allele for each trait."
            )
        }
    }

    private func checkPhase2Answer(
        clone: SlimeNode,
        droppedPheno: DihybridPhenotype,
        onto blank: (row: Int, col: Int, pheno: DihybridPhenotype)
    ) {
        let expected = blank.pheno
        let correct = droppedPheno.color == expected.color && droppedPheno.shape == expected.shape
        let key = "\(blank.row)_\(blank.col)"

        if correct {
            playCorrectSound()
            playSlimeSound()
            clone.removeFromParent()
            blankNodes[key]?.removeFromParent()
            blankNodes.removeValue(forKey: key)

            let slime = SlimeNode(color: expected.color, shape: expected.shape, size: useSmallUI ? 42 : 66, isAnimated: false)
            slime.setScale(0.1)
            slime.alpha = 0
            slime.position = cellPos(row: blank.row, col: blank.col)
            addChild(slime)
            slime.run(SKAction.group([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ]))
            gridSlimes[blank.row][blank.col] = slime

            filledBlanks += 1
            if filledBlanks == blanks.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showCelebration()
                }
            }
        } else {
            clone.run(SKAction.sequence([
                SKAction.moveBy(x: -8, y: 0, duration: 0.05),
                SKAction.moveBy(x: 8, y: 0, duration: 0.05),
                SKAction.moveBy(x: -8, y: 0, duration: 0.05),
                SKAction.moveBy(x: 8, y: 0, duration: 0.05),
                SKAction.removeFromParent()
            ]))
            let pheno = blank.pheno
            let colorName = pheno.color == .purple ? "Purple" : "White"
            let shapeName = pheno.shape == .round ? "Round" : "Spiky"
            showWrongAnswer(explanation:
                "This cell's parents pass \(colorName.lowercased()) color and \(shapeName.lowercased()) shape alleles.\n" +
                "The offspring here should be \(colorName) and \(shapeName)!"
            )
        }
    }

    private func showCelebration() {
        for row in gridSlimes { for slime in row where slime != nil {
            slime?.playCorrectAnimation()
        }}

        phase2Nodes.forEach { $0.removeFromParent() }

        let congrats = makeLabel("🎉 The Final Lab Complete! 🎉", fontSize: useSmallUI ? 16 : 22, at: CGPoint(x: centerX, y: rowButtonsTop), bold: true)
        congrats.fontColor = UIColor(red: 0.55, green: 0.27, blue: 0.88, alpha: 1)
        congrats.alpha = 0
        addChild(congrats)

        let finishBtn = createFinishButton()
        finishBtn.position = CGPoint(x: centerX, y: rowButtonsBot)
        finishBtn.alpha = 0
        addChild(finishBtn)

        congrats.run(SKAction.fadeIn(withDuration: 0.5))
        finishBtn.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
    }
    
    private func createFinishButton() -> SKSpriteNode {
        let tex = SKTexture(imageNamed: "genotype_card_purple_thin")
        let btnRatio = tex.size().width / tex.size().height
        let btnH: CGFloat = useSmallUI ? 60 : 80
        let btn = SKSpriteNode(texture: tex)
        btn.texture?.filteringMode = .nearest
        btn.size = CGSize(width: btnH * btnRatio, height: btnH)
        btn.name = "finishBtn"

        let arrowTex = SKTexture(imageNamed: "arrow")
        let arrowRatio = arrowTex.size().width / arrowTex.size().height
        let arrowH: CGFloat = useSmallUI ? 14 : 20
        let arrowSprite = SKSpriteNode(texture: arrowTex)
        arrowSprite.texture?.filteringMode = .nearest
        arrowSprite.size = CGSize(width: arrowH * arrowRatio, height: arrowH)
        arrowSprite.position = CGPoint(x: useSmallUI ? 35 : 45, y: -1)
        arrowSprite.name = "finishBtn"
        btn.addChild(arrowSprite)

        let btnLbl = SKLabelNode(text: "Finish")
        btnLbl.fontName = "AvenirNext-Bold"
        btnLbl.fontSize = useSmallUI ? 18 : 24
        btnLbl.fontColor = .white
        btnLbl.verticalAlignmentMode = .center
        btnLbl.position = CGPoint(x: useSmallUI ? -15 : -20, y: 0)
        btnLbl.name = "finishBtn"
        btn.addChild(btnLbl)

        btn.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 0.95, duration: 0.8)
        ])))
        return btn
    }
    


    private func makeLabel(_ text: String, fontSize: CGFloat, at position: CGPoint, color: UIColor = .darkGray, bold: Bool = false) -> SKLabelNode {
        let lbl = SKLabelNode(text: text)
        lbl.fontName = bold ? "AvenirNext-Bold" : "AvenirNext-Medium"
        lbl.fontSize = fontSize; lbl.fontColor = color
        lbl.position = position
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center
        lbl.numberOfLines = 3
        return lbl
    }
}

class LabCardNode: SKNode {
    let labelText: String

    init(text: String, height: CGFloat = 80) {
        self.labelText = text
        super.init()

        let tex = SKTexture(imageNamed: "genotype_card_purple")
        let cardRatio = tex.size().width / tex.size().height
        let bg = SKSpriteNode(texture: tex)
        bg.texture?.filteringMode = .nearest
        bg.size = CGSize(width: height * cardRatio, height: height)
        addChild(bg)

        let lbl = SKLabelNode(text: text)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = height < 60 ? 18 : 24
        lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        addChild(lbl)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Error!") }
}
