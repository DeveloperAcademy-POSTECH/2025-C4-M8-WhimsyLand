//
//  ToyPreview.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/20/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

// 모델 설정 상수
private let targetSizeInMeters: Float = 0.26
private let modelScale: CGFloat = 0.7
private let modelOrientation: SIMD3<Double> = [0, 0, 0]

struct ToyPreview: View {
    
    var modelName: String = ""
    @State private var loadedEntity: Entity?
    
    var body: some View {
        Model3D(named: modelName) { model in
            model.resizable()
                .scaledToFit()
                .rotation3DEffect(
                    Rotation3D(
                        eulerAngles: .init(angles: modelOrientation, order: .xyz)
                    )
                )
                .scaleEffect(modelScale)
        } placeholder: {
            ProgressView()
        }
        .dragRotation(yawLimit: .degrees(360), pitchLimit: .degrees(360))
    }
    
}
