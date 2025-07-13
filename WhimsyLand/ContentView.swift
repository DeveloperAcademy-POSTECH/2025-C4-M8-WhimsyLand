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

    @State private var enlarge = false
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @Environment(\.openWindow) private var openWindow
    @Environment(AppModel.self) private var appModel

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
                
                scene.isEnabled = appModel.showSphere
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            enlarge.toggle()
        })
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack (spacing: 12) {
                    Button("First View") {
                        openWindow(id: "first")
                    }
                    
                    Button("Second View") {
                        openWindow(id: "second")
                    }
                    Button {
                        enlarge.toggle()
                    } label: {
                        Text(enlarge ? "Reduce RealityView Content" : "Enlarge RealityView Content")
                    }
                    .animation(.none, value: 0)
                    .fontWeight(.semibold)

                    ToggleImmersiveSpaceButton()
                    if appModel.isFullImmersiveSpaceShown {
                        Button("Close Immersive Space") {
                            Task {
                                await dismissImmersiveSpace()
                            }
                        }
                    } else {
                        Button("New Immersive Space") {
                            Task {
                                await openImmersiveSpace(id: "newImmersive")
                }
            }
        }
    }
}
        }
        .onDisappear {
            Task {
                await dismissImmersiveSpace()
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
