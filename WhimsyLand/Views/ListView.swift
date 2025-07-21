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
    @Environment(ViewModel.self) var model
    @Environment(PlaceableItemStore.self) var placeableItemStore
    @State private var searchText = ""
    @State private var isDetailActive = false
    
    // TODO : viewmodel 이동해야함
    let itemImages = ["BrickHouse","RagHouse","TreeHouse"]
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("아이템 \(itemImages.count)개")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
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
                    ForEach(itemImages, id: \.self) { index in
                        VStack(spacing: 20) {
                            VStack{
                                Image("\(index)")
                                    .resizable()
                                    .scaledToFit()
                                
                                
                                Text("\(index)")
                                    .font(.title3)
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "#5E5E5E29").opacity(0.16))
                            )
                            .hoverEffect()
                            .onTapGesture {
                                if let index = itemImages.firstIndex(of: index){
                                    placeableItemStore.selectedFileName = itemImages[index]
                                    openWindow(id: "Toy")
                                    print("\(placeableItemStore.selectedFileName)가 선택됨")
                                }
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
            model.mixedImmersiveState.mixedImmersiveMode = .editing
            print("🛠️ mixedImmersiveMode = editing")
        }
        .onDisappear{
            dismissWindow(id:"Toy")
        }
    }
}

//#Preview("ThreeLittlePigs") {
//    NavigationStack {
//        ListView(
//            immersiveSpaceIdentifier: "Object Placement",
//            module: .threeLittlePigs
//        )
//        .environment(AppState())
//    }
//}
