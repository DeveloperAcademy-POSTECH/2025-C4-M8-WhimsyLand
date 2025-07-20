//
//  Toy.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/20/25.
//

import SwiftUI
import RealityKit

// 모델 설정 상수
private let modelName = "Cone"
private let modelDepth: Double = 200
private let modelSize: CGFloat = 560
private let modelScale: CGFloat = 0.7
private let modelOrientation: SIMD3<Double> = [0, 0, 0]

struct Toy: View {
    @Environment(ViewModel.self) private var model
    @State private var conePosition: SIMD3<Float> = .zero

    var body: some View {
        VStack(spacing: 100) {
            // 3D 미리보기
            Model3D(named: modelName) { model in
                model.resizable()
                    .scaledToFit()
                    .rotation3DEffect(
                        Rotation3D(
                            eulerAngles: .init(angles: modelOrientation, order: .xyz)
                        )
                    )
                    .frame(width: modelSize, height: modelSize)
                    .scaleEffect(modelScale)
                    .frame(depth: modelDepth)
                    .offset(z: -modelDepth / 2)
            } placeholder: {
                ProgressView()
                    .offset(z: -modelDepth * 0.75)
            }
            .dragRotation(yawLimit: .degrees(360), pitchLimit: .degrees(360))
            .offset(z: modelDepth)
        }
    }
}

#Preview {
    Toy()
}
