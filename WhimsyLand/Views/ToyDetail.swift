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
    @Environment(PlaceableToyStore.self) var placeableToyStore
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        ZStack {
            if let item = toyModel.selectedItem {
                
                VStack(alignment: .leading, spacing: 20) {
                    Text(item.module?.name ?? "")
                        .font(.pretendard(.bold,size: 34))
                    Divider()
                    Text(item.module?.overview ?? "")
                        .font(.pretendard(.regular, size: 26))
                    HStack(spacing: 20) {
                        InfoCard(title: "주인", value: item.module?.owner ?? "")
                        InfoCard(title: "재료", value: item.module?.material ?? "")
                        Button("꺼내서 조작하기") {
                            if let toy = placeableToyStore.placeableToysByFileName[item.ModelName] {
                                model.mixedImmersiveState.placementManager?.selectToy(toy)
                                print("👉 \(toy.descriptor.fileName)를 선택함")
                            } else {
                                print("⚠️ 대응하는 PlaceableToy를 찾을 수 없습니다.")
                            }
                            dismissWindow(id: model.ToyDetailViewID)
                        }
                        .buttonStyle(.bordered)
                        .disabled(model.currentImmersiveMode != .mixed)
                        
                        EnterFullButton(toyItem: item)
                            .environment(model)
                    }
                    .frame(maxWidth: 400, alignment: .leading)
                    
                    Text(item.module?.description ?? "")
                        .font(.pretendard(.light, size: 24))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 608)
                    
                    Text(item.module?.callToAction ?? "")
                        .font(.pretendard(.semibold, size: 26))
                    Spacer()
                }
                .padding(40)
                .frame(width: 980, height: 491)
                .glassBackgroundEffect()
                .cornerRadius(46)
                
                ToyPreview(modelName: item.ModelName)
            }
        }.onDisappear{
            toyModel.isSecondaryWindowShown = false
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
}
