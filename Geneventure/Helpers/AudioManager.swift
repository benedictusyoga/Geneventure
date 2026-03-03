//
//  AudioManager.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import AVFoundation
internal import Combine

@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isMuted: Bool = UserDefaults.standard.bool(forKey: "isAudioMuted")
    
    private var mainBGM: AVAudioPlayer?
    private var levelBGM: AVAudioPlayer?
    
    enum MixState {
        case menu, levelSelect, level
    }
    private var currentMix: MixState = .menu
    
    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        func getURL(_ name: String) -> URL? {
            return Bundle.main.url(forResource: name, withExtension: "m4a") ??
                   Bundle.main.url(forResource: name, withExtension: "m4a", subdirectory: "Resources")
        }
        
        if let url = getURL("bgm_main") {
            mainBGM = try? AVAudioPlayer(contentsOf: url)
            mainBGM?.numberOfLoops = -1
        }
        
        if let url = getURL("bgm_levels") {
            levelBGM = try? AVAudioPlayer(contentsOf: url)
            levelBGM?.numberOfLoops = -1
        }
        
        if isMuted {
            mainBGM?.volume = 0
            levelBGM?.volume = 0
        }
    }
    
    func toggleMute() {
        isMuted.toggle()
        UserDefaults.standard.set(isMuted, forKey: "isAudioMuted")
        applyMix()
    }
    
    private func applyMix(fadeDuration: TimeInterval = 1.0) {
        if isMuted {
            mainBGM?.setVolume(0.0, fadeDuration: fadeDuration)
            levelBGM?.setVolume(0.0, fadeDuration: fadeDuration)
            return
        }
        
        switch currentMix {
        case .menu:
            mainBGM?.setVolume(1.0, fadeDuration: fadeDuration)
            levelBGM?.setVolume(0.0, fadeDuration: fadeDuration)
        case .levelSelect:
            mainBGM?.setVolume(0.4, fadeDuration: fadeDuration)
            levelBGM?.setVolume(0.0, fadeDuration: fadeDuration)
        case .level:
            mainBGM?.setVolume(0.0, fadeDuration: fadeDuration)
            levelBGM?.setVolume(1.0, fadeDuration: fadeDuration)
        }
    }
    
    func playMenu() {
        currentMix = .menu
        if mainBGM?.isPlaying == false {
            mainBGM?.volume = 0
            mainBGM?.play()
        }
        applyMix()
    }
    
    func playLevelSelect() {
        currentMix = .levelSelect
        if mainBGM?.isPlaying == false {
            mainBGM?.volume = 0
            mainBGM?.play()
        }
        applyMix()
    }
    
    func playLevel() {
        currentMix = .level
        if levelBGM?.isPlaying == false {
            levelBGM?.volume = 0
            levelBGM?.play()
        }
        applyMix()
    }

    func playSFX(_ name: String, volume: Float = 0.2) {
        guard !isMuted else { return }
        
        let extensions = ["m4a", "mp3", "wav"]
        var url: URL?
        for ext in extensions {
            if let found = Bundle.main.url(forResource: name, withExtension: ext) ??
                           Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Resources") {
                url = found
                break
            }
        }
        
        guard let sfxURL = url else { return }
        
        Task {
            let player = try? AVAudioPlayer(contentsOf: sfxURL)
            player?.volume = volume
            player?.play()
            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
            _ = player
        }
    }
}
