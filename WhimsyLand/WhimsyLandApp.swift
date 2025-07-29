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
    @State private var placeableToyStore = PlaceableToyStore()
    @State private var modelLoader = ModelLoader()
    
    // Model Load 실행 여부를 저장하기 위한 변수
    @State private var isModelsLoaded = false
    
    // 사용자가 immersionStyle을 조절하기 위한 변수
    @State private var immersionStyle: ImmersionStyle = .mixed
    
    var body: some Scene {
        WindowGroup(id: model.HomeViewID) {
            HomeView()
                .environment(placeableToyStore)
                .environment(model)
                .environment(toyModel)
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        
        WindowGroup(id: model.ListViewID) {
            ListView()
                .frame(minWidth: 1020, maxWidth: 1020,
                       minHeight: 678, maxHeight: .infinity)
                .environment(placeableToyStore)
                .environment(model)
                .environment(toyModel)
        }
        .defaultSize(width:1020,  height: 678)
        .windowResizability(.contentSize)
        
        WindowGroup(id: model.ToyDetailViewID){
            ToyDetailView()
                .environment(model)
                .environment(toyModel)
                .environment(placeableToyStore)
        }
        //        .defaultSize(width: 980, height: 510)
        .windowStyle(.plain)
        .defaultWindowPlacement { content, context in
            guard let contentWindow = context.windows.first(where: { $0.id == model.ListViewID }) else { return WindowPlacement(nil)
            }
            return WindowPlacement(.trailing(contentWindow))
        }
        
        ImmersiveSpace(id: model.ImmersiveId) {
            if model.currentImmersiveMode == .full {
                FullImmersiveSwitcherView()
                    .environment(model)
                    .environment(toyModel)
            } else {
                // .mixed 또는 다른 경우 모두 ToyPlacementSwitcherView 표시
                ToyPlacementSwitcherView(
                    mixedImmersiveState: model.mixedImmersiveState,
                    placeableToyStore: placeableToyStore
                )
                .environment(model)
                .environment(toyModel)
            }
        }
        .immersionStyle(selection: $model.immersionStyle, in: .mixed, .full)
        .onChange(of: scenePhase) {
            if scenePhase != .active {
                Task {
                    print("ScenePhase is not active")
                    model.handleAppDidDeactivate(dismiss: dismissImmersiveSpace.callAsFunction)
                }
            }
        }
        // 앱의 상태에 따라 관리하는 부분
        .onChange(of: scenePhase, initial: true) {
            // 앱이 활성화 된 경우 처리
            if scenePhase == .active {
                Task {
                    // 모델 파일 불러와서 placeableToyStore에 저장하기
                    if !isModelsLoaded {
                        await modelLoader.loadToys()
                        placeableToyStore.setPlaceableToys(modelLoader.placeableToys)
                        isModelsLoaded = true
                    }
                    
                    // 이 기기에서 world tracking과 plane detection을 지원한다면
                    // 권한을 요청한다 (사용자에게 허용 요청)
                    if model.mixedImmersiveState.allRequiredProvidersAreSupported {
                        await model.mixedImmersiveState.requestWorldSensingAuthorization()
                    }
                    
                    //현재 권한 상태 조회한다 (사용자가 허용했는지, ar은 문제가 없는지)
                    await model.mixedImmersiveState.queryWorldSensingAuthorization()
                    
                    // 현재 권한 상태, 기기의 worldTracking, Plane Detection 지원 여부를 판단하여
                    // 최종적으로 MixedImmersive를 열지 결정한다
                    guard model.mixedImmersiveState.canEnterMixedImmersiveSpace else {
                        print("⚠️ Mixed Immersive 공간 진입 보류: 권한 미획득 or 미지원")
                        return
                    }
                    
                    // mixedImmersive를 여는것이 허용되었으므로 상태를 변경한다
                    await model.switchToImmersiveMode(.mixed)
                    
                    // immersiveSpace 열기
                    guard model.immersiveSpaceState == .closed else { return }
                    let result = await openImmersiveSpace(id: model.ImmersiveId)
                    if case .opened = result {
                        model.immersiveSpaceState = .open
                    }
                    
                    await model.mixedImmersiveState.monitorSessionEvents()
                }
            }
        }
    }
}
