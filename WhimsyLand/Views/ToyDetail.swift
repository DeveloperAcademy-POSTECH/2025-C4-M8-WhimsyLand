//
//  ToyDetail.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/14/25.
//

import SwiftUI

struct ToyDetail: View {
    @Environment(ViewModel.self) var model
    @Environment(PlaceableItemStore.self) var placeableItemStore
    let toyModule : ToyModule
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(toyModule.name)
                    .font(.system(size: 34, weight: .bold))
                Divider()
                Text(toyModule.overview)
                    .font(.system(size: 26, weight: .regular))
                HStack(spacing: 20) {
                    InfoCard(title: "주인", value: toyModule.owner)
                    InfoCard(title: "재료", value: toyModule.material)
                    Button("꺼내서 조작하기") {
                        // 테스트용: 첫 번째 PlaceableObject 가져오기
                        if let first = placeableItemStore.placeableObjectsByFileName.values.first {
                            model.mixedImmersiveState.placementManager?.selectObject(first)
                            print("👉 \(first.descriptor.fileName)를 선택함")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(model.currentImmersiveMode != .mixed)

                }
                .frame(maxWidth: 328, alignment: .leading)

                Text(toyModule.description)
                    .font(.system(size: 24, weight: .light))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 608)

                Text(toyModule.callToAction)
                    .font(.system(size: 26, weight: .semibold))
                Spacer()
            }
            .padding(40)
            .frame(width: 980, height: 451)
            .background()
            .cornerRadius(46)
            
            toyModule.detailView
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

extension ToyModule {
    @ViewBuilder
    fileprivate var detailView: some View {
        Toy()
    }
}
