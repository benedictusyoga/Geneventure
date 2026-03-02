//
//  ChallengeGenerator.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import Foundation
import SpriteKit

protocol ChallengeProvider {
    var questionTitle: String { get }
    var parentsLabel: String { get }
    var parent1: Genotype { get }
    var parent2: Genotype { get }
    var correctGenotypes: [Genotype] { get }
}

struct PunnettChallenge: ChallengeProvider {
    let parent1: Genotype
    let parent2: Genotype
    var questionTitle: String { "Complete the Punnett Square!" }
    var parentsLabel: String { "\(parent1.displayName) × \(parent2.displayName)" }
    var correctGenotypes: [Genotype] {
        monohybridCross(parent1, parent2)
    }
}

class ChallengeGenerator {
    static func generate() -> ChallengeProvider {
        let p1 = Genotype.allCases.randomElement()!
        let p2 = Genotype.allCases.randomElement()!
        return PunnettChallenge(parent1: p1, parent2: p2)
    }
}
