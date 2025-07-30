//
//  ToyDetailView.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/14/25.
//

import SwiftUI

struct ToyDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(ToyModel.self) private var toyModel
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        HStack {
            if let item = toyModel.selectedItem {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 40) {
                        Button(action: {
                            if viewModel.isListWindowShown == false {
                                openWindow(id: viewModel.HomeViewID)
                            }
                            dismissWindow(id: viewModel.ToyDetailViewID)
                        }){
                            Image(systemName: "xmark")
                                .aspectRatio(contentMode: .fit)
                        }.frame(width: 44, height: 44)
                        
                        Text(item.module?.name ?? "")
                            .font(.pretendard(.bold,size: 34))
                    }
                    Divider()
                    Text(item.module?.overview ?? "")
                        .font(.pretendard(.regular, size: 26))
                    HStack(spacing: 20) {
                        InfoCard(title: "주인", value: item.module?.owner ?? "")
                        InfoCard(title: "재료", value: item.module?.material ?? "")
                        
                        EnterFullButton(toyItem: item)
                            .environment(viewModel)
                    }
                    .padding(.vertical, 20)
                    Text(item.module?.description ?? "")
                        .font(.pretendard(.light, size: 24))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(item.module?.callToAction ?? "")
                        .font(.pretendard(.semibold, size: 26))
                }
                .padding(40)
                .frame(width: 608)
        ToyPreview(modelName: item.ModelName)
    }
        }
    .padding(40)
    .frame(width: 980, height: 491, alignment: .leading)
    .glassBackgroundEffect()
    .cornerRadius(46)
    .onDisappear{
            viewModel.isSecondaryWindowShown = false
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
