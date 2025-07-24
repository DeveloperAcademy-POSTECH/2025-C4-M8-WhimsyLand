//
//  ToyDetail.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/14/25.
//

import SwiftUI

struct ToyDetail: View {
    @Environment(ViewModel.self) private var model
    @Environment(ToyModel.self) private var toyModel
    @Environment(PlaceableItemStore.self) var placeableItemStore
    
    @State private var isMonitoring = true
    
    @Binding var item: ToyItem?

    var body: some View {
        ZStack {
            if let item = item {
            VStack(alignment: .leading, spacing: 20) {
                Text(item.module?.name ?? "")
                    .font(.system(size: 34, weight: .bold))
                Divider()
                Text(item.module?.overview ?? "")
                    .font(.system(size: 26, weight: .regular))
                HStack(spacing: 20) {
                    InfoCard(title: "주인", value: item.module?.owner ?? "")
                    InfoCard(title: "재료", value: item.module?.material ?? "")
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
                
                Text(item.module?.description ?? "")
                    .font(.system(size: 24, weight: .light))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 608)
                
                Text(item.module?.callToAction ?? "")
                    .font(.system(size: 26, weight: .semibold))
                Spacer()
            }
            .padding(40)
            .frame(width: 980, height: 451)
            .background()
            .cornerRadius(46)
                Toy2(modelName: item.ModelName, modelDepth: 200, modelSize: 560, modelScale: 1, modelOrientation: [0, 0, 0])
            }
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
