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
    @State private var appState = AppState()
    @State private var appModel = AppModel()
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(
                appState: appState,
                immersiveSpaceIdentifier: UIIdentifier.immersiveSpace
            )
                .environment(appModel)
        }
        .windowStyle(.volumetric)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
        
        ImmersiveSpace(id: UIIdentifier.immersiveSpace) {
            ObjectPlacementRealityView(appState: appState)
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
