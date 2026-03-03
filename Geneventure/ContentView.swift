//
//  ContentView.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showCutscene = !UserDefaults.standard.bool(forKey: "hasSeenCutscene")
    var body: some View {
        if showCutscene {
            CutsceneView {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showCutscene = false
                }
            }
        } else {
            MenuView()
        }
    }
}
