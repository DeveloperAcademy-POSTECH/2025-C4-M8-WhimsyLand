//
//  PlaceableToy.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/9/25.
//

import Foundation
import RealityKit

// MARK: ModelDescriptor
struct ModelDescriptor: Identifiable, Hashable {
    let fileName: String
    let displayName: String

    var id: String { fileName }

    init(fileName: String, displayName: String? = nil) {
        self.fileName = fileName
        self.displayName = displayName ?? fileName
    }
}

// MARK: PreviewMaterials
//private enum PreviewMaterials {
//    static let active = UnlitMaterial(color: .gray.withAlphaComponent(0.5))
//    static let inactive = UnlitMaterial(color: .gray.withAlphaComponent(0.1))
//}

// MARK: - PlaceableToy
@MainActor
class PlaceableToy {
    let descriptor: ModelDescriptor
    var previewEntity: Entity
    private var renderContent: ModelEntity
    
    static let previewCollisionGroup = CollisionGroup(rawValue: 1 << 15)
    
    init(descriptor: ModelDescriptor, renderContent: ModelEntity, previewEntity: Entity) {
        self.descriptor = descriptor
        self.previewEntity = previewEntity
        //self.previewEntity.applyMaterial(PreviewMaterials.active)
        self.renderContent = renderContent
    }

    var isPreviewActive: Bool = true {
        didSet {
            if oldValue != isPreviewActive {
                // previewEntity.applyMaterial(isPreviewActive ? PreviewMaterials.active : PreviewMaterials.inactive)
                // 드래그 제스처가 이미 배치된 객체와 간섭을 방지하기 위해 input target만 동작함
                previewEntity.components[InputTargetComponent.self]?.allowedInputTypes = isPreviewActive ? .indirect : []
            }
        }
    }

    func materialize() -> PlacedToy {
        let shapes = previewEntity.components[CollisionComponent.self]!.shapes
        return PlacedToy(descriptor: descriptor, renderContentToClone: renderContent, shapes: shapes)
    }

    func matchesCollisionEvent(event: CollisionEvents.Began) -> Bool {
        event.entityA == previewEntity || event.entityB == previewEntity
    }

    func matchesCollisionEvent(event: CollisionEvents.Ended) -> Bool {
        event.entityA == previewEntity || event.entityB == previewEntity
    }

    func attachPreviewEntity(to entity: Entity) {
        entity.addChild(previewEntity)
    }
}


// MARK: - PlacedToy
class PlacedToy: Entity {
    let fileName: String
    
    // 객체를 표시하기 위한 3D model
    let renderContent: ModelEntity

    static let collisionGroup = CollisionGroup(rawValue: 1 << 29)
    
    // 객체에 붙은 UI 원점
    // UI는 중력에 따라 정렬되고 사용자 쪽을 향함
    let uiOrigin = Entity()
    
    var affectedByPhysics = false {
        didSet {
            guard affectedByPhysics != oldValue else { return }
            if affectedByPhysics {
                components[PhysicsBodyComponent.self]!.mode = .dynamic
            } else {
                components[PhysicsBodyComponent.self]!.mode = .static
            }
        }
    }
    
    var isBeingDragged = false {
        didSet {
            affectedByPhysics = !isBeingDragged
        }
    }
    
    var positionAtLastReanchoringCheck: SIMD3<Float>?
    
    var atRest = false

    init(descriptor: ModelDescriptor, renderContentToClone: ModelEntity, shapes: [ShapeResource]) {
        fileName = descriptor.fileName
        renderContent = renderContentToClone.clone(recursive: true)
        super.init()
        name = renderContent.name
        
        // Apply the rendered content’s scale to this parent entity to ensure 렌더링 된 콘텐츠의 스케일을 상위 엔티티에 적용
        // collision 모양과, physics 형체 스케일이 올바른지 확인
        scale = renderContent.scale
        renderContent.scale = .one
        
        // 객체에 중력 반응 만들기
        let physicsMaterial = PhysicsMaterialResource.generate(restitution: 0.0)
        let physicsBodyComponent = PhysicsBodyComponent(shapes: shapes, mass: 1.0, material: physicsMaterial, mode: .static)
        components.set(physicsBodyComponent)
        components.set(CollisionComponent(shapes: shapes, isStatic: false,
                                          filter: CollisionFilter(group: PlacedToy.collisionGroup, mask: .all)))
        addChild(renderContent)
        addChild(uiOrigin)
        uiOrigin.position.y = extents.y / 2 // 객체 중앙 UI 원점 위치
        
        // 배치된 객체 조작 direct, indirect 허용
        components.set(InputTargetComponent(allowedInputTypes: [.direct, .indirect]))
        
        // 배치된 객체에 grounding shadow 추가
        renderContent.components.set(GroundingShadowComponent(castsShadow: true))
    }
    
    required init() {
        fatalError("`init` is unimplemented.")
    }
}

// MARK: - Entity 확장
extension Entity {
    func applyMaterial(_ material: Material) {
        if let modelEntity = self as? ModelEntity {
            modelEntity.model?.materials = [material]
        }
        for child in children {
            child.applyMaterial(material)
        }
    }

    var extents: SIMD3<Float> { visualBounds(relativeTo: self).extents }

    func look(at target: SIMD3<Float>) {
        look(at: target,
             from: position(relativeTo: nil),
             relativeTo: nil,
             forward: .positiveZ)
    }
}

