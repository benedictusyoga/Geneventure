//
//  Level.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import Foundation

enum HintType {
    case revealAllele(String)
    case showRatio(String)
    case explainRule(String)
}

struct LevelData: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let hints: [HintType]
}

let allLevels: [LevelData] = [
    LevelData(id: 1, title: "Meet the Slimes", subtitle: "Watch and observe.", hints: [.explainRule("Some traits always show up; others hide.")]),
    LevelData(id: 2, title: "Who Wins?", subtitle: "Drag the right offspring.", hints: [.explainRule("Purple is dominant for this example.")]),
    LevelData(id: 3, title: "The Surprise", subtitle: "Find the odd one out.", hints: [.showRatio("Drag the white slime to the empty spot.")]),
    LevelData(id: 4, title: "The Hidden Code", subtitle: "Crack open a Slime!", hints: [.revealAllele("Drag the slime to the empty spot and see what's revealed!")]),
    LevelData(id: 5, title: "The Grid", subtitle: "Read a Punnett square.", hints: [.explainRule("Each cell shows one possible offspring.")]),
    LevelData(id: 6, title: "Fill the Grid", subtitle: "Build the Punnett square.", hints: [.explainRule("Combine the rows and columns to see the offspring.")]),
    LevelData(id: 7, title: "Work Backwards", subtitle: "Match parents to offspring.", hints: [.showRatio("Feeling stuck? Use the scratch pad on the top left of the screen!")]),
    LevelData(id: 8, title: "The Mystery Parent", subtitle: "Drag to reveal the secret.", hints: [.showRatio("Feeling stuck? Use the scratch pad on the top left of the screen!")]),
    LevelData(id: 9, title: "Two Traits", subtitle: "Round or Spiky? Purple or White?", hints: [.showRatio("We can use the punnet square for multiple traits too! It's called a \"Dihybrid Cross\"!")]),
    LevelData(id: 10, title: "The Final Lab", subtitle: "Put it all together.", hints: [.explainRule("Use everything you've learned.")])
]
