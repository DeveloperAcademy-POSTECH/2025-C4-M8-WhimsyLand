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
    }
}

//#Preview(windowStyle: .volumetric) {
//    ContentView()
//        .environment(AppModel())
//}
