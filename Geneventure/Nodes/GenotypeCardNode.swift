//
//  GenotypeCardNode.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SpriteKit

class GenotypeCardNode: SKNode {
    let genotype: Genotype
    var isPlaced: Bool = false
    
    init(genotype: Genotype, height: CGFloat = 80) {
        self.genotype = genotype
        super.init()
        
        let isRecessive = (genotype == .bb)
        let imageName = isRecessive ? "slot_empty" : "slot_filled"
        
        let bgSprite = SKSpriteNode(imageNamed: imageName)
        bgSprite.texture?.filteringMode = .nearest
        
        let ratio = (bgSprite.texture?.size().width ?? 80) / (bgSprite.texture?.size().height ?? 44)
        bgSprite.size = CGSize(width: height * ratio, height: height)
        bgSprite.name = "bg"
        addChild(bgSprite)
        
        let lbl = SKLabelNode(text: genotype.displayName)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = 34
        lbl.fontColor = isRecessive ? UIColor.darkGray : .white
        lbl.verticalAlignmentMode = .center
        addChild(lbl)

        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 0.7),
            SKAction.scale(to: 0.93, duration: 0.7)
        ])
        run(SKAction.repeatForever(breathe))
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("Not Implemented")}
    
    func highlight(_ on: Bool) {
        guard let bg = childNode(withName: "bg") as? SKSpriteNode else { return }
        bg.colorBlendFactor = on ? 0.3 : 0.0
        bg.color = .yellow
    }
}
