//
//  Level5.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class Level5Scene: GameScene {
    private var centerX: CGFloat { size.width / 2 }
    private var centerY: CGFloat { size.height / 2 }
    private let cellSize: CGFloat = 110

    private var rowInstruct: CGFloat { size.height * 0.74 }
    private var rowCross: CGFloat { size.height * 0.65 }
    private var rowGridTop: CGFloat { size.height * 0.58 }
    private var rowMagnifier: CGFloat { size.height * 0.29 }
    private var rowTiles: CGFloat { size.height * 0.16 }
    private var rowDoneBtn: CGFloat { size.height * 0.20 }
    private var rowProgress: CGFloat { size.height * 0.05 }
    
    private var gridNode: PunnettGridNode!
    
    private var phase = 1
    private var tooltipNode: SKNode?
    private var magnifier: SKSpriteNode!
    private var draggingMagnifier = false
    private var hoveredCell: PunnettCellNode?
    private var instructionLabel: SKLabelNode!
    private var instructionPlate: SKSpriteNode!
    
    private typealias Question = (text: String, answer: Int, explanation: String)
    private let questions: [Question] = [
        (
            "How many cells show BB?",
            1,
            "Only 1 out of 4 cells shows BB — top-left.\nBoth parents passed their dominant B allele."
        ),
        (
            "How many cells show bb (White Slime)?",
            1,
            "Only 1 cell shows bb — bottom-right.\nBoth parents passed their recessive b allele."
        ),
        (
            "How many offspring could be Purple?",
            3,
            "Three cells have at least one B: BB, Bb, Bb.\nOnly bb turns White. That's the famous 3:1 ratio!"
        )
    ]
    private var currentQuestion = 0
    private var questionLabel: SKLabelNode!
    private var progressLabel: SKLabelNode!
    private var dropZone: SKSpriteNode!
    private var dropZoneLabel: SKLabelNode!
    private var numberTiles: [NumberTileNode] = []
    private var tileHomes: [CGPoint] = []
    private var draggingTile: NumberTileNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        resetState()
        setupGrid()
        setupMagnifier()
        setupInstruction()
    }

    override func relayout() {
        resetState()
        setupGrid()
        setupMagnifier()
        setupInstruction()
    }
    
    private func resetState() {
        let hint = childNode(withName: "hintToken")
        hint?.removeFromParent()
        removeAllChildren()
        if let hint = hint { addChild(hint) }
        
        phase = 1
        numberTiles.removeAll()
        tileHomes.removeAll()
        currentQuestion = 0
        draggingTile = nil
        draggingMagnifier = false
        hoveredCell = nil
        tooltipNode?.removeFromParent()
        tooltipNode = nil
    }
    
    private func setupGrid() {
        enumerateChildNodes(withName: "punnettGrid") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "crossLabel") { node, _ in node.removeFromParent() }

        let alleles: [Allele] = [.dominant, .recessive]
        gridNode = PunnettGridNode(
            rowAlleles: alleles,
            colAlleles: alleles,
            cellSize: cellSize,
            filled: true
        )
        gridNode.name = "punnettGrid"
        let gridW = CGFloat(alleles.count) * cellSize
        let gridH = CGFloat(alleles.count) * cellSize

        let gridCenterY = (rowCross + rowMagnifier) / 2
        gridNode.position = CGPoint(
            x: centerX - gridW / 2,
            y: gridCenterY - gridH / 2
        )
        addChild(gridNode)

        for row in gridNode.cells {
            for cell in row {
                cell.onTap = { [weak self] in
                    guard self?.phase == 1 else { return }
                    self?.showTooltip(for: cell)
                }
            }
        }

        let crossLabel = makeLabel(
            "Bb × Bb",
            fontSize: 20,
            at: CGPoint(x: centerX, y: gridCenterY + gridH / 2 + 48),
            bold: true
        )
        crossLabel.name = "crossLabel"
        addChild(crossLabel)
    }

    
    private func setupMagnifier() {
        enumerateChildNodes(withName: "magnifier") { node, _ in node.removeFromParent() }

        let sprite = SKSpriteNode(imageNamed: "magnifier")
        sprite.texture?.filteringMode = .nearest
        sprite.size = CGSize(width: 120, height: 120)
        sprite.name = "magnifier"
        sprite.position = CGPoint(x: centerX, y: rowMagnifier)
        addChild(sprite)
        magnifier = sprite

        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 0.8),
            SKAction.scale(to: 0.92, duration: 0.8)
        ])
        sprite.run(SKAction.repeatForever(breathe))
    }
    
    private func setupInstruction() {
        enumerateChildNodes(withName: "instructionPlate") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "doneExploring") { node, _ in node.removeFromParent() }

        let plateWidth = min(size.width * 0.9, 750)
        instructionPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        instructionPlate.name = "instructionPlate"
        instructionPlate.texture?.filteringMode = .nearest
        instructionPlate.size = CGSize(width: plateWidth, height: 100)
        instructionPlate.position = CGPoint(x: centerX, y: rowInstruct)
        addChild(instructionPlate)

        instructionLabel = makeLabel(
            "Tap the cells or drag the 🔍 over them to explore!",
            fontSize: 20,
            at: .zero
        )
        instructionLabel.numberOfLines = 2
        instructionLabel.preferredMaxLayoutWidth = plateWidth * 0.85
        instructionLabel.fontColor = .black
        instructionLabel.zPosition = 1
        instructionLabel.name = "instructionLabel"
        instructionPlate.addChild(instructionLabel)

        let tex = SKTexture(imageNamed: "genotype_card_purple_thin")
        let ratio = tex.size().width / tex.size().height
        let btnHeight: CGFloat = 80
        let btn = SKSpriteNode(texture: tex)
        btn.texture?.filteringMode = .nearest
        btn.size = CGSize(width: btnHeight * ratio, height: btnHeight)
        btn.name = "doneExploring"
        btn.position = CGPoint(x: centerX, y: rowDoneBtn)
        addChild(btn)

        let arrowTex = SKTexture(imageNamed: "arrow")
        let arrowRatio = arrowTex.size().width / arrowTex.size().height
        let arrowH: CGFloat = 14
        let arrowSprite = SKSpriteNode(texture: arrowTex)
        arrowSprite.texture?.filteringMode = .nearest
        arrowSprite.size = CGSize(width: arrowH * arrowRatio, height: arrowH)
        arrowSprite.position = CGPoint(x: 55, y: -1)
        arrowSprite.name = "doneExploring"
        btn.addChild(arrowSprite)

        let btnLbl = SKLabelNode(text: "Next")
        btnLbl.fontName = "AvenirNext-Bold"
        btnLbl.fontSize = 18
        btnLbl.fontColor = .white
        btnLbl.verticalAlignmentMode = .center
        btnLbl.position = CGPoint(x: -15, y: 0)
        btnLbl.name = "doneExploring"
        btn.addChild(btnLbl)

        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 0.95, duration: 0.8)
        ])
        btn.run(SKAction.repeatForever(breathe))
    }
    
    private func showTooltip(for cell: PunnettCellNode) {
        tooltipNode?.removeFromParent()
        
        let titles: [String: String] = [
            "BB": "BB — Homozygous Dominant",
            "Bb": "Bb — Heterozygous",
            "bb": "bb — Homozygous Recessive"
        ]
        let subtitles: [String: String] = [
            "BB": "Two dominant alleles. This offspring is Purple.",
            "Bb": "One dominant, one recessive. Still Purple — B wins!",
            "bb": "Two recessive alleles. This offspring is White."
        ]
        
        let title = titles[cell.expectedGenotype] ?? cell.expectedGenotype
        let subtitle = subtitles[cell.expectedGenotype] ?? ""
        
        let popup = SKNode()
        popup.zPosition = 30
        
        let bg = SKShapeNode(rectOf: CGSize(width: 360, height: 120), cornerRadius: 16)
        bg.fillColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.92)
        bg.strokeColor = UIColor.white.withAlphaComponent(0.15)
        bg.lineWidth = 1
        popup.addChild(bg)
        
        let titleLbl = SKLabelNode(text: title)
        titleLbl.fontName = "AvenirNext-Bold"
        titleLbl.fontSize = 20
        titleLbl.fontColor = .white
        titleLbl.verticalAlignmentMode = .center
        titleLbl.horizontalAlignmentMode = .center
        titleLbl.position = CGPoint(x: 0, y: 26)
        popup.addChild(titleLbl)
        
        let subLbl = SKLabelNode(text: subtitle)
        subLbl.fontName = "AvenirNext-Medium"
        subLbl.fontSize = 16
        subLbl.fontColor = UIColor.white.withAlphaComponent(0.8)
        subLbl.verticalAlignmentMode = .center
        subLbl.horizontalAlignmentMode = .center
        subLbl.numberOfLines = 2
        subLbl.preferredMaxLayoutWidth = 320
        subLbl.position = CGPoint(x: 0, y: -20)
        popup.addChild(subLbl)
        
        let cellScenePos = gridNode.convert(cell.position, to: self)
        let aboveY = cellScenePos.y + cellSize / 2 + 60
        let belowY = cellScenePos.y - cellSize / 2 - 60
        let useAbove = aboveY + 44 < size.height - 60
        popup.position = CGPoint(x: cellScenePos.x, y: useAbove ? aboveY : belowY)
        
        popup.alpha = 0
        addChild(popup)
        tooltipNode = popup
        
        popup.run(SKAction.sequence([
            SKAction.scale(to: 0.85, duration: 0),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
        ]))
    }
    
    private func beginQuestions() {
        phase = 2
        
        magnifier?.removeFromParent()
        tooltipNode?.removeFromParent()
        hoveredCell = nil
        
        let phase1Names = ["doneExploring", "instructionPlate", "instructionLabel", "magnifier", "punnettGrid", "crossLabel"]
        for name in phase1Names {
            enumerateChildNodes(withName: name) { node, _ in node.removeFromParent() }
        }

        setupGrid()
        
        let plateWidth = min(size.width * 0.9, 750)
        let qPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        qPlate.name = "qPlate"
        qPlate.texture?.filteringMode = .nearest
        qPlate.size = CGSize(width: plateWidth, height: 100)
        qPlate.position = CGPoint(x: centerX, y: rowInstruct)
        addChild(qPlate)

        questionLabel = makeLabel("", fontSize: 20, at: .zero, bold: true)
        questionLabel.name = "questionLabel"
        questionLabel.numberOfLines = 2
        questionLabel.preferredMaxLayoutWidth = plateWidth * 0.85
        questionLabel.fontColor = .black
        questionLabel.zPosition = 1
        qPlate.addChild(questionLabel)

        progressLabel = makeLabel("Question 1 / 3", fontSize: 14, at: CGPoint(x: centerX, y: rowProgress))
        progressLabel.name = "progressLabel"
        addChild(progressLabel)
        
        let dz: CGFloat = 130
        dropZone = SKSpriteNode(imageNamed: "slot_empty")
        dropZone.name = "dropZone"
        dropZone.texture?.filteringMode = .nearest
        dropZone.size = CGSize(width: dz, height: dz)
        dropZone.position = CGPoint(x: centerX, y: rowMagnifier)
        addChild(dropZone)

        dropZoneLabel = makeLabel("Answer?", fontSize: 13, at: CGPoint(x: centerX, y: rowMagnifier - dz * 0.62))
        dropZoneLabel.name = "dropZoneLabel"
        addChild(dropZoneLabel)
        
        let spacing: CGFloat = min(120, size.width * 0.20)
        let startX = centerX - spacing * 1.5
        for (i, num) in [1, 2, 3, 4].enumerated() {
            let tile = NumberTileNode(number: num)
            let pos = CGPoint(x: startX + CGFloat(i) * spacing, y: rowTiles)
            tile.position = pos
            tileHomes.append(pos)
            addChild(tile)
            numberTiles.append(tile)
        }
        
        showQuestion(index: 0)
    }
    
    private func showQuestion(index: Int) {
        currentQuestion = index
        
        let parent = questionLabel.parent
        let pos = questionLabel.position
        let prefWidth = questionLabel.preferredMaxLayoutWidth
        questionLabel.removeFromParent()
        
        questionLabel = makeLabel(questions[index].text, fontSize: 20, at: pos, color: .black, bold: true)
        questionLabel.numberOfLines = 2
        questionLabel.preferredMaxLayoutWidth = prefWidth
        questionLabel.zPosition = 1
        parent?.addChild(questionLabel)
        
        progressLabel.text = "Question \(index + 1) / 3"
        dropZone.texture = SKTexture(imageNamed: "slot_empty")
        dropZone.texture?.filteringMode = .nearest
        dropZoneLabel.isHidden = false
        
        for (i, tile) in numberTiles.enumerated() {
            tile.isUsed = false
            tile.alpha = 1.0
            tile.run(SKAction.move(to: tileHomes[i], duration: 0.25))
        }
    }
    
    private func checkAnswer(tile: NumberTileNode) {
        let q = questions[currentQuestion]
        if tile.number == q.answer {
            playCorrectSound()
            playSlimeSound()
            tile.isUsed = true
            tile.run(SKAction.move(to: dropZone.position, duration: 0.2))
            dropZone.texture = SKTexture(imageNamed: "slot_filled")
            dropZone.texture?.filteringMode = .nearest
            dropZoneLabel.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                if self.currentQuestion < self.questions.count - 1 {
                    self.showQuestion(index: self.currentQuestion + 1)
                } else {
                    self.completeLevel()
                }
            }
        } else {
            let i = numberTiles.firstIndex(where: { $0 === tile }) ?? 0
            tile.run(SKAction.move(to: tileHomes[i], duration: 0.25))
            showWrongAnswer(explanation: q.explanation)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        
        if phase == 2 {
            let hit = atPoint(loc)
            for tile in numberTiles where !tile.isUsed {
                if hit === tile || hit.inParentHierarchy(tile) {
                    draggingTile = tile
                    tile.zPosition = 10
                    return
                }
            }
        } else {
            let hit = atPoint(loc)
            if hit === magnifier || hit.inParentHierarchy(magnifier) {
                draggingMagnifier = true
                magnifier.zPosition = 10
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        
        if draggingMagnifier {
            magnifier.position = loc
            var matched: PunnettCellNode? = nil
            for row in gridNode.cells {
                for cell in row {
                    let cellPos = gridNode.convert(cell.position, to: self)
                    if abs(loc.x - cellPos.x) < cellSize * 0.6 &&
                        abs(loc.y - cellPos.y) < cellSize * 0.6 {
                        matched = cell
                        break
                    }
                }
                if matched != nil { break }
            }
            if matched !== hoveredCell {
                hoveredCell = matched
                if let cell = matched {
                    showTooltip(for: cell)
                } else {
                    tooltipNode?.removeFromParent()
                    tooltipNode = nil
                }
            }
        }
        
        if let tile = draggingTile {
            tile.position = loc
            let dist = hypot(loc.x - dropZone.position.x, loc.y - dropZone.position.y)
            dropZone.texture = SKTexture(imageNamed: dist < 65 ? "slot_current" : "slot_empty")
            dropZone.texture?.filteringMode = .nearest
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)
        
        if phase == 1 {
            if draggingMagnifier {
                draggingMagnifier = false
                magnifier.zPosition = 0
                hoveredCell = nil
            } else if hit.name == "doneExploring" || hit.parent?.name == "doneExploring" {
                beginQuestions()
            }
            return
        }
        
        if let tile = draggingTile {
            draggingTile = nil
            tile.zPosition = 0
            let dzPos = dropZone.position
            if hypot(loc.x - dzPos.x, loc.y - dzPos.y) < 65 {
                checkAnswer(tile: tile)
            } else {
                let i = numberTiles.firstIndex(where: { $0 === tile }) ?? 0
                tile.run(SKAction.move(to: tileHomes[i], duration: 0.25))
            }
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
