//
//  WhimsyLandApp.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/8/25.
//

import SwiftUI

private enum UIIdentifier {
    static let immersiveSpace = "Object Placement"
}

@main
struct WhimsyLandApp: App {
    @State private var model = ViewModel()
    @State private var appState = AppState()
    @State private var modelLoader = ModelLoader()
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(model)
                .environment(appState)
                .environment(modelLoader)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1020, height: 540)
        
        
        WindowGroup {
            ContentView(
                appState: appState,
                immersiveSpaceIdentifier: UIIdentifier.immersiveSpace
            )
            .environment(appState)
        }
        .windowStyle(.volumetric)
        
        ImmersiveSpace(id: UIIdentifier.immersiveSpace) {
            ObjectPlacementRealityView()
                .environment(appState)
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase != .active {
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
            }
        }
    }
}
