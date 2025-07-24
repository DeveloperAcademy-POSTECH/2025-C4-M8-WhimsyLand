//
//  WhimsyLandApp.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/8/25.
//

import SwiftUI

@main
struct WhimsyLandApp: App {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var model = ViewModel()
    @State private var toyModel = ToyModel()
    
    // item에 따라 다른 immersion 스타일
    @State private var houseImmersionStyle: ImmersionStyle = .full
    @State private var placeableItemStore = PlaceableItemStore()
    @State private var modelLoader = ModelLoader()
    
    // 사용자가 immersionStyle을 조절하기 위한 변수
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        WindowGroup(id: "HomeView") {
            HomeView()
                .environment(placeableItemStore)
                .environment(model)
                .environment(toyModel)
                .task {
                    await modelLoader.loadObjects()
                    placeableItemStore.setPlaceableObjects(modelLoader.placeableObjects)
                }
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        
        WindowGroup(id: "Toy", for: ToyItem.self, content: { $value in
            ToyDetail(item: $value)
                .environment(model)
                .environment(toyModel)
                .environment(placeableItemStore)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1120, height: 902)
        .defaultWindowPlacement { content, context in
                 guard let contentWindow = context.windows.first(where: { $0.id == "HomeView" }) else { return WindowPlacement(nil)
                 }
                 return WindowPlacement(.trailing(contentWindow))
             }
        
        ImmersiveSpace(id: model.mixedImmersiveID) {
            ObjectPlacementRealityView(mixedImmersiveState: model.mixedImmersiveState)
                .environment(model)
                .environment(modelLoader)
                .environment(placeableItemStore)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        // 앱이 강제로 종료되거나 사라졌을 때 상태를 관리하는 부분
        .onChange(of: scenePhase, initial: true) {
            if scenePhase != .active {
                Task {
                    model.handleAppDidDeactivate(dismiss: dismissImmersiveSpace.callAsFunction)
                }
            }
        }
    }
}
