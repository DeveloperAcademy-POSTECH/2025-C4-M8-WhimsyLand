//
//  ImmersiveView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/8/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        ZStack {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
            VStack {
                Spacer()
                Button("나가기") {
                    Task {
                        await dismissImmersiveSpace()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.bottom, 40)
            }
            .zIndex(1)
        }
    }
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}
