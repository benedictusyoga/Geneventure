//
//  CustceneView.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI

struct CutsceneView: View {
    let onFinish: () -> Void
    @State private var currentPage = 0
    
    private let slides: [(imageName: String, caption: String, hasMagnifier: Bool)] = [
        ("cutscene", "Ugh! Big B, little b... it’s all just alphabet soup! I'll never understand how genetics works. It's impossible!", false),
        ("bg_menu", "Wait a second... those slimes in the yard. Some are purple, but others are white? There is a pattern here... I just need to see it closer.", false),
        ("bg_menu", "Alright, little friends, will you teach me your secrets? Let's start the... Geneventure!", true)
    ]
    
    var body: some View {
        ZStack {
            Color(hue: 0.75, saturation: 0.08, brightness: 0.97)
                .ignoresSafeArea()
            
            SlideView(slide: slides[currentPage], isLast: currentPage == slides.count - 1)
                .id(currentPage)
                .transition(.opacity)
            
            Color.white.opacity(0.0001)
                .ignoresSafeArea()
                .onTapGesture {
                    if currentPage < slides.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }
            
            Button("Skip") {
                markSeenAndFinish()
            }
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(24)
            .frame(maxHeight: .infinity, alignment: .topTrailing)
            
            if currentPage == slides.count - 1 {
                VStack {
                    Spacer()
                    Button {
                        markSeenAndFinish()
                    } label: {
                        ZStack {
                            Image("genotype_card_purple_thin")
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 240)
                                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
                            
                            Text("Let's Go!")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 4)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4), value: currentPage)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            AudioManager.shared.playLevel()
        }
    }
    
    private func markSeenAndFinish() {
        UserDefaults.standard.set(true, forKey: "hasSeenCutscene")
        onFinish()
    }
}

private struct SlideView: View {
    let slide: (imageName: String, caption: String, hasMagnifier: Bool)
    let isLast: Bool
    @State private var isAnimating = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geo in
                Image(slide.imageName)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width * 1.3, height: geo.size.height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .offset(x: isAnimating ? -(geo.size.width * 0.15) : (geo.size.width * 0.15))
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 12.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            if slide.hasMagnifier {
                GeometryReader { geo in
                    Image("magnifier")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(x: isAnimating ? geo.size.width * 0.7 : geo.size.width * 0.3,
                                  y: isAnimating ? geo.size.height * 0.3 : geo.size.height * 0.5)
                        .scaleEffect(isAnimating ? 1.05 : 0.95)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                                isAnimating = true
                            }
                        }
                }
            }
            
            VStack(spacing: 0) {
                Spacer()
                ZStack {
                    Image("genotype_card_pale")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                    
                    Text(slide.caption)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.black.opacity(0.8))
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 64)
                        .padding(.vertical, 32)
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 64)
                
                if !isLast {
                    Text("Tap to continue...")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, y: 1)
                        .opacity(0.6)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                } else {
                    Spacer().frame(height: 130)
                }
            }
        }
    }
}
