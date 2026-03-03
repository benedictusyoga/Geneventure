//
//  GeneventureApp.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI

@main
struct GeneventureApp: App {
    init() {
        registerCustomFont(fontName: "PixelifySans-VariableFont_wght", fontExtension: "ttf")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(GameState.shared)
        }
    }
}
