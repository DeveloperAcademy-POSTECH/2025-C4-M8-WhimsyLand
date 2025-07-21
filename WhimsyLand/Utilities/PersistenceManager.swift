//
//  PersistenceManager.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/9/25.
//
/*
 월드 앵커로 배치된 오브젝트에 매핑하는 클래스
 */

import Foundation
import ARKit
import RealityKit

class PersistenceManager {
    private var worldTracking: WorldTrackingProvider
    
    // 월드 앵커된 UUID 매칭
    private var anchoredObjects: [UUID: PlacedObject] = [:]
    
    // 월드 앵커할 UUID 매칭
    private var objectsBeingAnchored: [UUID: PlacedObject] = [:]
    
    // 평면에 붙이지않고 움직이고 있는 객체들
    private var movingObjects: [PlacedObject] = []
    
    private let objectAtRestThreshold: Float = 0.001 // 1 cm
    
    // ARKit로부터 받아 업데이트 된 앵커를 기반 현재 모든 월드 앵커 dictionary
    private var worldAnchors: [UUID: WorldAnchor] = [:]
    
    // 배치된 객체 월드앵커를 JSON 파일로 저장
    static let objectsDatabaseFileName = "persistentObjects.json"
    
    // 월드 앵커로 유지한 객체를 로드할 3D 모델 dictionary 파일
    private var persistedObjectFileNamePerAnchor: [UUID: String] = [:]
    
    var placeableObjectsByFileName: [String: PlaceableObject] = [:]
    
    private var rootEntity: Entity
    
    init(worldTracking: WorldTrackingProvider, rootEntity: Entity) {
        self.worldTracking = worldTracking
        self.rootEntity = rootEntity
    }
    
    /// 배치된 객체의 월드앵커가 매핑된  문서 디렉토리에 JSON파일 Deserialize
    func loadPersistedObjects() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = documentsDirectory.first?.appendingPathComponent(PersistenceManager.objectsDatabaseFileName)
        
        guard let filePath, FileManager.default.fileExists(atPath: filePath.path(percentEncoded: true)) else {
            print("Couldn’t find file: '\(PersistenceManager.objectsDatabaseFileName)' - skipping deserialization of persistent objects.")
            return
        }
        
        do {
            let data = try Data(contentsOf: filePath)
            persistedObjectFileNamePerAnchor = try JSONDecoder().decode([UUID: String].self, from: data)
        } catch {
            print("Failed to restore the mapping from world anchors to persisted objects.")
        }
    }
    
    /// 배치된 객체의 월드앵커가 매핑된  문서 디렉토리에 JSON파일 Serialize
    func saveWorldAnchorsObjectsMapToDisk() {
        var worldAnchorsToFileNames: [UUID: String] = [:]
        for (anchorID, object) in anchoredObjects {
            worldAnchorsToFileNames[anchorID] = object.fileName
        }
        
        let encoder = JSONEncoder()
        do {
            let jsonString = try encoder.encode(worldAnchorsToFileNames)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsDirectory.appendingPathComponent(PersistenceManager.objectsDatabaseFileName)
            
            do {
                try jsonString.write(to: filePath)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    @MainActor
    func attachPersistedObjectToAnchor(_ modelFileName: String, anchor: WorldAnchor) {
        guard let placeableObject = placeableObjectsByFileName[modelFileName] else {
            print("No object available for '\(modelFileName)' - it will be ignored.")
            return
        }
        
        let object = placeableObject.materialize()
        object.position = anchor.originFromAnchorTransform.translation
        object.orientation = anchor.originFromAnchorTransform.rotation
        object.isEnabled = anchor.isTracked
        rootEntity.addChild(object)
        
        anchoredObjects[anchor.id] = object
    }
    
    @MainActor
    func process(_ anchorUpdate: AnchorUpdate<WorldAnchor>) {
        let anchor = anchorUpdate.anchor
        
        if anchorUpdate.event != .removed {
            worldAnchors[anchor.id] = anchor
        } else {
            worldAnchors.removeValue(forKey: anchor.id)
        }
        
        switch anchorUpdate.event {
        case .added:
            // world tracking provider 시작시 이전 월드앵키거 있는지 확인
            if let persistedObjectFileName = persistedObjectFileNamePerAnchor[anchor.id] {
                attachPersistedObjectToAnchor(persistedObjectFileName, anchor: anchor)
            } else if let objectBeingAnchored = objectsBeingAnchored[anchor.id] {
                objectsBeingAnchored.removeValue(forKey: anchor.id)
                anchoredObjects[anchor.id] = objectBeingAnchored
                
                // 지금 앵커 추가 성공
                rootEntity.addChild(objectBeingAnchored)
            } else {
                if anchoredObjects[anchor.id] == nil {
                    Task {
                        // 바로 월드앵커 지우기
                        print("No object is attached to anchor \(anchor.id) - it can be deleted.")
                        await removeAnchorWithID(anchor.id)
                    }
                }
            }
            fallthrough
        case .updated:
            // 실좌표와 동기화해서 배치된 객체 월드앵커 위치 유지 앵커가 추적중이 아니면 객체 숨김
            let object = anchoredObjects[anchor.id]
            object?.position = anchor.originFromAnchorTransform.translation
            object?.orientation = anchor.originFromAnchorTransform.rotation
            object?.isEnabled = anchor.isTracked
        case .removed:
            // 실좌표에서 월드 앵커를 지웠으면 배치된 겍체 지움
            let object = anchoredObjects[anchor.id]
            object?.removeFromParent()
            anchoredObjects.removeValue(forKey: anchor.id)
        }
    }
    
    @MainActor
    func removeAllPlacedObjects() async {
        // 월드 앵커가 모두 완벽히 지워진 후에 배치된 객체가 지워짐
        await deleteWorldAnchorsForAnchoredObjects()
    }
    
    private func deleteWorldAnchorsForAnchoredObjects() async {
        for anchorID in anchoredObjects.keys {
            await removeAnchorWithID(anchorID)
        }
    }
    
    func removeAnchorWithID(_ uuid: UUID) async {
        do {
            try await worldTracking.removeAnchor(forID: uuid)
        } catch {
            print("Failed to delete world anchor \(uuid) with error \(error).")
        }
    }
    
    @MainActor
    func attachObjectToWorldAnchor(_ object: PlacedObject) async {
        // 먼저 새로운 월드 앵커 만들고 world tracking provider를 추가
        let anchor = WorldAnchor(originFromAnchorTransform: object.transformMatrix(relativeTo: nil))
        movingObjects.removeAll(where: { $0 === object })
        objectsBeingAnchored[anchor.id] = object
        do {
            try await worldTracking.addAnchor(anchor)
        } catch {
            // 월드 앵커 추가 실패, 갯수 제한 도달시 기존 월드 앵커는 유지 되지만 attach 안된 객체는 전부 삭제됨
            
            if let worldTrackingError = error as? WorldTrackingProvider.Error, worldTrackingError.code == .worldAnchorLimitReached {
                print(
"""
Unable to place object "\(object.name)". You’ve placed the maximum number of objects.
Remove old objects before placing new ones.
"""
                )
            } else {
                print("Failed to add world anchor \(anchor.id) with error: \(error).")
            }
            
            objectsBeingAnchored.removeValue(forKey: anchor.id)
            object.removeFromParent()
            return
        }
    }
    
    @MainActor
    private func detachObjectFromWorldAnchor(_ object: PlacedObject) {
        guard let anchorID = anchoredObjects.first(where: { $0.value === object })?.key else {
            return
        }
        
        // 움직이고 있기에 앵커된 객체 삭제
        anchoredObjects.removeValue(forKey: anchorID)
        Task {
            // 월드앵커 불필요해서 삭제
            await removeAnchorWithID(anchorID)
        }
    }
    
    @MainActor
    func placedObject(for entity: Entity) -> PlacedObject? {
        return anchoredObjects.first(where: { $0.value === entity })?.value
    }
    
    @MainActor
    func object(for entity: Entity) -> PlacedObject? {
        if let placedObject = placedObject(for: entity) {
            return placedObject
        }
        if let movingObject = movingObjects.first(where: { $0 === entity }) {
            return movingObject
        }
        if let anchoringObject = objectsBeingAnchored.first(where: { $0.value === entity })?.value {
            return anchoringObject
        }
        return nil
    }
    
    @MainActor
    func removeObject(_ object: PlacedObject) async {
        guard let anchorID = anchoredObjects.first(where: { $0.value === object })?.key else {
            return
        }
        await removeAnchorWithID(anchorID)
    }
    
    @MainActor
    func checkIfAnchoredObjectsNeedToBeDetached() async {
        let anchoredObjectsBeforeCheck = anchoredObjects
        
        // 월드 앵커로 부터 detach가 필요하거나 더이상 rest 상태가 아닌지 확인
        for (anchorID, object) in anchoredObjectsBeforeCheck {
            guard let anchor = worldAnchors[anchorID] else {
                object.positionAtLastReanchoringCheck = object.position(relativeTo: nil)
                movingObjects.append(object)
                anchoredObjects.removeValue(forKey: anchorID)
                continue
            }
            
            let distanceToAnchor = object.position(relativeTo: nil) - anchor.originFromAnchorTransform.translation
            
            if length(distanceToAnchor) >= objectAtRestThreshold {
                object.atRest = false
                
                object.positionAtLastReanchoringCheck = object.position(relativeTo: nil)
                movingObjects.append(object)
                detachObjectFromWorldAnchor(object)
            }
        }
    }
    
    @MainActor
    func checkIfMovingObjectsCanBeAnchored() async {
        let movingObjectsBeforeCheck = movingObjects
        
        // 지금 앵커 없는 객체인지 앞으로 attach할 새로운 월드앵커인지 확인
        for object in movingObjectsBeforeCheck {
            guard !object.isBeingDragged else { continue }
            guard let lastPosition = object.positionAtLastReanchoringCheck else {
                object.positionAtLastReanchoringCheck = object.position(relativeTo: nil)
                continue
            }
            
            let currentPosition = object.position(relativeTo: nil)
            let movementSinceLastCheck = currentPosition - lastPosition
            object.positionAtLastReanchoringCheck = currentPosition
            
            if length(movementSinceLastCheck) < objectAtRestThreshold {
                object.atRest = true
                await attachObjectToWorldAnchor(object)
            }
        }
    }
}
