//
//  Toy.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/20/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

// 모델 설정 상수
//private let modelName : String = ""  // TODO: 선택한 toy3D name 받아오기
private let targetSizeInMeters: Float = 0.26
//private let modelDepth: Double = 200
//private let modelSize: CGFloat = 560
//private let modelScale: CGFloat = 0.7
//private let modelOrientation: SIMD3<Double> = [0, 0, 0]

struct ToyPreview: View {
 
    var modelName: String = ""
    @State private var loadedEntity: Entity?
    
    var body: some View {
        // 3D 미리보기
        RealityView { content in
            if let entity = loadedEntity {
                content.add(entity)
            }
           
        } update: { content in
            content.entities.removeAll()
            if let entity = loadedEntity {
                           content.add(entity)
                       }
        
        } placeholder: {
            ProgressView()
        }
        .task(id: modelName) {
            await loadModel()
        }
        .gesture(
            RotateGesture3D()
                .targetedToAnyEntity()
                .useGestureComponent()
        )
        
        //            Model3D(named: modelName) { model in
        //                model.resizable()
        //                    .scaledToFit()
        //                    .rotation3DEffect(
        //                        Rotation3D(
        //                            eulerAngles: .init(angles: modelOrientation, order: .xyz)
        //                        )
        //                    )
        //                    .frame(width: modelSize, height: modelSize)
        //                    .scaleEffect(modelScale)
        //                    .frame(depth: modelDepth)
        //                    .offset(z: -modelDepth / 2)
        //            } placeholder: {
        //                ProgressView()
        //                    .offset(z: -modelDepth * 0.75)
        //            }
        //            .dragRotation(yawLimit: .degrees(360), pitchLimit: .degrees(360))
        //            .offset(z: modelDepth)
    }
    
    private func loadModel() async {
              if let entity = try? await Entity(named: modelName) {
                  
                  // 모델 원본 크기 측정
                  let originalBounds = entity.visualBounds(relativeTo: nil)
                  let originalSize = originalBounds.extents
                  
                  // 모델 크기 중 가장 큰 축을 기준으로 스케일 계산
                  let maxOriginalDimension = max(originalSize.x, originalSize.y, originalSize.z)
                  let scaleFactor = targetSizeInMeters / maxOriginalDimension
                  
                  entity.scale = [scaleFactor, scaleFactor, scaleFactor]
                  entity.position =  [0.21, -0.13, 0]
                  
                  enableGesturesRecursively(for: entity)
                  
                  await MainActor.run {
                      loadedEntity = entity
                  }
              }
      }
}

//#Preview {
//    Toy()
//}
