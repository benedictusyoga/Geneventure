//
//  Level9.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class Level9Scene: GameScene {
    private var isCompact: Bool { size.width < 500 }
    private var isShortScreen: Bool { size.height < 900 }
    private var useSmallUI: Bool { isCompact || isShortScreen }
    private var navbarHeight: CGFloat { isCompact ? 110 : 90 }
    private var contentWidth: CGFloat { min(size.width - 40, 500) }
    private var plateWidth: CGFloat { min(contentWidth, 700) }
    private var centerX: CGFloat { size.width / 2 }
    private var centerY: CGFloat { size.height / 2 }

    private var usableTop: CGFloat { size.height - navbarHeight }
    private var usableHeight: CGFloat { size.height - navbarHeight - 30 }
    private var groupCenterY: CGFloat { usableTop - usableHeight / 2 }

    private var rowInstruct: CGFloat { useSmallUI ? groupCenterY + 211 : groupCenterY + 303 }
    private var rowCross: CGFloat { useSmallUI ? groupCenterY + 128 : groupCenterY + 188 }
    private var rowGridTop: CGFloat { useSmallUI ? groupCenterY + 74 : groupCenterY + 110 }
    private var rowButtonsTop: CGFloat { useSmallUI ? groupCenterY - 151 : groupCenterY - 227 }
    private var rowButtonsBot: CGFloat { useSmallUI ? groupCenterY - 228 : groupCenterY - 329 }
    private var rowRatio: CGFloat { size.height * 0.10 }
    private var rowContinue: CGFloat { size.height * 0.05 }

    private let phenotypeGrid: [[DihybridPhenotype]] = [
        [(.purple, .round), (.purple, .round), (.purple, .round), (.purple, .round)],
        [(.purple, .round), (.purple, .spiky), (.purple, .round), (.purple, .spiky)],
        [(.purple, .round), (.purple, .round), (.white, .round), (.white, .round)],
        [(.purple, .round), (.purple, .spiky), (.white, .round), (.white, .spiky)]
    ]

    private var slimeGrid: [[SlimeNode]] = []
    private var categoryButtons: [SKNode] = []
    private var instructionPlate: SKSpriteNode!
    private var instructionLabel: SKLabelNode!
    private var staticNodes: [SKNode] = []

    private var phase = 1
    private var revealedCount = 0
    private var isProcessingTap = false

    private struct Category {
        let color: ColorPhenotype
        let shape: ShapePhenotype
        let label: String
        let count: Int
    }
    private let categories: [Category] = [
        Category(color: .purple, shape: .round, label: "Purple\nRound", count: 9),
        Category(color: .purple, shape: .spiky, label: "Purple\nSpiky", count: 3),
        Category(color: .white, shape: .round, label: "White\nRound", count: 3),
        Category(color: .white, shape: .spiky, label: "White\nSpiky", count: 1)
    ]

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        resetState()
        setupStaticUI()
        buildSlimeGrid()
        buildCategoryButtons()
    }

    override func relayout() {
        resetState()
        setupStaticUI()
        buildSlimeGrid()
        buildCategoryButtons()
    }

    private func resetState() {
        let hint = childNode(withName: "hintToken")
        hint?.removeFromParent()
        removeAllChildren()
        if let hint = hint { addChild(hint) }
        
        phase = 1
        revealedCount = 0
        isProcessingTap = false
        slimeGrid.removeAll()
        categoryButtons.removeAll()
        staticNodes.removeAll()
    }

    private func setupStaticUI() {
        let names = ["instructionPlate", "crossSprite", "alleleCard"]
        for name in names { enumerateChildNodes(withName: name) { node, _ in node.removeFromParent() } }

        instructionPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        instructionPlate.name = "instructionPlate"
        instructionPlate.texture?.filteringMode = .nearest
        instructionPlate.size = CGSize(width: plateWidth, height: useSmallUI ? 100 : 140)
        instructionPlate.position = CGPoint(x: centerX, y: rowInstruct)
        addChild(instructionPlate)

        instructionLabel = SKLabelNode(text: "Tap each category to highlight matching offspring!")
        instructionLabel.fontName = "AvenirNext-Medium"
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
        staticNodes.append(instructionPlate)

        let cardH: CGFloat = useSmallUI ? 36 : 50
        let gap = useSmallUI ? size.width * 0.20 : size.width * 0.10
        for xPos in [centerX - gap, centerX + gap] {
            let cardTex = SKTexture(imageNamed: "genotype_card_purple")
            let cardRatio = cardTex.size().width / cardTex.size().height
            let card = SKSpriteNode(texture: cardTex)
            card.name = "alleleCard"
            card.texture?.filteringMode = .nearest
            card.size = CGSize(width: cardH * cardRatio, height: cardH)
            card.position = CGPoint(x: xPos, y: rowCross)
            addChild(card)
            staticNodes.append(card)

            let lbl = SKLabelNode(text: "BbRr")
            lbl.fontName = "AvenirNext-Bold"
            lbl.fontSize = useSmallUI ? 18 : 24
            lbl.fontColor = .white
            lbl.verticalAlignmentMode = .center
            card.addChild(lbl)
        }

        let crossTex = SKTexture(imageNamed: "cross")
        let crossRatio = crossTex.size().width / crossTex.size().height
        let crossH: CGFloat = useSmallUI ? 30 : 44
        let crossSprite = SKSpriteNode(texture: crossTex)
        crossSprite.name = "crossSprite"
        crossSprite.texture?.filteringMode = .nearest
        crossSprite.size = CGSize(width: crossH * crossRatio, height: crossH)
        crossSprite.position = CGPoint(x: centerX, y: rowCross)
        addChild(crossSprite)
        staticNodes.append(crossSprite)
    }

    private func buildSlimeGrid() {
        enumerateChildNodes(withName: "gridSlime") { node, _ in node.removeFromParent() }
        slimeGrid.removeAll()

        let spacing: CGFloat = useSmallUI ? 52 : 80
        let slimeSize: CGFloat = useSmallUI ? 42 : 66
        let startX = centerX - spacing * 1.5
        let startY = rowGridTop

        for (row, rowData) in phenotypeGrid.enumerated() {
            var rowSlimes: [SlimeNode] = []
            for (col, phenotype) in rowData.enumerated() {
                let slime = SlimeNode(color: phenotype.color, shape: phenotype.shape, size: slimeSize, isAnimated: false)
                slime.name = "gridSlime"
                slime.position = CGPoint(
                    x: startX + CGFloat(col) * spacing,
                    y: startY - CGFloat(row) * spacing
                )
                slime.alpha = 0
                addChild(slime)
                rowSlimes.append(slime)
                slime.run(SKAction.sequence([
                    SKAction.wait(forDuration: Double(row * 4 + col) * 0.03),
                    SKAction.fadeIn(withDuration: 0.2)
                ]))
            }
            slimeGrid.append(rowSlimes)
        }
    }

    private func buildCategoryButtons() {
        let btnW: CGFloat = useSmallUI ? 130 : 177
        let btnH: CGFloat = useSmallUI ? 65 : 87
        let colGap: CGFloat = useSmallUI ? min(140, size.width * 0.35) : min(220, size.width * 0.40)
        let cols: [CGFloat] = [centerX - colGap / 2, centerX + colGap / 2]
        let rows: [CGFloat] = [rowButtonsTop, rowButtonsBot]

        for (i, cat) in categories.enumerated() {
            let col = i % 2
            let row = i / 2
            let btn = SKNode()
            btn.name = "cat_\(i)"

            let isPurple = (cat.color == .purple)
            let cardTex = SKTexture(imageNamed: isPurple ? "genotype_card_purple" : "genotype_card_white")
            let bg = SKSpriteNode(texture: cardTex)
            bg.texture?.filteringMode = .nearest
            bg.size = CGSize(width: btnW, height: btnH)
            bg.name = "cat_bg"
            btn.addChild(bg)

            let lbl = SKLabelNode(text: cat.label)
            lbl.fontName = "AvenirNext-Bold"
            lbl.fontSize = useSmallUI ? 14 : 18
            lbl.fontColor = isPurple ? .white : UIColor.black
            lbl.verticalAlignmentMode = .center
            lbl.horizontalAlignmentMode = .center
            lbl.numberOfLines = 2
            lbl.preferredMaxLayoutWidth = useSmallUI ? 70 : 100
            lbl.position = CGPoint(x: useSmallUI ? -18 : -26, y: 0)
            btn.addChild(lbl)

            let indSize: CGFloat = useSmallUI ? 38 : 55
            let indicator = SlimeNode(color: cat.color, shape: cat.shape, size: indSize, isAnimated: false)
            indicator.setScale(0.80)
            indicator.position = CGPoint(x: useSmallUI ? 36 : 52, y: useSmallUI ? 4 : 6)
            btn.addChild(indicator)

            btn.position = CGPoint(x: cols[col], y: rows[row])
            btn.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 0.8),
                SKAction.scale(to: 0.95, duration: 0.8)
            ])))
            addChild(btn)
            categoryButtons.append(btn)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let hit = atPoint(touch.location(in: self))

        if phase == 1 {
            for (i, btn) in categoryButtons.enumerated() {
                if hit === btn || hit.inParentHierarchy(btn) {
                    tapCategory(index: i)
                    return
                }
            }
        } else {
            if hit.name == "nextBtn" { completeLevel() }
        }
    }

    private func tapCategory(index: Int) {
        guard !isProcessingTap else { return }
        let isAlreadyRevealed = categoryButtons[index].childNode(withName: "badge") != nil

        isProcessingTap = true
        let cat = categories[index]

        for (row, rowSlimes) in slimeGrid.enumerated() {
            for (col, slime) in rowSlimes.enumerated() {
                let p = phenotypeGrid[row][col]
                let matches = p.color == cat.color && p.shape == cat.shape
                slime.run(SKAction.fadeAlpha(to: matches ? 1.0 : 0.2, duration: 0.2))
            }
        }

        if !isAlreadyRevealed {
            playCorrectSound()
            let badge = SKShapeNode(circleOfRadius: useSmallUI ? 16 : 22)
            badge.fillColor = UIColor.systemGreen
            badge.strokeColor = .clear
            badge.position = CGPoint(x: useSmallUI ? 52 : 74, y: useSmallUI ? 22 : 32)
            badge.name = "badge"
            let bLbl = SKLabelNode(text: "\(cat.count)")
            bLbl.fontName = "AvenirNext-Black"
            bLbl.fontSize = useSmallUI ? 16 : 22
            bLbl.fontColor = .white
            bLbl.verticalAlignmentMode = .center
            badge.addChild(bLbl)
            categoryButtons[index].addChild(badge)

            revealedCount += 1
        }

        let isComplete = revealedCount == 4

        if isComplete && !isAlreadyRevealed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.transitionToResult()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                for row in self.slimeGrid { for slime in row {
                    slime.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
                }}
                self.isProcessingTap = false
            }
        }
    }

    private func transitionToResult() {
        phase = 2
        let fade = SKAction.fadeOut(withDuration: 0.4)
        
        staticNodes.forEach { $0.run(fade) }
        categoryButtons.forEach { $0.run(fade) }
        for row in slimeGrid {
            for slime in row { slime.run(fade) }
        }
        
        run(SKAction.wait(forDuration: 0.5)) {
            self.staticNodes.forEach { $0.removeFromParent() }
            self.categoryButtons.forEach { $0.removeFromParent() }
            for row in self.slimeGrid {
                for slime in row { slime.removeFromParent() }
            }
            self.showResultPage()
        }
    }

    private func showResultPage() {
        let plateY: CGFloat = isCompact ? groupCenterY + 185 : centerY + 180
        let ratioY: CGFloat = isCompact ? groupCenterY + 55 : centerY + 50
        let subY: CGFloat = isCompact ? groupCenterY - 30 : centerY - 45
        let descY: CGFloat = isCompact ? groupCenterY - 105 : centerY - 130
        let btnY: CGFloat = isCompact ? groupCenterY - 180 : rowContinue + 60

        let resultPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        resultPlate.texture?.filteringMode = .nearest
        resultPlate.size = CGSize(width: plateWidth, height: isCompact ? 100 : 120)
        resultPlate.position = CGPoint(x: centerX, y: plateY)
        resultPlate.alpha = 0
        addChild(resultPlate)

        let resultTitle = makeLabel("The Dihybrid Secret", fontSize: isCompact ? 18 : 26, at: .zero, bold: true)
        resultTitle.fontColor = .black
        resultTitle.zPosition = 1
        resultPlate.addChild(resultTitle)

        let ratioLbl = makeLabel("9 : 3 : 3 : 1", fontSize: isCompact ? 38 : 72, at: CGPoint(x: centerX, y: ratioY), bold: true)
        ratioLbl.fontColor = UIColor(red: 0.35, green: 0.15, blue: 0.75, alpha: 1)
        ratioLbl.alpha = 0
        addChild(ratioLbl)

        let subLbl = makeLabel("Purple Round : Purple Spiky : White Round : White Spiky", fontSize: isCompact ? 14 : 22, at: CGPoint(x: centerX, y: subY), color: UIColor.systemGray)
        subLbl.preferredMaxLayoutWidth = contentWidth
        subLbl.alpha = 0
        addChild(subLbl)

        let description = makeLabel("This perfect ratio reveals how two different traits\ninherit independently from each other!", fontSize: isCompact ? 13 : 20, at: CGPoint(x: centerX, y: descY))
        description.preferredMaxLayoutWidth = contentWidth
        description.alpha = 0
        addChild(description)

        resultPlate.run(SKAction.fadeIn(withDuration: 0.4))
        ratioLbl.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.scale(to: 1.1, duration: 0.25).reversed()
            ])
        ]))
        subLbl.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: 0.4)]))
        description.run(SKAction.sequence([SKAction.wait(forDuration: 0.8), SKAction.fadeIn(withDuration: 0.4)]))

        let tex = SKTexture(imageNamed: "genotype_card_purple_thin")
        let btnRatio = tex.size().width / tex.size().height
        let btnH: CGFloat = isCompact ? 60 : 80
        let btn = SKSpriteNode(texture: tex)
        btn.texture?.filteringMode = .nearest
        btn.size = CGSize(width: btnH * btnRatio, height: btnH)
        btn.name = "nextBtn"
        btn.position = CGPoint(x: centerX, y: btnY)
        btn.alpha = 0
        addChild(btn)

        let arrowTex = SKTexture(imageNamed: "arrow")
        let arrowRatio = arrowTex.size().width / arrowTex.size().height
        let arrowH: CGFloat = isCompact ? 14 : 18
        let arrowSprite = SKSpriteNode(texture: arrowTex)
        arrowSprite.texture?.filteringMode = .nearest
        arrowSprite.size = CGSize(width: arrowH * arrowRatio, height: arrowH)
        arrowSprite.position = CGPoint(x: isCompact ? 36 : 45, y: -1)
        arrowSprite.name = "nextBtn"
        btn.addChild(arrowSprite)

        let btnLbl = SKLabelNode(text: "Finish")
        btnLbl.fontName = "AvenirNext-Bold"
        btnLbl.fontSize = isCompact ? 18 : 24
        btnLbl.fontColor = .white
        btnLbl.verticalAlignmentMode = .center
        btnLbl.position = CGPoint(x: isCompact ? -15 : -20, y: 0)
        btnLbl.name = "nextBtn"
        btn.addChild(btnLbl)

        btn.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeIn(withDuration: 0.4),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 0.8),
                SKAction.scale(to: 0.95, duration: 0.8)
            ]))
        ]))
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
