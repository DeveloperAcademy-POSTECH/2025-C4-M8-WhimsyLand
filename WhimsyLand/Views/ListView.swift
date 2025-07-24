//
//  ListView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI
import RealityKit

struct ListView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    @Environment(ViewModel.self) var model
    @Environment(ToyModel.self) var toyModel
    @Environment(PlaceableItemStore.self) var placeableItemStore
    
    @State private var searchText = ""
    
    var body: some View {
        
        VStack {
            // Header
            HStack {
                Text("아이템 \(toyModel.items.count)개")
                    .font(.pretendard(.bold, size: 29))
                
                Spacer()
                
                // Search Bar
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
                .frame(width: 300)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
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
                            placeableItemStore.selectedFileName = item.ModelName
                            openWindow(id: "Toy", value: item)
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .cornerRadius(20)
        .persistentSystemOverlays(.hidden)
        .onAppear {
            model.mixedImmersiveState.mixedImmersiveMode = .editing
        }
        .onDisappear{
            dismissWindow(id:"Toy")
        }
    }
}
