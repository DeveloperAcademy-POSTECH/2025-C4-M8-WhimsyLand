//
//  GestureComponent.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/10/25.
//

import RealityKit
import SwiftUI

/// 개체의 제스처 상태를 저장하는 클래스 (드래그, 회전, 스케일 등)
class EntityGestureState: Codable {
    /// 현재 제스처 타겟이 되는 Entity의 ID
    var targetEntity: UInt64?
    /// 드래그 시작 시점의 3D 위치
    var dragStartPosition: SIMD3<Float> = .zero
    /// 드래그 중 여부
    var isDragging: Bool = false
    /// 회전 시작 시점의 방향 정보
    var startOrientation: Rotation3D = .identity
    /// 회전 중 여부
    var isRotating = false
    /// 크기 조절 시작 시점의 스케일
    var initialScale: SIMD3<Float>? = nil
}

@MainActor
public struct GestureComponent: Component, Codable {

    /// 드래그 가능 여부
    var canDrag = true
    /// 탭 가능 여부
    var canTap = true
    /// 회전 가능 여부
    var canRotate = true

    /// 제스처 상태를 저장하는 싱글톤 객체
    static var shared = EntityGestureState()

    /// TapGesture가 끝났을 때 호출되는 함수
    mutating public func onEnded(value: EntityTargetValue<TapGesture.Value>) {
        guard canTap else { return } // 탭이 비활성화면 무시

        let state = GestureComponent.shared
        if state.targetEntity == nil {
            state.targetEntity = value.entity.id // 현재 엔티티를 타겟으로 지정

            handleTap(value: value) // 탭 처리 함수 호출
        }
        state.targetEntity = nil // 타겟 초기화
    }

    /// 실제 탭 동작을 처리하는 함수
    mutating private func handleTap(value: EntityTargetValue<TapGesture.Value>) {
        let entity = value.entity

        // 모델 컴포넌트가 존재하는지 확인
        guard var model = entity.components[ModelComponent.self] else { return }
        // 첫 번째 머티리얼이 SimpleMaterial이면, 머티리얼을 다시 세팅
        if let material = model.materials.first as? SimpleMaterial {
            model.materials = [material]
            entity.components.set([model, self])
        }
    }

    /// DragGesture가 변경될 때 호출되는 함수
    mutating public func onChanged(value: EntityTargetValue<DragGesture.Value>) {
        guard canDrag else { return } // 드래그 불가 시 무시

        let state = GestureComponent.shared
        if state.targetEntity == nil {
            state.targetEntity = value.entity.id // 드래그 타겟 지정
        }

        handleDrag(value: value) // 드래그 처리 함수 호출
    }

    /// 실제 드래그 동작을 처리하는 함수
    mutating private func handleDrag(value: EntityTargetValue<DragGesture.Value>) {
        let state = GestureComponent.shared

        if !state.isDragging {
            state.isDragging = true // 드래그 시작 플래그 설정
            state.dragStartPosition = value.entity.scenePosition // 시작 위치 저장
        }

        // 제스처의 3D 이동값을 로컬 → 씬 좌표로 변환
        let translation3D = value.convert(value.gestureValue.translation3D, from: .local, to: .scene)

        // 이동 오프셋 계산
        let offset = SIMD3<Float>(x: Float(translation3D.x), y: Float(translation3D.y), z: Float(translation3D.z))
        let newPosition = state.dragStartPosition + offset

        // 엔티티의 위치를 새로운 위치로 갱신
        value.entity.scenePosition = newPosition
    }

    /// DragGesture가 끝났을 때 호출되는 함수
    mutating public func onEnded(value: EntityTargetValue<DragGesture.Value>) {
        let state = GestureComponent.shared
        state.isDragging = false // 드래그 종료
        state.targetEntity = nil // 타겟 초기화
    }

    /// RotateGesture3D가 변경될 때 호출되는 함수
    mutating func onChanged(value: EntityTargetValue<RotateGesture3D.Value>) {
        let state = GestureComponent.shared
        guard canRotate, !state.isDragging else { return } // 회전 불가 또는 드래그 중이면 무시

        let entity = value.entity

        // 회전 시작 시 orientation 저장
        if !state.isRotating {
            state.isRotating = true
            state.startOrientation = .init(entity.orientation(relativeTo: nil))
        }

        let rotation = value.rotation // Rotation3D
        // 누적 회전값 계산: 시작 orientation에 현재 회전값을 곱함
        let newOrientation = state.startOrientation.rotated(by: rotation)
        entity.transform.rotation = simd_quatf(newOrientation)
    }

    /// RotateGesture3D가 끝났을 때 호출되는 함수
    mutating func onEnded(value: EntityTargetValue<RotateGesture3D.Value>) {
        GestureComponent.shared.isRotating = false // 회전 종료
    }

    /// MagnifyGesture(핀치 제스처) 변경 시 호출되는 함수
    mutating func onChanged(value: EntityTargetValue<MagnifyGesture.Value>) {
        // 크기 조절 시작 시 초기 스케일을 저장
        let state = GestureComponent.shared
        let entity = value.entity

        if state.initialScale == nil {
            state.initialScale = entity.scale
        }

        // 제스처의 배율값을 가져와서 초기 스케일에 곱함
        let magnification = Float(value.gestureValue.magnification)
        let minScale: Float = 0.25
        let maxScale: Float = 3.0

        // 초기 스케일이 nil일 경우 1.0으로 대체
        let baseScale = state.initialScale ?? SIMD3<Float>(repeating: 1.0)
        var newScale = baseScale * magnification

        // 각 축별로 최소/최대값 제한
        newScale = SIMD3<Float>(
            x: min(max(newScale.x, minScale), maxScale),
            y: min(max(newScale.y, minScale), maxScale),
            z: min(max(newScale.z, minScale), maxScale)
        )

        // 엔티티의 스케일 적용
        entity.scale = newScale
    }

    /// MagnifyGesture가 끝났을 때 호출되는 함수
    mutating func onEnded(value: EntityTargetValue<MagnifyGesture.Value>) {
        // 제스처 종료 시 초기 스케일 리셋
        GestureComponent.shared.initialScale = nil
    }
    
    func enableGesturesRecursively(for entity: Entity) {
        // ModelEntity에만 GestureComponent, InputTargetComponent, CollisionComponent 추가
        if let model = entity as? ModelEntity {
            if model.components[InputTargetComponent.self] == nil {
                model.components.set(InputTargetComponent())
            }
            if model.components[CollisionComponent.self] == nil {
                model.generateCollisionShapes(recursive: false)
            }
            if model.components[GestureComponent.self] == nil {
                model.components.set(GestureComponent())
            }
        }
        for child in entity.children {
            enableGesturesRecursively(for: child)
        }
    }
}

// 모든 하위 엔티티에 제스처 관련 컴포넌트 추가
@MainActor
func enableGesturesRecursively(for entity: Entity) {
    if let model = entity as? ModelEntity {
        if model.components[InputTargetComponent.self] == nil {
            model.components.set(InputTargetComponent())
        }
        if model.components[CollisionComponent.self] == nil {
            model.generateCollisionShapes(recursive: false)
        }
        if model.components[GestureComponent.self] == nil {
            model.components.set(GestureComponent())
        }
    }
    for child in entity.children {
        enableGesturesRecursively(for: child)
    }
}

