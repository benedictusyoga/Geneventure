//
//  HUDView.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI

struct HintPopupView: View {
    let hint: HintType
    let onDismiss: () -> Void
    
    var icon: String {
        switch hint {
        case .revealAllele: return "eye.fill"
        case .showRatio: return "chart.bar.fill"
        case .explainRule: return "lightbulb.fill"
        }
    }
    
    var message: String {
        switch hint {
        case .revealAllele(let s),
                .showRatio(let s),
                .explainRule(let s): return s
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))
                
                Text("Hint")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                Text(message)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                Button(action: onDismiss) {
                    Text("Got it!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.4, green: 0.2, blue: 0.6))
                        .clipShape(Capsule())
                }
            }
            .padding(32)
            .frame(maxWidth: 320)
            .background(
                Image("plate")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFill()
            )
            .clipped()
            .padding(24)
        }
        .transition(.opacity.combined(with: .scale))
    }
}

struct WrongAnswerView: View {
    let explanation: String
    let onRetry: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            
            VStack(spacing: 12) {
                Text("Not quite!")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.red)
                
                Text(explanation)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Button(action: onRetry) {
                    Text("Try Again")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.9))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: 440)
            .background(
                Image("plate")
                    .interpolation(.none)
                    .resizable()
            )
            .padding(16)
        }
        .transition(.opacity.combined(with: .scale))
    }
}

struct HUDView: View {
    let levelData: LevelData
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var showScratchPad = false
    @Binding var activeHint: HintType?
    @Binding var wrongExplanation: String?
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer()
            }
            if levelData.id >= 6 {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.35)) {
                                showScratchPad = true
                            }
                        } label: {
                            Image("scratch_pad")
                                .resizable()
                                .scaledToFit()
                                .frame(width: sizeClass == .compact ? 52 : 80,
                                       height: sizeClass == .compact ? 52 : 80)
                                .shadow(radius: 6, y: 3)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 8)
                    }
                    Spacer()
                }
            }
            if let hint = activeHint {
                HintPopupView(hint: hint) {
                    withAnimation { activeHint = nil }
                }
                .zIndex(10)
            }
            if let explanation = wrongExplanation {
                WrongAnswerView(explanation: explanation) {
                    withAnimation { wrongExplanation = nil }
                }
                .zIndex(11)
            }
            if showScratchPad {
                ScratchPadView(isDihybrid: levelData.id >= 9) {
                    withAnimation(.spring(response: 0.35)) { showScratchPad = false }
                }
                .zIndex(15)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: activeHint != nil)
        .animation(.easeInOut(duration: 0.25), value: wrongExplanation != nil)
    }
}
