//
//  ScratchPadView.swift
//  Geneventure
//
//  Created by Benedictus Yogatama Favian Satyajati on 02/03/26.
//

import SwiftUI

struct ScratchPadView: View {
    let isDihybrid: Bool
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var p1a1: Allele = .dominant
    @State private var p1a2: Allele = .recessive
    @State private var p2a1: Allele = .dominant
    @State private var p2a2: Allele = .recessive
    
    @State private var p1cDom1 = true;  @State private var p1cDom2 = false
    @State private var p1sDom1 = true;  @State private var p1sDom2 = false
    @State private var p2cDom1 = true;  @State private var p2cDom2 = false
    @State private var p2sDom1 = true;  @State private var p2sDom2 = false
    
    let onDismiss: () -> Void
    
    var p1: [Allele] { [p1a1, p1a2] }
    var p2: [Allele] { [p2a1, p2a2] }
    
    var offspringGrid: [[String]] {
        p1.map { rowAllele in
            p2.map { colAllele in
                [rowAllele.rawValue, colAllele.rawValue]
                    .sorted { $0 < $1 }
                    .joined()
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 0) {
                HStack {
                    Text("Scratch Pad")
                        .font(.headline)
                    Spacer()
                    Button("Done", action: onDismiss)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                
                ScrollView {
                    VStack(spacing: 20) {
                        if isDihybrid {
                            dihybridContent
                        } else {
                            monohybridContent
                        }
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .frame(maxWidth: sizeClass == .compact ? .infinity : 550,
                   maxHeight: sizeClass == .compact ? 520 : 650)
            .padding(.horizontal, sizeClass == .compact ? 16 : 0)
        }
        .environment(\.colorScheme, .light)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.default, value: offspringGrid)
    }
    
    struct Gamete {
        let colorDom: Bool
        let shapeDom: Bool
        var label: String { (colorDom ? "B" : "b") + (shapeDom ? "R" : "r") }
    }

    private func gametes(c1: Bool, c2: Bool, s1: Bool, s2: Bool) -> [Gamete] {
        [
            Gamete(colorDom: c1, shapeDom: s1),
            Gamete(colorDom: c1, shapeDom: s2),
            Gamete(colorDom: c2, shapeDom: s1),
            Gamete(colorDom: c2, shapeDom: s2)
        ]
    }

    private func genotypeLabel(c1: Bool, c2: Bool, s1: Bool, s2: Bool) -> String {
        let color = ([c1 ? "B" : "b", c2 ? "B" : "b"]).sorted { $0 < $1 }.joined()
        let shape = ([s1 ? "R" : "r", s2 ? "R" : "r"]).sorted { $0 < $1 }.joined()
        return color + shape
    }
    
    @ViewBuilder
    private var dihybridContent: some View {
        let p1Gametes = gametes(c1: p1cDom1, c2: p1cDom2, s1: p1sDom1, s2: p1sDom2)
        let p2Gametes = gametes(c1: p2cDom1, c2: p2cDom2, s1: p2sDom1, s2: p2sDom2)

        VStack(spacing: 20) {
            VStack(spacing: 12) {
                HStack {
                    Text("Parent 1:")
                        .fontWeight(.bold)
                    Spacer()
                    GenePickerPair(isDominant1: $p1cDom1, isDominant2: $p1cDom2, domId: "B", recId: "b")
                    Text("·").foregroundColor(.secondary)
                    GenePickerPair(isDominant1: $p1sDom1, isDominant2: $p1sDom2, domId: "R", recId: "r")
                    Spacer()
                    Text(genotypeLabel(c1: p1cDom1, c2: p1cDom2, s1: p1sDom1, s2: p1sDom2))
                        .font(.system(.body, design: .monospaced))
                }
                
                HStack {
                    Text("Parent 2:")
                        .fontWeight(.bold)
                    Spacer()
                    GenePickerPair(isDominant1: $p2cDom1, isDominant2: $p2cDom2, domId: "B", recId: "b")
                    Text("·").foregroundColor(.secondary)
                    GenePickerPair(isDominant1: $p2sDom1, isDominant2: $p2sDom2, domId: "R", recId: "r")
                    Spacer()
                    Text(genotypeLabel(c1: p2cDom1, c2: p2cDom2, s1: p2sDom1, s2: p2sDom2))
                        .font(.system(.body, design: .monospaced))
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)

            DihybridScratchGrid(rowGametes: p1Gametes, colGametes: p2Gametes)
        }
    }
    
    @ViewBuilder
    private var monohybridContent: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                HStack {
                    Text("Parent 1:")
                        .fontWeight(.bold)
                    Spacer()
                    Picker("", selection: $p1a1) {
                        Text("B").tag(Allele.dominant)
                        Text("b").tag(Allele.recessive)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)
                    Picker("", selection: $p1a2) {
                        Text("B").tag(Allele.dominant)
                        Text("b").tag(Allele.recessive)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)
                }
                
                HStack {
                    Text("Parent 2:")
                        .fontWeight(.bold)
                    Spacer()
                    Picker("", selection: $p2a1) {
                        Text("B").tag(Allele.dominant)
                        Text("b").tag(Allele.recessive)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)
                    Picker("", selection: $p2a2) {
                        Text("B").tag(Allele.dominant)
                        Text("b").tag(Allele.recessive)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            ScratchPunnettGrid(grid: offspringGrid, colHeaders: p2, rowHeaders: p1)
        }
    }
}

struct GenePickerPair: View {
    @Binding var isDominant1: Bool
    @Binding var isDominant2: Bool
    let domId: String
    let recId: String
    
    var body: some View {
        HStack(spacing: 4) {
            Picker("", selection: $isDominant1) {
                Text(domId).tag(true)
                Text(recId).tag(false)
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .frame(width: 60)
            
            Picker("", selection: $isDominant2) {
                Text(domId).tag(true)
                Text(recId).tag(false)
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .frame(width: 60)
        }
    }
}

struct ScratchPunnettGrid: View {
    let grid: [[String]]
    let colHeaders: [Allele]
    let rowHeaders: [Allele]

    @Environment(\.horizontalSizeClass) private var sizeClass
    private var cellSize: CGFloat { sizeClass == .compact ? 62 : 80 }
    private var headerSize: CGFloat { sizeClass == .compact ? 38 : 50 }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Color.clear.frame(width: headerSize, height: headerSize)
                ForEach(0..<colHeaders.count, id: \.self) { col in
                    Text(colHeaders[col].rawValue)
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .frame(width: cellSize, height: headerSize)
                }
            }
            
            ForEach(0..<grid.count, id: \.self) { row in
                HStack(spacing: 0) {
                    Text(rowHeaders[row].rawValue)
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .frame(width: headerSize, height: cellSize)
                    
                    ForEach(0..<grid[row].count, id: \.self) { col in
                        let genotype = grid[row][col]
                        let isPurple = genotype.contains("B")
                        
                        ZStack {
                            Rectangle()
                                .fill(isPurple ? Color.purple.opacity(0.12) : Color(UIColor.systemBackground))
                                .border(Color.secondary.opacity(0.3), width: 0.5)
                            Text(genotype)
                                .font(.system(.title3, design: .monospaced))
                                .foregroundColor(isPurple ? .purple : .primary)
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

private struct DihybridScratchGrid: View {
    let rowGametes: [ScratchPadView.Gamete]
    let colGametes: [ScratchPadView.Gamete]

    @Environment(\.horizontalSizeClass) private var sizeClass
    private var cellSize: CGFloat { sizeClass == .compact ? 50 : 64 }
    private var headerSize: CGFloat { sizeClass == .compact ? 32 : 40 }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Color.clear.frame(width: headerSize, height: headerSize)
                ForEach(0..<colGametes.count, id: \.self) { col in
                    Text(colGametes[col].label)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: cellSize, height: headerSize)
                }
            }

            ForEach(0..<rowGametes.count, id: \.self) { row in
                HStack(spacing: 0) {
                    Text(rowGametes[row].label)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: headerSize, height: cellSize)

                    ForEach(0..<colGametes.count, id: \.self) { col in
                        let hasB = rowGametes[row].colorDom || colGametes[col].colorDom
                        let hasR = rowGametes[row].shapeDom || colGametes[col].shapeDom

                        ZStack {
                            Rectangle()
                                .fill(hasB ? Color.purple.opacity(0.12) : Color(UIColor.systemBackground))
                                .border(Color.secondary.opacity(0.3), width: 0.5)
                            
                            Text(hasR ? "●" : "✦")
                                .font(.system(size: 18))
                                .foregroundColor(hasB ? .purple : .primary)
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
