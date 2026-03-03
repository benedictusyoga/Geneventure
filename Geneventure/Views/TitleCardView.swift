//
//  TitleCardView.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI

struct TitleCardView: View {
    var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            ZStack {
                MenuSlimeView(color: .purple, shape: .spiky, size: 80 * scale)
                    .offset(x: 30 * scale, y: -50 * scale)
                    .rotationEffect(.degrees(10))
            }
            .frame(maxWidth: 420 * scale)

            Image("geneventure_title")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300 * scale)
                .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 6)
        }
    }
}

private struct MenuSlimeView: View {
    let color: ColorPhenotype
    let shape: ShapePhenotype
    let size: CGFloat
    
    @State private var bounce = false
    @State private var float = false
    
    private var imageName: String {
        switch (color, shape) {
        case (.purple, .round): return "slime_purple"
        case (.purple, .spiky): return "slime_purple_spiky"
        case (.white, .round): return "slime_white"
        case (.white, .spiky): return "slime_white_spiky"
        }
    }
    
    var body: some View {
        ZStack {
            Image(imageName)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
            
            HStack(spacing: size * 0.05) {
                Image("eye")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.4, height: size * 0.4)
                
                Image("eye")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.4, height: size * 0.4)
            }
            .offset(y: -size * 0.15)
        }
        .scaleEffect(bounce ? 1.08 : 0.94)
        .offset(y: float ? -5 : 5)
        .onAppear {
            let delay = Double.random(in: 0...0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    bounce = true
                }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    float = true
                }
            }
        }
    }
}
