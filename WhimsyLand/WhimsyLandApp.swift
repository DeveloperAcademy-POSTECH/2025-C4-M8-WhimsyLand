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
    @State private var extractedObject: ObjectModule? = nil

    // item에 따라 다른 immersion 스타일
    @State private var houseImmersionStyle: ImmersionStyle = .full
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

        WindowGroup(id: "ExtractedObject") {
            if let object = extractedObject {
                Reality3DView(objectName: object.rawValue)
            }
        }
        .defaultSize(width: 0.4, height: 0.4, depth: 0.4, in: .meters)
        .windowStyle(.volumetric)
        
        // scene 일부분을 immersive space로 정의
        ImmersiveSpace(id: Module.threeLittlePigs.name ) {
            House()
                .onAppear {
                    model.isShowBrickHouse = true
                }
                .onDisappear {
                    model.isShowBrickHouse = false
                }
        }.immersionStyle(selection: $houseImmersionStyle, in: .full)

        
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
