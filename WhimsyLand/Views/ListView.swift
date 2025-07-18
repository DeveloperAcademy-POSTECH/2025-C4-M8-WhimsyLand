//
//  ListView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI

struct ListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(MixedImmersiveState.self) private var mixedImmersiveState
    @Environment(PlaceableItemStore.self) private var placeableItemStore
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(ModelLoader.self) private var modelLoader
    @State private var searchText = ""
    
    var module: Module
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Object(10)")
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
            
            // Mixed Immersive Enter Button
            Button("Try Enter") {
                Task {
                    await mixedImmersiveState.requestWorldSensingAuthorization()
                    
                    switch await openImmersiveSpace(id: UIIdentifier.immersiveSpace) {
                    case .opened:
                        print("Immersive space opened successfully: \(UIIdentifier.immersiveSpace)")
                        break
                    case .error:
                        print("An error occurred when trying to open the immersive space \(UIIdentifier.immersiveSpace)")
                    case .userCancelled:
                        print("The user declined opening immersive space \(UIIdentifier.immersiveSpace)")
                    @unknown default:
                        break
                    }
                }
            }
            .disabled(!mixedImmersiveState.canEnterMixedImmersiveSpace)
            
            Spacer()
            
            // Book Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)
                ], spacing: 30) {
                    
                    // Additional placeholder books for scrolling
                    ForEach(1..<10) { index in
                        VStack(spacing: 20) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.6))
                                .frame(width:304, height: 328)
                            
                            Text("Book Title \(index)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(width:1020, height: 678)
        .cornerRadius(20)
        .overlay{
            if mixedImmersiveState.mixedImmersiveSpaceOpened {
                ObjectPlacementMenuView(
                    mixedImmersiveState: mixedImmersiveState, placeableItemStore: placeableItemStore)
                    .padding(20)
                    .glassBackgroundEffect()
            }
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase == .active {
                Task {
                    await mixedImmersiveState.queryWorldSensingAuthorization()
                }
            } else {
                if mixedImmersiveState.mixedImmersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        mixedImmersiveState.didLeaveMixedImmersiveSpace()
                    }
                }
            }
        }
        .onChange(of: mixedImmersiveState.providersStoppedWithError, { _, providersStoppedWithError in
            if providersStoppedWithError {
                if mixedImmersiveState.mixedImmersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        mixedImmersiveState.didLeaveMixedImmersiveSpace()
                    }
                }
                mixedImmersiveState.providersStoppedWithError = false
            }
        })
        .task {
            if mixedImmersiveState.allRequiredProvidersAreSupported {
                await mixedImmersiveState.requestWorldSensingAuthorization()
            }
        }
        .task {
            await mixedImmersiveState.monitorSessionEvents()
        }
    }
}

#Preview("ThreeLittlePigs") {
    NavigationStack {
        ListView(
            module: .threeLittlePigs
        )
        .environment(MixedImmersiveState())
    }
}
