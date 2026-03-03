//
//  CustomNavbarView.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI

struct CustomNavBarView: View {
    let title: String
    var subtitle: String? = nil
    var titleColor: Color = .black
    var onBack: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                if let onBack {
                    Button(action: onBack) {
                        Image("back_button")
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 44)
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                    .padding(.leading, 16)
                }

                VStack(spacing: -4) {
                    Text(title)
                        .font(.pixelify(size: 32, weight: .bold))
                        .foregroundColor(titleColor)

                    Image("level_select_border")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 220)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.pixelify(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.4), radius: 0, x: 1, y: 1)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
            .padding(.top, 4)
        }
    }
}
