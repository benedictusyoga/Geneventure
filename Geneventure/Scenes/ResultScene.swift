//
//  ResultScene.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI

struct ResultView: View {
    let levelData: LevelData
    let onContinue: () -> Void
    let onReplay: () -> Void
    @State private var appeared = false
    @State private var breathing = false
    @State private var showInfiniteUnlockAlert = false
    @ObservedObject private var gameState = GameState.shared

    var body: some View {
        ZStack {
            Image("bg_purple")
                .interpolation(.none)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            HStack(spacing: 80) {
                Image("star")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 140, maxWidth: 220, minHeight: 140, maxHeight: 220)
                    .shadow(color: .yellow.opacity(0.5), radius: 20)
                    .scaleEffect(appeared ? 1.0 : 0.3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appeared)

                VStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Text("Level Complete!")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, y: 2)
                        Text(levelData.title)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)

                    Button(action: onContinue) {
                        ZStack {
                            Image("genotype_card_white_thin")
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 240)
                                .shadow(color: .black.opacity(0.2), radius: 6, y: 4)

                            HStack(spacing: 8) {
                                Text("Continue")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                Image("arrow")
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                            }
                        }
                    }
                    .scaleEffect(breathing ? 1.05 : 0.97)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                            breathing = true
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.4), value: appeared)
                }
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            appeared = true
            if levelData.id == 10 && !gameState.hasSeenInfiniteUnlock {
                showInfiniteUnlockAlert = true
            }
        }
        .alert("Infinite Mode Unlocked!", isPresented: $showInfiniteUnlockAlert) {
            Button("Awesome!") {
                gameState.setSeenInfiniteUnlock()
            }
        } message: {
            Text("You've completed all levels and unlocked Infinite Mode! You can now access it from the main menu.")
        }
    }
}
