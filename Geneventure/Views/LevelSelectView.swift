//
//  LevelSelectView.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI

struct LevelSelectView: View {
    @ObservedObject private var gameState = GameState.shared
    @State private var selectedLevel: LevelData? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            CustomNavBarView(title: "Choose a Level", onBack: { dismiss() })

            ScrollView {
                VStack(spacing: 60) {
                    ForEach(Array(allLevels.enumerated()), id: \.element.id) { index, level in
                        LevelCardView(
                            level: level,
                            isUnlocked: gameState.isUnlocked(level.id),
                            isCompleted: gameState.isCompleted(level.id)
                        )
                        .id("\(level.id)-\(gameState.isCompleted(level.id))")
                        .frame(width: 220)
                        .offset(x: CGFloat(sin(Double(index) * 1.2)) * 50)
                        .onTapGesture {
                            if gameState.isUnlocked(level.id) {
                                selectedLevel = level
                            }
                        }
                    }
                }
                .background(LevelPathView(count: allLevels.count))
                .padding(.vertical, 40)
                .frame(maxWidth: .infinity)
            }
        }
        .background(
            Image("bg_level_select")
                .interpolation(.none)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .onAppear {
            AudioManager.shared.playLevelSelect()
        }
        .fullScreenCover(item: $selectedLevel) { level in
            GameContainerView(levelData: level)
        }
    }
}

struct LevelCardView: View {
    let level: LevelData
    let isUnlocked: Bool
    let isCompleted: Bool
    
    @State private var isBreathing = false
    
    var isCurrent: Bool {
        isUnlocked && !isCompleted
    }
    
    var backgroundImage: String {
        if isCompleted { return "slot_filled" }
        if isUnlocked { return "slot_current" }
        return "slot_empty"
    }

    var textColor: Color {
        if isCompleted { return .white }
        if isUnlocked { return .black }
        return .secondary
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Image(backgroundImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: isUnlocked ? Color.black.opacity(0.3) : .clear, radius: 4, x: 0, y: 3)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(textColor)
                } else if isUnlocked {
                    Text("\(level.id)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(textColor)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 60, weight: .semibold))
                        .foregroundColor(textColor.opacity(0.5))
                }
            }
            .aspectRatio(1, contentMode: .fit)
            
            Text(level.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                )
        }
        .opacity(isUnlocked ? 1.0 : 0.7)
        .scaleEffect(isCurrent ? (isBreathing ? 1.05 : 0.98) : (isUnlocked ? 1.0 : 0.95))
        .onAppear {
            if isCurrent {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isBreathing = true
                }
            }
        }
    }
}

struct LevelPathView: View {
    let count: Int
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let itemHeight: CGFloat = 260
                let spacing: CGFloat = 60
                
                let centerX = geo.size.width / 2
                
                for i in 0..<count {
                    let y = (CGFloat(i) * (itemHeight + spacing)) + (itemHeight / 2)
                    let xOffset = CGFloat(sin(Double(i) * 1.2)) * 50
                    let x = centerX + xOffset
                    
                    let point = CGPoint(x: x, y: y)
                    
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        let prevY = (CGFloat(i - 1) * (itemHeight + spacing)) + (itemHeight / 2)
                        let prevXOffset = CGFloat(sin(Double(i - 1) * 1.2)) * 50
                        let prevX = centerX + prevXOffset
                        
                        let cpY = (y + prevY) / 2
                        path.addCurve(to: point, control1: CGPoint(x: prevX, y: cpY), control2: CGPoint(x: x, y: cpY))
                    }
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 10, dash: [15, 20], dashPhase: 0))
            .foregroundColor(.black.opacity(0.3))
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
        }
    }
}
