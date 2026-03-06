//
//  InfiniteScene.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class InfiniteScene: GameScene {
    var onUpdateStats: ((Int, Int) -> Void)?
    var onGameOver: ((Int) -> Void)?
    
    private var score = 0
    private var lives = 3
    private var currentChallenge: ChallengeProvider?
    private var filledCount = 0
    private var isBusy = false
    
    private var gridNode: PunnettGridNode!
    private var bouncyTokens: [GenotypeCardNode] = []
    
    private var dragNode: GenotypeCardNode?
    private var dragGenotype: Genotype?
    
    private var isCompact: Bool { size.width < 500 }
    private var isShortScreen: Bool { size.height < 900 }
    private var useSmallUI: Bool { isCompact || isShortScreen }
    private var navbarHeight: CGFloat { isCompact ? 110 : 90 }
    private var contentWidth: CGFloat { min(size.width - 40, 500) }
    private var plateWidth: CGFloat { min(contentWidth, 700) }
    private var centerX: CGFloat { size.width / 2 }
    private var centerY: CGFloat { size.height / 2 }
    private var cellSize: CGFloat { useSmallUI ? 60 : 80 }
    
    private var usableTop: CGFloat { size.height - navbarHeight }
    private var usableHeight: CGFloat { size.height - navbarHeight - 30 }
    private var groupCenterY: CGFloat { usableTop - usableHeight / 2 }

    private var rowInstruct: CGFloat { useSmallUI ? groupCenterY + 180 : groupCenterY + 230 }
    private var rowParents: CGFloat { useSmallUI ? groupCenterY + 110 : groupCenterY + 140 }
    private var rowGrid: CGFloat { useSmallUI ? groupCenterY - 10 : groupCenterY - 20  }
    
    private var parentLabel: SKLabelNode!
    private var instructionPlate: SKSpriteNode!
    private var instructionLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        physicsWorld.gravity = .zero
        let borderYTop = rowInstruct + 60
        let borderYBot = 60.0
        let border = SKPhysicsBody(edgeLoopFrom: CGRect(x: 10, y: borderYBot, width: size.width - 20, height: borderYTop - borderYBot))
        physicsBody = border
        physicsBody?.categoryBitMask = 0x1
        physicsBody?.collisionBitMask = 0x1
        
        setupUI()
        loadNextChallenge()
    }
    
    private func setupUI() {
        instructionPlate = SKSpriteNode(imageNamed: "plate")
        instructionPlate.texture?.filteringMode = .nearest
        instructionPlate.size = CGSize(width: plateWidth, height: useSmallUI ? 50 : 60)
        instructionPlate.position = CGPoint(x: centerX, y: rowInstruct)
        addChild(instructionPlate)
        
        instructionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        instructionLabel.fontSize = useSmallUI ? 14 : 16
        instructionLabel.fontColor = .black
        instructionLabel.verticalAlignmentMode = .center
        instructionLabel.position = .zero
        instructionPlate.addChild(instructionLabel)
        
        parentLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        parentLabel.fontSize = useSmallUI ? 18 : 24
        parentLabel.fontColor = .black
        parentLabel.position = CGPoint(x: centerX, y: rowParents)
        addChild(parentLabel)
        
        childNode(withName: "hintToken")?.isHidden = true
    }
    
    private func loadNextChallenge() {
        isBusy = false
        filledCount = 0
        
        gridNode?.removeFromParent()
        bouncyTokens.forEach { $0.removeFromParent() }
        bouncyTokens.removeAll()
        
        currentChallenge = ChallengeGenerator.generate()
        guard let challenge = currentChallenge else { return }
        
        instructionLabel.text = challenge.questionTitle
        parentLabel.text = challenge.parentsLabel
        
        let p1 = challenge.parent1
        let p2 = challenge.parent2
        gridNode = PunnettGridNode(
            rowAlleles: allelesFor(p1),
            colAlleles: allelesFor(p2),
            cellSize: cellSize,
            filled: false
        )
        let gridW = cellSize * 2
        let gridH = cellSize * 2
        gridNode.position = CGPoint(x: centerX - gridW / 2, y: rowGrid - gridH / 2)
        addChild(gridNode)
        
        spawnBouncingTokens(for: challenge)
        
        onUpdateStats?(score, lives)
    }
    
    private func spawnBouncingTokens(for challenge: ChallengeProvider) {
        let correctOnes = challenge.correctGenotypes
        var choices = correctOnes
        
        let possibleDistractors = Genotype.allCases.filter { !correctOnes.contains($0) }
        for _ in 0..<2 {
            if let d = possibleDistractors.randomElement() {
                choices.append(d)
            }
        }
        
        choices.shuffle()
        
        for g in choices {
            let cardHeight: CGFloat = useSmallUI ? 60 : 80
            let token = GenotypeCardNode(genotype: g, height: cardHeight)
            let spawnYMin = 80.0
            let spawnYMax = min(rowGrid - 80, 250)
            token.position = CGPoint(
                x: CGFloat.random(in: 50...size.width - 50),
                y: CGFloat.random(in: spawnYMin...spawnYMax)
            )
            token.zPosition = 10
            
            let pb = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
            pb.affectedByGravity = false
            pb.allowsRotation = false
            pb.friction = 0
            pb.restitution = 1.0
            pb.linearDamping = 0
            pb.categoryBitMask = 0x1
            pb.collisionBitMask = 0x1
            
            token.physicsBody = pb
            
            addChild(token)
            bouncyTokens.append(token)
            
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let speed: CGFloat = 150
            pb.velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
        }
    }
    
    private func allelesFor(_ g: Genotype) -> [Allele] {
        switch g {
        case .BB: return [.dominant, .dominant]
        case .Bb: return [.dominant, .recessive]
        case .bb: return [.recessive, .recessive]
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isBusy, let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)
        
        for token in bouncyTokens {
            if hit === token || hit.inParentHierarchy(token) {
                dragNode = token
                dragGenotype = token.genotype
                
                token.physicsBody?.isDynamic = false
                token.zPosition = 100
                token.run(SKAction.scale(to: 1.2, duration: 0.1))
                return
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let node = dragNode else { return }
        let loc = touch.location(in: self)
        node.position = loc
        
        for row in gridNode.cells {
            for cell in row where cell.isEmpty {
                let p = gridNode.convert(cell.position, to: self)
                let dist = hypot(loc.x - p.x, loc.y - p.y)
                cell.highlight(dist < cellSize * 0.7)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = dragNode, let touch = touches.first, let genotype = dragGenotype else { return }
        let loc = touch.location(in: self)
        
        dragNode = nil
        dragGenotype = nil
        
        for row in gridNode.cells { for cell in row { cell.highlight(false) } }
        
        var bestCell: PunnettCellNode?
        var minDist = CGFloat.infinity
        
        for row in gridNode.cells {
            for cell in row where cell.isEmpty {
                let p = gridNode.convert(cell.position, to: self)
                let d = hypot(loc.x - p.x, loc.y - p.y)
                if d < minDist { minDist = d; bestCell = cell }
            }
        }
        
        if let cell = bestCell, minDist < cellSize * 0.8 {
            if genotype.rawValue == cell.expectedGenotype {
                playCorrectSound()
                playSlimeSound()
                node.removeFromParent()
                if let idx = bouncyTokens.firstIndex(of: node) { bouncyTokens.remove(at: idx) }
                
                cell.fill(with: genotype.rawValue, correct: true)
                filledCount += 1
                score += 10
                onUpdateStats?(score, lives)
                
                if filledCount == 4 {
                    isBusy = true
                    playLevelCompleteSound()
                    score += 50
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.run { self.loadNextChallenge() }
                    ]))
                }
            } else {
                handleIncorrectPlacement(node, cell: cell)
            }
        } else {
            node.run(SKAction.scale(to: 1.0, duration: 0.1))
            node.physicsBody?.isDynamic = true
            node.zPosition = 10
        }
    }
    
    private func handleIncorrectPlacement(_ node: GenotypeCardNode, cell: PunnettCellNode) {
        lives -= 1
        onUpdateStats?(score, lives)
        
        let explanation: String
        switch cell.expectedGenotype {
        case "BB": explanation = "This cell combines B (top) + B (left) = BB!"
        case "bb": explanation = "This cell combines b (top) + b (left) = bb!"
        default:   explanation = "This cell combines B and b to make Bb!"
        }
        
        isBusy = true
        showWrongAnswer(explanation: explanation)
        
        node.run(SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.sequence([
                SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                SKAction.moveBy(x: 20, y: 0, duration: 0.05),
                SKAction.moveBy(x: -10, y: 0, duration: 0.05)
            ])
        ])) {
            if self.lives <= 0 {
                self.onGameOver?(self.score)
            } else {
                node.physicsBody?.isDynamic = true
                node.zPosition = 10
                self.isBusy = false
            }
        }
    }
}
