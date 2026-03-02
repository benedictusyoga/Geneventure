//
//  GameState.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import Foundation
internal import Combine

@MainActor
class GameState: ObservableObject {
    static let shared = GameState()
    
    private let completedKey = "completedLevels"
    private let infiniteHighScoreKey = "infiniteHighScore"
    private let infiniteUnlockedKey = "hasSeenInfiniteUnlock"
    
    @Published private(set) var completedLevels: Set<Int> = []
    @Published private(set) var infiniteHighScore: Int = 0
    @Published private(set) var hasSeenInfiniteUnlock: Bool = false
    
    @MainActor
    private init() {
        let saved = UserDefaults.standard.array(forKey: completedKey) as? [Int] ?? []
        completedLevels = Set(saved)
        infiniteHighScore = UserDefaults.standard.integer(forKey: infiniteHighScoreKey)
        hasSeenInfiniteUnlock = UserDefaults.standard.bool(forKey: infiniteUnlockedKey)
    }
    func isUnlocked(_ levelId: Int) -> Bool {
        levelId == 1 || completedLevels.contains(levelId - 1)
    }
    func isCompleted(_ levelId: Int) -> Bool {
        completedLevels.contains(levelId)
    }
    
    func markCompleted(_ levelId: Int) {
        completedLevels.insert(levelId)
        UserDefaults.standard.set(Array(completedLevels), forKey: completedKey)
        objectWillChange.send()
    }

    func setSeenInfiniteUnlock() {
        hasSeenInfiniteUnlock = true
        UserDefaults.standard.set(true, forKey: infiniteUnlockedKey)
        objectWillChange.send()
    }
    
    func submitInfiniteScore(_ score: Int) {
        if score > infiniteHighScore {
            infiniteHighScore = score
            UserDefaults.standard.set(score, forKey: infiniteHighScoreKey)
            objectWillChange.send()
        }
    }
    
    func resetAll() {
        completedLevels = []
        infiniteHighScore = 0
        hasSeenInfiniteUnlock = false
        UserDefaults.standard.removeObject(forKey: completedKey)
        UserDefaults.standard.removeObject(forKey: infiniteHighScoreKey)
        UserDefaults.standard.removeObject(forKey: infiniteUnlockedKey)
    }
}
