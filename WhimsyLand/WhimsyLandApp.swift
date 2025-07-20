//
//  WhimsyLandApp.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/8/25.
//

import SwiftUI

@main
struct WhimsyLandApp: App {
    @State private var model = ViewModel()
    @State private var extractedObject: ObjectModule? = nil

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

    var body: some Scene {
        WindowGroup(id: "HomeView") {
            HomeView()
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        
        WindowGroup(id: "ItemDetail") {
            ItemDetail()
        }
        .windowStyle(.plain)
        .defaultSize(width: 980, height: 480)
        .defaultWindowPlacement { content, context in
                  guard let contentWindow = context.windows.first(where: { $0.id == "HomeView" }) else { return WindowPlacement(nil)
                  }
                  return WindowPlacement(.trailing(contentWindow))
              }

        
        ImmersiveSpace(id: model.fullImmersiveID) {
            Fence()
                .environment(model)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
            
        ImmersiveSpace(id: model.mixedImmersiveID) {
            ObjectPlacementRealityView()
                .environment(mixedImmersiveState)
                .environment(modelLoader)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        // 앱이 강제로 종료되거나 사라졌을 때 상태를 관리하는 부분
        .onChange(of: scenePhase, initial: true) {
            if scenePhase != .active {
                if model.immersiveSpaceState == .open {
                    Task {
                        await dismissImmersiveSpace()
                        model.immersiveSpaceState = .closed
                        model.currentImmersiveMode = .none
                        mixedImmersiveState.didLeaveMixedImmersiveSpace()
                    }
                }
            }
        }
    }
}
