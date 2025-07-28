//
//  ListView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI
import RealityKit

struct ListView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    @Environment(ViewModel.self) var viewModel
    @Environment(ToyModel.self) var toyModel
    @Environment(PlaceableToyStore.self) var placeableToyStore
    
    @State private var searchText = ""
    
    var body: some View {
        
        VStack {
            HStack{
                Button(action: {
                    openWindow(id: viewModel.HomeViewID)
                }){
                    Image(systemName: "chevron.left")
                        .padding(14)
                }.frame(width: 44, height: 44)
                
                Text("아이템 \(toyModel.items.count)개")
                    .font(.pretendard(.bold, size: 29))
                Spacer()
            }.padding([.top, .leading], 24)
            Spacer()
            
            // Book Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)
                ], spacing: 30) {
                    // 아이템을 3 x 3 리스트 형태
                    ForEach(toyModel.items) { item in
                        ToyCard(imageName: item.ImageName, label: item.label) {
                            placeableToyStore.selectedFileName = item.ModelName
                            toyModel.selectedItem = item
                            
                            // 선택한 아이템 현실공간으로 꺼내오기
                            if let first = placeableToyStore.placeableToysByFileName.values.first {
                                viewModel.mixedImmersiveState.placementManager?.selectToy(first)
                                print("👉 \(first.descriptor.fileName)를 선택함")
                            }
                            
                            if viewModel.isSecondaryWindowShown != true {
                                openWindow(id: viewModel.ToyDetailViewID)
                                viewModel.isSecondaryWindowShown = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .cornerRadius(20)
        .persistentSystemOverlays(.hidden)
        .onAppear {
            viewModel.mixedImmersiveState.mixedImmersiveMode = .editing
            viewModel.isListWindowShown = true
            dismissWindow(id: viewModel.HomeViewID)
        }
        .onDisappear{
            dismissWindow(id:viewModel.ToyDetailViewID)
            viewModel.isListWindowShown = false
        }
    }
}
