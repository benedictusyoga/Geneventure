//
//  AlleleTileNode.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class AlleleTileNode: SKNode {
    let allele: Allele
    private var background: SKShapeNode!
    private var label: SKLabelNode!
    
    var isPlaced: Bool = false
    
    init(allele: Allele) {
        self.allele = allele
        super.init()
        setupBackground()
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("Error Encountered!")}
    
    private func setupBackground() {
        background = SKShapeNode(rectOf: CGSize(width: 48, height: 48), cornerRadius: 10)
        background.fillColor = allele == .dominant ? UIColor(red: 0.55, green: 0.27, blue: 0.88, alpha: 1) : UIColor(white: 0.85, alpha: 1)
        background.strokeColor = .black
        background.lineWidth = 1.5
        addChild(background)
    }
    
    private func setupLabel() {
        label = SKLabelNode(text: allele.rawValue)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 26
        label.fontColor = allele == .dominant ? .white : .darkGray
        label.verticalAlignmentMode = .center
        addChild(label)
        
    }
    
    func highlight(_ on: Bool) {
        background.strokeColor = on ? UIColor.systemYellow : UIColor.black
        background.lineWidth = on ? 3 : 1.5
    }
}
