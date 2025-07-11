//
//  EntityExtension.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/11/25.
//

import Foundation
import RealityKit
import SwiftUI

// Entity에 제스처 관련 편의 프로퍼티 추가
extension Entity {
    /// 씬 기준의 위치를 가져오거나 설정하는 프로퍼티
    var scenePosition: SIMD3<Float> {
        get { position(relativeTo: nil) }
        set { setPosition(newValue, relativeTo: nil) }
    }
    
    /// GestureComponent를 가져오거나 설정하는 프로퍼티
    var gestureComponent: GestureComponent? {
        get { components[GestureComponent.self] }
        set { components[GestureComponent.self] = newValue }
    }
}
