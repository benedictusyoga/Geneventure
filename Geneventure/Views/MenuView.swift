//
//  MenuView.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI
import SpriteKit

struct MenuView: View {
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var isSliding = false
    @State private var showLockedAlert = false
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var gameState = GameState.shared

    private var isCompact: Bool { sizeClass == .compact }

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    Image("bg_menu")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width * 1.3, height: geo.size.height)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        .offset(x: isSliding ? -(geo.size.width * 0.15) : (geo.size.width * 0.15))
                }
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.4).ignoresSafeArea())
                .onAppear {
                    AudioManager.shared.playMenu()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(Animation.easeInOut(duration: 12.0).repeatForever(autoreverses: true)) {
                            isSliding = true
                        }
                    }
                }

                if isCompact {
                    VStack(spacing: 24) {
                        TitleCardView(scale: 0.85)

                        menuButtons
                    }
                    .padding(.vertical, 32)
                } else {
                    GeometryReader { geo in
                        let isNarrowRegular = geo.size.width < 900
                        let hSpacing: CGFloat    = isNarrowRegular ? 32  : 80
                        let titleScale: CGFloat  = isNarrowRegular ? 1.0 : 1.3

                        HStack(spacing: hSpacing) {
                            TitleCardView(scale: titleScale)
                                .offset(y: -20)

                            menuButtons
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button {
                    audioManager.toggleMute()
                } label: {
                    Image(systemName: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, y: 2)
                }
                .padding(.top, isCompact ? 16 : 56)
                .padding(.trailing, 20)
            }
            .alert("Laboratory Locked", isPresented: $showLockedAlert) {
                Button("Got it!", role: .cancel) { }
            } message: {
                Text("You need to complete all 10 story levels in the Laboratory before you can unlock Infinite Mode!")
            }
        }
    }

    @ViewBuilder
    private var menuButtons: some View {
        VStack(spacing: isCompact ? -10 : -16) {
            NavigationLink(destination: LevelSelectView()) {
                MenuButtonLabel(title: "Laboratory", isCompact: isCompact)
            }

            if gameState.isCompleted(10) {
                NavigationLink(destination: InfiniteContainerView()) {
                    MenuButtonLabel(title: "Infinite Mode", isCompact: isCompact)
                }
            } else {
                Button {
                    showLockedAlert = true
                } label: {
                    MenuButtonLabel(title: "Infinite Mode", isLocked: true, isCompact: isCompact)
                }
            }

            NavigationLink(destination: CreditsView(categories: creditsData)) {
                MenuButtonLabel(title: "Credits", isCompact: isCompact)
            }

            Button {
                exit(0)
            } label: {
                MenuButtonLabel(title: "Quit Game", isCompact: isCompact)
            }
        }
    }
    
    private struct MenuButtonLabel: View {
        let title: String
        var isLocked: Bool = false
        var isCompact: Bool = false

        var body: some View {
            ZStack {
                Image(isLocked ? "genotype_card_white_thin" : "genotype_card_purple_thin")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: isCompact ? 200 : 240)
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)

                HStack(spacing: 8) {
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: isCompact ? 12 : 14, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    Text(title)
                        .font(.system(size: isCompact ? 15 : 18, weight: .black, design: .rounded))
                        .foregroundColor(isLocked ? .gray : .white)
                }
            }
            .padding(.vertical, isCompact ? 2 : 4)
            .opacity(isLocked ? 0.7 : 1.0)
        }
    }
    
    struct CreditItem: Identifiable {
        let id = UUID()
        let detail: String
        let name: String
        let url: String?
    }
    
    struct CreditCategory: Identifiable {
        let id = UUID()
        let title: String
        let items: [CreditItem]
    }
    
    private let creditsData: [CreditCategory] = [
        CreditCategory(title: "Creator", items: [
            CreditItem(detail: "Made With Love", name: "Benedictus Yogatama", url: nil)
        ]),
        CreditCategory(title: "Visual Assets", items: [
            CreditItem(detail: "All Assets Made By", name: "Benedictus Yogatama", url: nil),
            CreditItem(detail: "Using", name: "Piskel - Free online sprite editor", url: nil)
        ]),
        CreditCategory(title: "Music", items: [
            CreditItem(detail: "All Music Made By", name: "Benedictus Yogatama", url: nil),
            CreditItem(detail: "Using", name: "BandLab - Music creation platform", url: nil)
        ]),
        CreditCategory(title: "Sound Effects", items: [
            CreditItem(detail: "\"Correct\" used for correct answers", name: "DRAGON-STUDIO (via Pixabay)", url: "https://pixabay.com/sound-effects/technology-correct-472358/"),
            CreditItem(detail: "\"Error 010\" used for wrong answers", name: "Universfield (via Pixabay)", url: "https://pixabay.com/sound-effects/film-special-effects-error-010-206498/"),
            CreditItem(detail: "\"Slime Squish 5\" used for slime sounds", name: "floraphonic (via Pixabay)", url: "https://pixabay.com/sound-effects/film-special-effects-slime-squish-5-218569/"),
            CreditItem(detail: "\"Bonus Points\" used for level completions", name: "Liecio (via Pixabay)", url: "https://pixabay.com/sound-effects/film-special-effects-bonus-points-190035/")
        ]),
        CreditCategory(title: "Playtesters", items: [
            CreditItem(detail: "Playtester 1", name: "Muhammad Azmi", url: nil),
            CreditItem(detail: "Playtester 2", name: "Teuku Fazariz Basya", url: nil),
            CreditItem(detail: "Playtester 3", name: "Maria Yohanna Shayna Putri", url: nil)
        ]),
        CreditCategory(title: "Inspirations", items: [
            CreditItem(detail: "Visual", name: "Stardew Valley, Pokemon, Super Mario Bros.", url: nil),
            CreditItem(detail: "Mechanics", name: "Duolingo, Lego Bricks", url: nil)
        ])
    ]
    
    struct CreditsView: View {
        @Environment(\.dismiss) private var dismiss
        let categories: [CreditCategory]
        
        var body: some View {
            VStack(spacing: 0) {
                CustomNavBarView(title: "Credits", titleColor: .white, onBack: { dismiss() })
                    .padding(.top, 44)
                
                ScrollView {
                    VStack(spacing: 48) {
                        ForEach(categories) { category in
                            VStack(spacing: 16) {
                                Text(category.title.uppercased())
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundColor(.purple)
                                    .kerning(2)
                                
                                VStack(spacing: 24) {
                                    ForEach(category.items) { item in
                                        VStack(spacing: 6) {
                                            Text(item.detail)
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.white.opacity(0.5))
                                            
                                            Text(item.name)
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                            
                                            if let url = item.url, let linkURL = URL(string: url) {
                                                Link(destination: linkURL) {
                                                    Text(url)
                                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                                        .foregroundColor(.purple.opacity(0.7))
                                                        .underline()
                                                        .multilineTextAlignment(.center)
                                                }
                                                .padding(.horizontal, 40)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text("© 2026 Benedictus Yogatama")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.top, 20)
                        }
                        .padding(.bottom, 60)
                    }
                    .padding(.top, 40)
                }
            }
            .background(
                ZStack {
                    Image("bg_menu")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    Color.black.opacity(0.85)
                        .ignoresSafeArea()
                }
            )
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MenuView()
}
