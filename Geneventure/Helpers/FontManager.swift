//
//  FontManager.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI
import CoreText
import UIKit

func registerCustomFont(fontName: String, fontExtension: String) {
    guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: fontExtension) else {
        print("❌ Couldn't find font file: \(fontName).\(fontExtension)")
        return
    }
    var error: Unmanaged<CFError>?
    CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
    if let error = error {
        print("❌ Font registration failed: \(error)")
    } else {
        print("✅ Font registered successfully: \(fontName)")
    }
}

extension Font {
    static func pixelify(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let pixelifyName = "PixelifySans-Regular"
        
        if UIFont(name: pixelifyName, size: size) != nil {
            return .custom(pixelifyName, size: size)
        }
        
        return .system(size: size, weight: weight, design: .rounded)
    }
}
