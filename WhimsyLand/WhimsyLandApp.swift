//
//  WhimsyLandApp.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/8/25.
//

import SwiftUI

@main
struct WhimsyLandApp: App {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
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
        WindowGroup(id: model.HomeViewID) {
            HomeView()
                .environment(placeableItemStore)
                .environment(model)
                .environment(toyModel)
                .task {
                    await modelLoader.loadObjects()
                    placeableItemStore.setPlaceableObjects(modelLoader.placeableObjects)
                }
                .task {
                    await model.mixedImmersiveState.monitorSessionEvents()
                }
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        
        WindowGroup(id: model.ToyDetailViewID){
            ToyDetail()
                .environment(model)
                .environment(toyModel)
                .environment(placeableItemStore)
        }
        .windowStyle(.plain)
        .defaultWindowPlacement { content, context in
            guard let contentWindow = context.windows.first(where: { $0.id == model.HomeViewID }) else { return WindowPlacement(nil)
            }
            return WindowPlacement(.trailing(contentWindow))
        }
        
        ImmersiveSpace(id: model.ImmersiveId) {
            if model.currentImmersiveMode == .full {
                FullImmersiveView()
                    .environment(model)
            } else {
                // .mixed 또는 다른 경우 모두 ObjectPlacementSwitcherView 표시
                ObjectPlacementSwitcherView(
                    mixedImmersiveState: model.mixedImmersiveState,
                    placeableItemStore: placeableItemStore
                )
                .environment(model)
            }
        }
        .immersionStyle(selection: $model.immersionStyle, in: .mixed, .full)
        
        // 앱의 상태에 따라 관리하는 부분
        .onChange(of: scenePhase, initial: true) {
            // 앱이 활성화 된 경우 처리
            if scenePhase == .active {
                Task {
                    await model.mixedImmersiveState.queryWorldSensingAuthorization()
                    if model.mixedImmersiveState.canEnterMixedImmersiveSpace {
                        await model.switchToImmersiveMode(.mixed)
                        if model.immersiveSpaceState == .closed {
                            let result = await openImmersiveSpace(id: model.ImmersiveId)
                            if case .opened = result {
                                model.immersiveSpaceState = .open
                            }
                        }
                    } else {
                        print("⚠️ Mixed Immersive 공간 진입 보류: 권한 미획득 or 미지원")
                    }
                }
            } else if scenePhase != .active {
                model.handleAppDidDeactivate(dismiss: dismissImmersiveSpace.callAsFunction)
            }
        }
    }
}
