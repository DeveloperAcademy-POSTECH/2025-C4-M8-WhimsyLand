//
//  ToyDetail.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/14/25.
//

import SwiftUI

struct ToyDetail: View {
    @Environment(ViewModel.self) private var model
    
    @State private var isMonitoring = true
    var module: ToyData
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(module.name)
                    .font(.system(size: 34, weight: .bold))
                Divider()
                Text(module.overview)
                    .font(.system(size: 26, weight: .regular))
                HStack(spacing: 20) {
                    InfoCard(title: "주인", value: module.owner)
                    InfoCard(title: "재료", value: module.material)
                }
                .frame(maxWidth: 328, alignment: .leading)
                
                Text(module.description)
                    .font(.system(size: 24, weight: .light))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 608)
                
                Text(module.callToAction)
                    .font(.system(size: 26, weight: .semibold))
                Spacer()
            }
            .padding(40)
            .frame(width: 980, height: 451)
            .background()
            .cornerRadius(46)
            
            module.detailView
                .frame(width: 560, height: 560)
                .position(x: 820, y: 225)
        }
    }
}

private struct InfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
            Divider()
            Text(value)
                .font(.system(size: 18, weight: .regular))
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
    }
}

extension ToyData {
    @ViewBuilder
    fileprivate var detailView: some View {
        Toy()
    }
}
