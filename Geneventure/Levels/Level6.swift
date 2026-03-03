//
//  Level6.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class Level6Scene: GameScene {
    private struct Round {
        let parent1: Genotype
        let parent2: Genotype
        var label: String { "\(parent1.displayName) × \(parent2.displayName)" }
    }

    private let rounds: [Round] = [
        Round(parent1: .Bb, parent2: .Bb),
        Round(parent1: .BB, parent2: .bb),
        Round(parent1: .Bb, parent2: .bb)
    ]
    private var currentRound = 0
    private var filledCount = 0

    private var centerX: CGFloat { size.width / 2 }
    private var centerY: CGFloat { size.height / 2 }
    private let cellSize: CGFloat = 110

    private var rowInstruct: CGFloat { size.height * 0.74 }
    private var rowCross: CGFloat { size.height * 0.64 }
    private var rowGridMid: CGFloat { size.height * 0.46 }
    private var rowTray: CGFloat { size.height * 0.16 }
    private var rowLabel: CGFloat { size.height * 0.05 }

    private var gridNode: PunnettGridNode!
    private var trayTiles: [GenotypeCardNode] = []
    private var miniSlimes: [SlimeNode] = []

    private var dragClone: GenotypeCardNode?
    private var dragGenotype: Genotype?

    private var roundLabel: SKLabelNode!
    private var instructionLabel: SKLabelNode!
    private var instructionPlate: SKSpriteNode!
    private var parentLabel: SKLabelNode!

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
        filledCount = 0
        trayTiles.removeAll()
        miniSlimes.removeAll()
        dragClone = nil
        dragGenotype = nil
    }

    private func setupStaticUI() {
        enumerateChildNodes(withName: "instructionPlate") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "parentLabel") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "roundLabel") { node, _ in node.removeFromParent() }

        let plateWidth = min(size.width * 0.9, 750)
        instructionPlate = SKSpriteNode(imageNamed: "genotype_card_pale_thin")
        instructionPlate.name = "instructionPlate"
        instructionPlate.texture?.filteringMode = .nearest
        instructionPlate.size = CGSize(width: plateWidth, height: 100)
        instructionPlate.position = CGPoint(x: centerX, y: rowInstruct)
        addChild(instructionPlate)

        instructionLabel = makeLabel(
            "Drag the correct genotype into each blank cell!",
            fontSize: 20,
            at: .zero
        )
        instructionLabel.fontColor = .black
        instructionLabel.preferredMaxLayoutWidth = plateWidth * 0.85
        instructionLabel.zPosition = 1
        instructionLabel.name = "instructionLabel"
        instructionPlate.addChild(instructionLabel)

        parentLabel = makeLabel("", fontSize: 22, at: CGPoint(x: centerX, y: rowCross), bold: true)
        parentLabel.name = "parentLabel"
        addChild(parentLabel)

        roundLabel = SKLabelNode(text: "Round 1 / 3")
        roundLabel.name = "roundLabel"
        roundLabel.fontName = "AvenirNext-Bold"
        roundLabel.fontSize = 14
        roundLabel.fontColor = UIColor.systemGray
        roundLabel.position = CGPoint(x: centerX, y: rowLabel)
        roundLabel.verticalAlignmentMode = .center
        roundLabel.horizontalAlignmentMode = .center
        addChild(roundLabel)
    }

    private func loadRound() {
        enumerateChildNodes(withName: "punnettGrid") { node, _ in node.removeFromParent() }
        trayTiles.forEach { $0.removeFromParent() }
        miniSlimes.forEach { $0.removeFromParent() }
        trayTiles.removeAll()
        miniSlimes.removeAll()
        filledCount = 0

        let round = rounds[currentRound]
        roundLabel.text = "Round \(currentRound + 1) / 3"
        parentLabel.text = round.label

        let rowAlleles = allelesFor(round.parent1)
        let colAlleles = allelesFor(round.parent2)
        gridNode = PunnettGridNode(
            rowAlleles: rowAlleles,
            colAlleles: colAlleles,
            cellSize: cellSize,
            filled: false
        )
        gridNode.name = "punnettGrid"
        let gridW = CGFloat(colAlleles.count) * cellSize
        let gridH = CGFloat(rowAlleles.count) * cellSize
        gridNode.position = CGPoint(
            x: centerX - gridW / 2,
            y: rowGridMid - gridH / 2
        )
        addChild(gridNode)

        for row in gridNode.cells {
            for cell in row {
                cell.isUserInteractionEnabled = false
            }
        }

        let needed = uniqueGenotypes(for: round)
        let spacing: CGFloat = min(150, size.width * 0.26)
        let startX = centerX - spacing * CGFloat(needed.count - 1) / 2
        for (i, g) in needed.enumerated() {
            let card = GenotypeCardNode(genotype: g, height: 80)
            card.position = CGPoint(x: startX + CGFloat(i) * spacing, y: rowTray)
            addChild(card)
            trayTiles.append(card)
        }
    }

    private func allelesFor(_ g: Genotype) -> [Allele] {
        switch g {
        case .BB: return [.dominant, .dominant]
        case .Bb: return [.dominant, .recessive]
        case .bb: return [.recessive, .recessive]
        }
    }

    private func uniqueGenotypes(for round: Round) -> [Genotype] {
        let offspring = monohybridCross(round.parent1, round.parent2)
        var seen = Set<String>()
        return offspring.compactMap { g -> Genotype? in
            let k = g.rawValue
            guard !seen.contains(k) else { return nil }
            seen.insert(k); return g
        }
    }

    private func nearestEmptyCell(to loc: CGPoint) -> PunnettCellNode? {
        var best: PunnettCellNode?
        var bestDist = CGFloat.infinity
        for row in gridNode.cells {
            for cell in row where cell.isEmpty {
                let p = gridNode.convert(cell.position, to: self)
                let d = hypot(loc.x - p.x, loc.y - p.y)
                if d < bestDist { bestDist = d; best = cell }
            }
        }
        return best
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)

        for tray in trayTiles {
            if hit === tray || hit.inParentHierarchy(tray) {
                let clone = GenotypeCardNode(genotype: tray.genotype, height: 80)
                clone.position = tray.position
                clone.zPosition = 20
                addChild(clone)
                dragClone = clone
                dragGenotype = tray.genotype
                return
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let clone = dragClone else { return }
        let loc = touch.location(in: self)
        clone.position = loc

        for row in gridNode.cells {
            for cell in row where cell.isEmpty {
                let p = gridNode.convert(cell.position, to: self)
                let near = hypot(loc.x - p.x, loc.y - p.y) < cellSize * 0.7
                cell.highlight(near)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first,
              let clone = dragClone,
              let genotype = dragGenotype else { return }
        let loc = touch.location(in: self)
        dragClone = nil
        dragGenotype = nil

        for row in gridNode.cells { for cell in row { cell.highlight(false) } }

        guard let cell = nearestEmptyCell(to: loc) else {
            clone.removeFromParent(); return
        }
        let cellPos = gridNode.convert(cell.position, to: self)
        guard hypot(loc.x - cellPos.x, loc.y - cellPos.y) < cellSize * 0.8 else {
            clone.removeFromParent(); return
        }

        if genotype.rawValue == cell.expectedGenotype {
            playCorrectSound()
            playSlimeSound()
            clone.removeFromParent()
            cell.fill(with: genotype.rawValue, correct: true)
            filledCount += 1

            let slime = SlimeNode(color: genotype.isDominant ? .purple : .white, size: 80)
            slime.setScale(0.35)
            slime.alpha = 0
            slime.position = cellPos
            slime.zPosition = 5
            addChild(slime)
            miniSlimes.append(slime)
            slime.run(SKAction.group([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.scale(to: 0.28, duration: 0.3)
            ]))

            if filledCount == gridNode.rows * gridNode.cols {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.advanceRound()
                }
            }
        } else {
            let expected = cell.expectedGenotype
            let explanation: String
            switch expected {
            case "BB": explanation = "This cell combines B (top) + B (left) = BB!"
            case "bb": explanation = "This cell combines b (top) + b (left) = bb!"
            default:   explanation = "This cell combines one B and one b = Bb!"
            }
            clone.run(SKAction.sequence([
                SKAction.moveBy(x: -8, y: 0, duration: 0.05),
                SKAction.moveBy(x: 8, y: 0, duration: 0.05),
                SKAction.moveBy(x: -8, y: 0, duration: 0.05),
                SKAction.moveBy(x: 8, y: 0, duration: 0.05),
                SKAction.removeFromParent()
            ]))
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
        lbl.numberOfLines = 2
        return lbl
    }
}
