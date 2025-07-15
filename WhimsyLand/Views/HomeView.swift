//
//  HomeView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI

struct Book {
    let id = UUID()
    let title: String
    let imageName: String?
    let coverColor: Color
}

struct HomeView: View {
    @Environment(ViewModel.self) private var model
    @Environment(AppState.self) private var appState
    @Environment(ModelLoader.self) private var modelLoader
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var searchText = ""
    @State private var currentPage = 0
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        //        @Bindable var model = model
        
        NavigationStack{
            VStack {
                // Header
                HStack {
                    Text("WhimsyLand")
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
                }.padding(20)
                
                Spacer()
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 20) {
                        ForEach(Module.allCases) { module in
                            NavigationLink(destination: ListView(module: module)) {
                                FairyTaleCard(module: module)
                            }.buttonBorderShape(.roundedRectangle(radius: 20))
                                .frame(width: 276, height: 344)
                        }
                    }
                    .padding(.horizontal, 20)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            }
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase == .active {
                Task {
                    await appState.queryWorldSensingAuthorization()
                }
            } else {
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
            }
        }
        .onChange(of: appState.providersStoppedWithError, { _, providersStoppedWithError in
            if providersStoppedWithError {
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
                appState.providersStoppedWithError = false
            }
        })
        .task {
            if appState.allRequiredProvidersAreSupported {
                await appState.requestWorldSensingAuthorization()
            }
        }
        .task {
            await appState.monitorSessionEvents()
        }
        .task {
            await modelLoader.loadObjects()
            await MainActor.run {
                appState.setPlaceableObjects(modelLoader.placeableObjects)
            }
        }
        .task {
            guard appState.canEnterImmersiveSpace else { return }
            let result = await openImmersiveSpace(id: "Object Placement")
            if case .opened = result {
                print("immersiveSpace opened successfully.")
            }
        }
    }
}


#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 1020, height: 540)) {
    HomeView()
}
