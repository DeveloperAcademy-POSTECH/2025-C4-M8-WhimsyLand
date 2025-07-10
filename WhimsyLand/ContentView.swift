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
// enlarge 만이 아니라 drag & drop, magnify, rotate 제스처를 위해 enlarge 부분 삭제 - Fine
//    @State private var enlarge = false

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
// scene에 대해 제스처 적용이 가능하도록 함 - Fine
                enableGesturesRecursively(for: scene)
                content.add(scene)
            }
// enlarge 부분 삭제 - Fine
//        } update: { content in
//            // Update the RealityKit content when SwiftUI state changes
//            if let scene = content.entities.first {
//                let uniformScale: Float = enlarge ? 1.4 : 1.0
//                scene.transform.scale = [uniformScale, uniformScale, uniformScale]
//            }
        }
//        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
//            enlarge.toggle()
//        })
        
        // 모든 엔티티에 대해 Tap, Drag, magnify, rotate 제스처 추가 - Fine
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
                // enlarge 부분 삭제 - Fine
//                VStack (spacing: 12) {
//                    Button {
//                        enlarge.toggle()
//                    } label: {
//                        Text(enlarge ? "Reduce RealityView Content" : "Enlarge RealityView Content")
//                    }
//                    .animation(.none, value: 0)
//                    .fontWeight(.semibold)

                    ToggleImmersiveSpaceButton()
                }
            }
        }
    }
//}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
