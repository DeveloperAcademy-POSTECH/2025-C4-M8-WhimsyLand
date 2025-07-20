//
//  WhimsyLandApp.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/8/25.
//

import SwiftUI

// TODO: 삭제 또는 viewModel 또는 AppSate로 이동
enum UIIdentifier {
    static let immersiveSpace = "Object Placement"
}

@main
struct WhimsyLandApp: App {
    @State private var model = ViewModel()

    // item에 따라 다른 immersion 스타일
    @State private var houseImmersionStyle: ImmersionStyle = .full
    @State private var mixedImmersiveState = MixedImmersiveState()
    @State private var placeableItemStore = PlaceableItemStore()
    @State private var modelLoader = ModelLoader()
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.scenePhase) private var scenePhase
    
    // 사용자가 immersionStyle을 조절하기 위한 변수
    @State private var immersionStyle: ImmersionStyle = .mixed
    @State private var toyImmersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        WindowGroup(id: "HomeView") {
            HomeView()
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)

        // ToyDetailView
        WindowGroup(id: "toy") {
            ToyDetail(module: toyModule)
                .environment(model)
        }
        .defaultSize(width: 980, height: 451)

        ImmersiveSpace(id: "toy") {
            Toy()
                .environment(model)
        }
        .immersionStyle(selection: $toyImmersionStyle, in: .mixed)
        
        ImmersiveSpace(id: model.immersiveSpaceID) {
            Fence()
                .environment(model)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .full)
            
        ImmersiveSpace(id: UIIdentifier.immersiveSpace) {
                ObjectPlacementRealityView()
                    .environment(mixedImmersiveState)
                    .environment(modelLoader)
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase != .active {
                if mixedImmersiveState.mixedImmersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        mixedImmersiveState.didLeaveMixedImmersiveSpace()
                    }
                }
            }
        }
    }
}
