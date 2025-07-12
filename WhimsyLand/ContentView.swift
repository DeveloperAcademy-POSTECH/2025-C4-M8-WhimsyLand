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
    //임시 코드
    let appState: AppState
    let immersiveSpaceIdentifier: String
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    //임시코드
    
    @State private var enlarge = false

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
            }
        } update: { content in
            // Update the RealityKit content when SwiftUI state changes
            if let scene = content.entities.first {
                let uniformScale: Float = enlarge ? 1.4 : 1.0
                scene.transform.scale = [uniformScale, uniformScale, uniformScale]
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            enlarge.toggle()
        })
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack (spacing: 12) {
                    Button {
                        enlarge.toggle()
                    } label: {
                        Text(enlarge ? "Reduce RealityView Content" : "Enlarge RealityView Content")
                    }
                    .animation(.none, value: 0)
                    .fontWeight(.semibold)

                    ToggleImmersiveSpaceButton()
                    
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
                }
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

//#Preview(windowStyle: .volumetric) {
//    ContentView()
//        .environment(AppModel())
//}
