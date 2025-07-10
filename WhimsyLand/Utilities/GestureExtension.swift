//
//  GestureExtension.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/10/25.
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

// TapGesture에 GestureComponent를 적용하는 extension
extension Gesture where Value == EntityTargetValue<TapGesture.Value> {
    /// Tap 제스처가 끝났을 때 GestureComponent의 onEnded 호출
    @MainActor public func useGestureComponent() -> some Gesture {
        onEnded { value in
            // Entity에 GestureComponent가 있으면 onEnded 실행
            guard var gestureComponent = value.entity.gestureComponent else { return }
            gestureComponent.onEnded(value: value)
        }
    }
}

// DragGesture에 GestureComponent를 적용하는 extension
extension Gesture where Value == EntityTargetValue<DragGesture.Value> {
    /// Drag 제스처 변화 및 종료 시 GestureComponent의 메서드 호출
    @MainActor public func useGestureComponent() -> some Gesture {
        onChanged { value in
            // 드래그 중 변화가 있을 때 onChanged 실행
            guard var gestureComponent = value.entity.gestureComponent else { return }
            gestureComponent.onChanged(value: value)
        }
        .onEnded { value in
            // 드래그가 끝났을 때 onEnded 실행
            guard var gestureComponent = value.entity.gestureComponent else { return }
            gestureComponent.onEnded(value: value)
        }
    }
}

// MagnifyGesture(핀치 확대/축소)를 Entity에 적용하는 extension
extension Gesture where Value == EntityTargetValue<MagnifyGesture.Value> {
    /// Magnify 제스처 변화 및 종료 시 스케일 조절
    @MainActor
    public func useGestureComponent() -> some Gesture {
        onChanged { value in
            // ModelEntity인지 확인
            guard let entity = value.entity as? ModelEntity else { return }
            
            // 초기 스케일 저장 (외부 상태에서 관리 가능)
            let initialScale = entity.scale
            
            // 제스처의 배율값 가져오기
            let magnification = Float(value.magnification)
            let minScale: Float = 0.25
            let maxScale: Float = 3.0
            
            // 새로운 스케일 계산 및 clamp 처리
            var newScale = initialScale * magnification
            newScale = SIMD3<Float>(
                x: min(max(newScale.x, minScale), maxScale),
                y: min(max(newScale.y, minScale), maxScale),
                z: min(max(newScale.z, minScale), maxScale)
            )
            entity.scale = newScale
        }
        .onEnded { value in
            // 필요시 상태 리셋 (여기서는 별도 동작 없음)
        }
    }
}

// RotateGesture3D에 GestureComponent를 적용하는 extension
extension Gesture where Value == EntityTargetValue<RotateGesture3D.Value> {
    /// 회전 제스처 변화 및 종료 시 GestureComponent의 메서드 호출
    @MainActor func useGestureComponent() -> some Gesture {
        onChanged { value in
            // 회전 중 변화가 있을 때 onChanged 실행
            guard var gestureComponent = value.entity.gestureComponent else { return }
            gestureComponent.onChanged(value: value)
        }
        .onEnded { value in
            // 회전이 끝났을 때 onEnded 실행
            guard var gestureComponent = value.entity.gestureComponent else { return }
            gestureComponent.onEnded(value: value)
        }
    }
}
