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
    
    private let toyModule: ToyModule = .ragHouse // TODO: 선택한 toy 받아오기
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(toyModule.name)
                    .font(.pretendard(.bold,size: 34))
                Divider()
                Text(toyModule.overview)
                    .font(.pretendard(.regular, size: 26))
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
                .frame(maxWidth: 400, alignment: .leading)

                Text(toyModule.description)
                    .font(.pretendard(.light, size: 24))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 608)

                Text(toyModule.callToAction)
                    .font(.pretendard(.semibold, size: 26))
                Spacer()
            }
            .padding(40)
            .frame(width: 980, height: 491)
            .glassBackgroundEffect() 
            .cornerRadius(46)

                toyModule.detailView
        }
    }
}

private struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.pretendard(.semibold, size: 20))
            Divider()
            Text(value)
                .font(.pretendard(.regular, size: 18))
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
