//
//  Home.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/9/25.
//

import SwiftUI
import RealityKit

struct House: View {
    var body: some View {
        RealityView { content in
            let root = Entity()
            
            do {
                try await createEnvironment(on: root)
            } catch {
                print("Failed to load environment: \(error.localizedDescription)")
            }
            content.add(root)
            
            // root 위치를 재배치
            root.position.z -= 1.0
        }
    }
}

// immersive환경 생성 및 image-based lighting적용
func createEnvironment(on root: Entity) async throws {
    // immersive 환경에 대한 루트 Entity
    let assetRoot = try await Entity(named: "CornellBox.usda")

    // image-based lighting 파일을  URL로 변환 그리고  로드
    guard let iblURL = Bundle.main.url(forResource: "TeapotIBL", withExtension: "exr") else {
        fatalError("Failed to load the Image-Based Lighting file.")
    }
    let iblEnv = try await EnvironmentResource(fromImage: iblURL)

    // image-based lighting 수행
    let iblEntity = await Entity()

    // The image-based lighting는 background와 lighting 정보가 포함되어있음
    var iblComp = ImageBasedLightComponent(source: .single(iblEnv))
    iblComp.inheritsRotation = true

    // entity에 image-based lighting 컴포넌트 추가
    await iblEntity.components.set(iblComp)

    // immersive 환경에 대한 image-based lightin 설정
    await assetRoot.components.set(ImageBasedLightReceiverComponent(imageBasedLight: iblEntity))

    //  immersive 환경에 image-based lighting entity를 추가
    await assetRoot.addChild(iblEntity)

    // immersive 환경을 `root`로 추가
    await root.addChild(assetRoot)
}

extension EnvironmentResource {
    // image URL 로부터 환경 리소스를 비동기로 생성
    convenience init(fromImage url: URL) async throws {
        // URL로 부터 이미지 리소를 읽기
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            fatalError("Failed to load image from \(url)")
        }

        // 이미지 리소스로 이미지 객체 생성
        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            fatalError("Failed to load image from \(url)")
        }

        // 이미지로 환경 리소스 생성
        try await self.init(equirectangular: image)
    }
}

//#Preview {
//    House()
//}
