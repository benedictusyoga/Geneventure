//
//  Genetics.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import Foundation

enum Allele: String, CaseIterable {
    case dominant = "B"
    case recessive = "b"
}

enum Genotype: String, CaseIterable {
    case BB
    case Bb
    case bb
    
    var isDominant: Bool {self != .bb}
    
    var alleles: (Allele, Allele) {
        switch self {
        case .BB: return (.dominant, .dominant)
        case .Bb: return (.dominant, .recessive)
        case .bb: return (.recessive, .recessive)
        }
    }
    
    var displayName: String {rawValue}
}

enum ColorPhenotype: String {
    case purple
    case white
    
    static func from(_ genotype: Genotype) -> ColorPhenotype {
        genotype.isDominant ? .purple : .white
    }
}

enum ShapePhenotype: String {
    case round
    case spiky
}

func monohybridCross(_ parent1: Genotype, _ parent2: Genotype) -> [Genotype] {
    let (a1, a2) = parent1.alleles
    let (b1, b2) = parent2.alleles
    let pairs: [(Allele, Allele)] = [(a1, b1), (a1, b2), (a2, b1), (a2, b2)]
    
    return pairs.map { pair in
        let sorted = [pair.0.rawValue, pair.1.rawValue].sorted { $0 < $1 }
        return Genotype(rawValue: sorted.joined()) ?? .bb
    }
}

func phenotypeRatio(from offspring: [Genotype]) -> (dominant: Int, recessive: Int) {
    let dominant = offspring.filter { $0.isDominant }.count
    let recessive = offspring.filter { !$0.isDominant }.count
    return (dominant, recessive)
}

typealias DihybridPhenotype = (color: ColorPhenotype, shape: ShapePhenotype)
