//
//  PunnettGridNode.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class PunnettGridNode: SKNode {
    let rows: Int
    let cols: Int
    let cellSize: CGFloat
    
    private(set) var cells: [[PunnettCellNode]] = []
    private var headerLabels: [SKLabelNode] = []
    
    init(rowAlleles: [Allele], colAlleles: [Allele], cellSize: CGFloat = 80, filled: Bool = false) {
        self.rows = rowAlleles.count
        self.cols = colAlleles.count
        self.cellSize = cellSize
        super.init()
        buildGrid(rowAlleles: rowAlleles, colAlleles: colAlleles, filled: filled)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("Error Encountered!")}
    
    private func buildGrid(rowAlleles: [Allele], colAlleles: [Allele], filled: Bool) {
        for (col, allele) in colAlleles.enumerated() {
            let lbl = makeHeaderLabel(text: allele.rawValue)
            lbl.position = CGPoint(x: CGFloat(col) * cellSize + cellSize * 0.5, y: cellSize * CGFloat(rows) + 20)
            addChild(lbl)
            headerLabels.append(lbl)
        }
        for (row, allele) in rowAlleles.enumerated() {
            let lbl = makeHeaderLabel(text: allele.rawValue)
            lbl.position = CGPoint(
                x: -24,
                y: CGFloat(rows - 1 - row) * cellSize + cellSize * 0.5
            )
            addChild(lbl)
            headerLabels.append(lbl)
        }
        
        cells = []
        for row in 0 ..< rows {
            var rowCells: [PunnettCellNode] = []
            for col in 0 ..< cols {
                let colAllele = colAlleles[col]
                let rowAllele = rowAlleles[row]
                let genotypeText: String
                let sorted = [colAllele.rawValue, rowAllele.rawValue].sorted { $0 < $1 }
                genotypeText = sorted.joined()
                
                let cellNode = PunnettCellNode(
                    size: CGSize(width: cellSize, height: cellSize),
                    genotypeText: genotypeText,
                    isEmpty: !filled
                )
                
                cellNode.position = CGPoint(x: CGFloat(col) * cellSize + cellSize * 0.5, y: CGFloat(rows - 1 - row) * cellSize + cellSize * 0.5)
                cellNode.gridPosition = (row, col)
                addChild(cellNode)
                rowCells.append(cellNode)
            }
            cells.append(rowCells)
        }
    }
    
    private func makeHeaderLabel(text: String) -> SKLabelNode {
        let lbl = SKLabelNode(text: text)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = 20
        lbl.fontColor = .darkGray
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center
        return lbl
    }
    
    var emptyCells: [PunnettCellNode] {
        cells.flatMap { $0 }.filter { $0.isEmpty }
    }
    
    func nearestEmptyCell(to point: CGPoint) -> PunnettCellNode? {
        emptyCells.min(by: {
            hypot($0.position.x - point.x, $0.position.y - point.y) <
                hypot($1.position.x - point.x, $1.position.y - point.y)
        })
    }
}

class PunnettCellNode: SKNode {
    var gridPosition: (row: Int, col: Int) = (0, 0)
    var isEmpty: Bool
    let expectedGenotype: String

    var onTap: (() -> Void)?

    private var bgSprite: SKSpriteNode!
    private var label: SKLabelNode!

    init(size: CGSize, genotypeText: String, isEmpty: Bool) {
        self.expectedGenotype = genotypeText
        self.isEmpty = isEmpty
        super.init()

        isUserInteractionEnabled = true

        let texName = "slot_empty"
        bgSprite = SKSpriteNode(imageNamed: texName)
        bgSprite.texture?.filteringMode = .nearest
        bgSprite.size = size
        addChild(bgSprite)

        label = SKLabelNode(text: isEmpty ? "" : genotypeText)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 18
        label.fontColor = .darkGray
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Error Encountered!") }

    func fill(with text: String, correct: Bool) {
        label.text = text
        isEmpty = false
        bgSprite.texture = SKTexture(imageNamed: "slot_filled")
        bgSprite.texture?.filteringMode = .nearest
        if correct {
            bgSprite.color = UIColor(red: 0.2, green: 0.85, blue: 0.4, alpha: 1)
            bgSprite.colorBlendFactor = 0.4
        } else {
            bgSprite.color = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1)
            bgSprite.colorBlendFactor = 0.4
        }
    }

    func highlight(_ on: Bool) {
        bgSprite.color = on ? UIColor.systemYellow : .white
        bgSprite.colorBlendFactor = on ? 0.35 : 0
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        onTap?()
    }
}
