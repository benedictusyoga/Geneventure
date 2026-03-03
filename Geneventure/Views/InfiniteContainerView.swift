//
//  InfiniteContainerView.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI
import SpriteKit

struct InfiniteContainerView: View {
    enum GameStateType {
        case intro
        case countdown
        case playing
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var score = 0
    @State private var lives = 3
    @State private var wrongExplanation: String? = nil
    @State private var showGameOver = false
    @State private var scene: InfiniteScene? = nil
    @State private var gameState: GameStateType = .intro
    @State private var countdown = 3
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image(gameState == .intro ? "bg_level_select" : "bg_level")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .overlay(gameState == .intro ? Color.black.opacity(0.6) : Color.clear)
            }
            .ignoresSafeArea()
            
            switch gameState {
            case .intro:
                InfiniteIntroView(highScore: GameState.shared.infiniteHighScore) {
                    startCountdown()
                }
                
            case .countdown:
                Text("\(countdown)")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                    .transition(.scale.combined(with: .opacity))
                
            case .playing:
                if let scene = scene {
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .ignoresSafeArea()
                    
                    InfiniteHUDView(score: score, lives: lives, wrongExplanation: $wrongExplanation)
                }
            }
            
            if gameState != .countdown {
                VStack {
                    CustomNavBarView(title: "Infinite Mode", onBack: {
                        if gameState == .playing {
                            resetGame()
                        } else {
                            dismiss()
                        }
                    })
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showGameOver) {
            InfiniteGameOverView(score: score) {
                showGameOver = false
                dismiss()
            } onReplay: {
                showGameOver = false
                resetGame()
            }
        }
        .onAppear {
            AudioManager.shared.playLevel()
        }
        .onDisappear {
            AudioManager.shared.playLevelSelect()
        }
        .navigationBarHidden(true)
    }
    
    private func startCountdown() {
        withAnimation { gameState = .countdown }
        countdown = 3
        
        Task {
            for _ in 1...3 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    if countdown > 1 {
                        withAnimation { countdown -= 1 }
                    }
                }
            }
            
            await MainActor.run {
                withAnimation {
                    setupScene()
                    gameState = .playing
                    AudioManager.shared.playMenu()
                }
            }
        }
    }
    
    private func setupScene() {
        let screen = UIScreen.main.bounds
        let newScene = InfiniteScene(size: screen.size)
        newScene.scaleMode = .resizeFill
        
        newScene.onUpdateStats = { s, l in
            withAnimation {
                self.score = s
                self.lives = l
            }
        }
        
        newScene.onWrongAnswer = { explanation in
            withAnimation {
                self.wrongExplanation = explanation
            }
        }
        
        newScene.onGameOver = { finalScore in
            GameState.shared.submitInfiniteScore(finalScore)
            showGameOver = true
        }
        
        self.scene = newScene
    }
    
    private func resetGame() {
        score = 0
        lives = 3
        wrongExplanation = nil
        gameState = .intro
        AudioManager.shared.playLevel()
    }
}

struct InfiniteIntroView: View {
    let highScore: Int
    let onStart: () -> Void
    
    @State private var breatheScale: CGFloat = 1.0
    
    private let slimeImage: String
    private let isSpiky: Bool
    private let eyeSize: CGFloat
    private let eyeYOffset: CGFloat
    private let eyeSpacing: CGFloat
    
    init(highScore: Int, onStart: @escaping () -> Void) {
        self.highScore = highScore
        self.onStart = onStart
        
        let color = ["purple", "white"].randomElement()!
        let spiky = Bool.random()
        self.isSpiky = spiky
        self.slimeImage = spiky ? "slime_\(color)_spiky" : "slime_\(color)"
        
        let targetSize: CGFloat = 110
        self.eyeSize = spiky ? targetSize * 0.28 : targetSize * 0.4
        self.eyeYOffset = spiky ? targetSize * -0.12 : targetSize * 0.18
        self.eyeSpacing = (targetSize * 0.36) - self.eyeSize
    }
    
    var body: some View {
        HStack(spacing: 80) {
            ZStack {
                Image(slimeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                
                HStack(spacing: eyeSpacing) {
                    Image("eye")
                        .interpolation(.none)
                        .resizable()
                        .frame(width: eyeSize, height: eyeSize)
                    Image("eye")
                        .interpolation(.none)
                        .resizable()
                        .frame(width: eyeSize, height: eyeSize)
                }
                .offset(y: -eyeYOffset)
            }
            .scaleEffect(1.6)
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("INFINITE MODE")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Master the Punnett Square! Drag the bouncing genotypes into the grid. Be fast, be accurate, and survive as long as you can.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 420)
                }
                
                HStack(spacing: 40) {
                    VStack(spacing: 4) {
                        Text("PERSONAL BEST")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(highScore)")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: onStart) {
                        ZStack {
                            Image("genotype_card_purple_thin")
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180)
                                .shadow(color: .black.opacity(0.3), radius: 6, y: 4)
                            
                            Text("START")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(breatheScale)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            breatheScale = 1.05
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}


struct InfiniteHUDView: View {
    let score: Int
    let lives: Int
    @Binding var wrongExplanation: String?
    
    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .top) {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { i in
                            Image(i < lives ? "slime_purple" : "slot_empty")
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .opacity(i < lives ? 1.0 : 0.4)
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.top, 100)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text("SCORE:")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.6))
                        Text("\(score)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 95)
                }
                Spacer()
            }
            
            if let explanation = wrongExplanation {
                WrongAnswerView(explanation: explanation) {
                    withAnimation { wrongExplanation = nil }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(100)
            }
        }
    }
}

struct InfiniteGameOverView: View {
    let score: Int
    let onMenu: () -> Void
    let onReplay: () -> Void
    
    @State private var breatheScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Image("bg_purple")
                .interpolation(.none)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.6))
            
            VStack(spacing: 40) {
                Text("GAME OVER")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    Text("Final Score")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(score)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text("Personal Best")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(GameState.shared.infiniteHighScore)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 12) {
                    Button(action: onMenu) {
                        ZStack {
                            Image("genotype_card_white_thin")
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                            
                            Text("MAIN MENU")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 160)
                        .scaleEffect(breatheScale)
                    }
                    
                    Button(action: onReplay) {
                        ZStack {
                            Image("genotype_card_purple_thin")
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                            
                            Text("PLAY AGAIN")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(width: 160)
                        .scaleEffect(breatheScale)
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        breatheScale = 1.05
                    }
                }
            }
        }
    }
}
