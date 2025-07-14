//
//  ContentView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/8/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    // RealityView 내 3D 콘텐츠의 확대 여부를 관리하는 상태 변수
    //    @State private var enlarge = false
    // RealityView에 추가된 엔티티를 추적할 수 있도록 상태 변수 추가
    @State private var sceneEntity: Entity? = nil
    let appState: AppState
    let immersiveSpaceIdentifier: String
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        RealityView { content in
            // RealityKit 콘텐츠 초기화(최초 1회 실행)
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                // scene에 대해 제스처 적용이 가능하도록 함
                enableGesturesRecursively(for: scene)
                content.add(scene) // RealityKit 씬을 RealityView에 추가
                sceneEntity = scene
            }
            //        } update: { content in
            //            // SwiftUI 상태(enlarge)가 변경될 때 RealityKit 콘텐츠를 업데이트
            //            if let scene = content.entities.first {
            //                let uniformScale: Float = enlarge ? 1.4 : 1.0 // 확대/축소 비율
            //                scene.transform.scale = [uniformScale, uniformScale, uniformScale] // 3D 씬 전체 스케일 적용
            //            }
        }
        //        // RealityView에 탭 제스처 추가: 탭 시 enlarge 상태 토글
        //        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
        //            enlarge.toggle()
        //        })
        
        // 모든 엔티티에 대해 Tap, Drag, magnify, rotate 제스처 추가
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .useGestureComponent()
        )
        
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .useGestureComponent()
        )
        .gesture(
            MagnifyGesture()
                .targetedToAnyEntity()
                .useGestureComponent()
        )
        .gesture(
            RotateGesture3D()
                .targetedToAnyEntity()
                .useGestureComponent()
        )
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                //                ToggleImmersiveSpaceButton()
                Button("Rotate +90° Y") {
                    // 씬의 첫 번째 자식(혹은 원하는 엔티티)에 회전 적용
                    if let entity = sceneEntity?.children.first {
                        let angle = Float.pi / 2 // 90도
                        let rotation = simd_quatf(angle: angle, axis: [0,1,0])
                        entity.transform.rotation *= rotation
                    }
                }
                Button("Rotate +90° X") {
                    if let entity = sceneEntity?.children.first {
                        let angle = Float.pi / 2 // 90도
                        let rotation = simd_quatf(angle: angle, axis: [1,0,0])
                        entity.transform.rotation *= rotation
                    }
                }
                Button("Rotate +90° Z") {
                    if let entity = sceneEntity?.children.first {
                        let angle = Float.pi / 2 // 90도
                        let rotation = simd_quatf(angle: angle, axis: [0,0,1])
                        entity.transform.rotation *= rotation
                    }
                }
                
                Button("Enter") {
                    Task {
                        switch await openImmersiveSpace(id: immersiveSpaceIdentifier) {
                        case .opened:
                            break
                        case .error:
                            print("An error occurred when trying to open the immersive space \(immersiveSpaceIdentifier)")
                        case .userCancelled:
                            print("The user declined opening immersive space \(immersiveSpaceIdentifier)")
                        @unknown default:
                            break
                        }
                    }
                }
                .disabled(!appState.canEnterImmersiveSpace)
                
                //                VStack (spacing: 12) {
                //                    // 확대/축소 토글 버튼
                //                    Button {
                //                        enlarge.toggle()
                //                    } label: {
                //                        Text(enlarge ? "Reduce RealityView Content" : "Enlarge RealityView Content")
                //                    }
                //                    .animation(.none, value: 0) // 버튼 자체에는 애니메이션 없음
                //                    .fontWeight(.semibold)
                
                //                    // 몰입형 공간 토글 스위치(visionOS 등에서 사용)
                //                    ToggleImmersiveSpaceButton()
            }
        }
        .onChange(of: scenePhase, initial: true) {
            print("HomeView scene phase: \(scenePhase)")
            if scenePhase == .active {
                Task {
                    // Check whether authorization has changed when the user brings the app to the foreground.
                    await appState.queryWorldSensingAuthorization()
                }
            } else {
                // Leave the immersive space if this view is no longer active;
                // the controls in this view pair up with the immersive space to drive the placement experience.
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
            }
        }
        .onChange(of: appState.providersStoppedWithError, { _, providersStoppedWithError in
            // Immediately close the immersive space if there was an error.
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
            // Request authorization before the user attempts to open the immersive space;
            // this gives the app the opportunity to respond gracefully if authorization isn’t granted.
            if appState.allRequiredProvidersAreSupported {
                await appState.requestWorldSensingAuthorization()
            }
        }
        .task {
            // Monitors changes in authorization. For example, the user may revoke authorization in Settings.
            await appState.monitorSessionEvents()
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView(
        appState: AppState(),
        immersiveSpaceIdentifier: "com.example.immersive-space"
    )
}
