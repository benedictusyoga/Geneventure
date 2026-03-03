//
//  GameContainerView.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI
import SpriteKit

struct GameContainerView: View {
    let levelData: LevelData
    
    @Environment(\.dismiss) private var dismiss
    @State private var activeHint: HintType? = nil
    @State private var wrongExplanation: String? = nil
    @State private var showResult = false
    @State private var scene: GameScene? = nil
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("bg_level")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .ignoresSafeArea()
            
            if let scene {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .id(scene)
                    .ignoresSafeArea()
                HUDView(
                    levelData: levelData,
                    activeHint: $activeHint,
                    wrongExplanation: $wrongExplanation
                )
                VStack {
                    CustomNavBarView(
                        title: levelData.title,
                        onBack: { dismiss() }
                    )
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            ResultView(
                levelData: levelData,
                onContinue: {
                    showResult = false
                    dismiss()
                },
                onReplay: {}
            )
        }
        .onAppear {
            buildScene()
            AudioManager.shared.playLevel()
        }
        .onDisappear {
            AudioManager.shared.playLevelSelect()
        }
    }
    
    private func buildScene() {
        let newScene: GameScene
        
        switch levelData.id {
        case 1: newScene = Level1Scene(size: sceneSize())
        case 2: newScene = Level2Scene(size: sceneSize())
        case 3: newScene = Level3Scene(size: sceneSize())
        case 4: newScene = Level4Scene(size: sceneSize())
        case 5: newScene = Level5Scene(size: sceneSize())
        case 6: newScene = Level6Scene(size: sceneSize())
        case 7: newScene = Level7Scene(size: sceneSize())
        case 8: newScene = Level8Scene(size: sceneSize())
        case 9: newScene = Level9Scene(size: sceneSize())
        case 10: newScene = Level10Scene(size: sceneSize())
        default: newScene = Level1Scene(size: sceneSize())
        }
        
        newScene.scaleMode = .resizeFill
        newScene.levelData = levelData
        newScene.onLevelComplete = { showResult = true }
        newScene.onShowHint = { hint in
            withAnimation { activeHint = hint }
        }
        newScene.onWrongAnswer = { explanation in
            withAnimation { wrongExplanation = explanation }
        }
        scene = newScene
    }
    
    private func sceneSize() -> CGSize {
        let screen = UIScreen.main.bounds
        return CGSize(width: screen.width, height: screen.height)
    }
    
}
