//
//  NumberTileNode.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class NumberTileNode: SKNode {
    let number: Int
    var isUsed: Bool = false
    
    init(number: Int) {
        self.number = number
        super.init()
        
        let bgSprite = SKSpriteNode(imageNamed: "allele_tile")
        bgSprite.texture?.filteringMode = .nearest
        
        bgSprite.size = CGSize(width: 80, height: 80)
        bgSprite.name = "bg"
        addChild(bgSprite)
        
        let lbl = SKLabelNode(text: "\(number)")
        lbl.fontName = "AvenirNext-Black"
        lbl.fontSize = 38
        
        lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        addChild(lbl)

        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 0.7),
            SKAction.scale(to: 0.93, duration: 0.7)
        ])
        run(SKAction.repeatForever(breathe))
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("Not Implemented") }
    
    func highlight(_ on: Bool) {
        guard let bg = childNode(withName: "bg") as? SKSpriteNode else { return }
        bg.colorBlendFactor = on ? 0.3 : 0.0
        bg.color = .yellow
    }
}
