//
//  PersistenceManager.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/9/25.
//
/*
 월드 앵커로 배치된 Toy에 매핑하는 클래스
 */

import Foundation
import ARKit
import RealityKit

class PersistenceManager {
    private var worldTracking: WorldTrackingProvider
    
    // 월드 앵커된 UUID 매칭
    private var anchoredToys: [UUID: PlacedToy] = [:]
    
    // 월드 앵커할 UUID 매칭
    private var toysBeingAnchored: [UUID: PlacedToy] = [:]
    
    // 평면에 붙이지않고 움직이고 있는 Toy들
    private var movingToys: [PlacedToy] = []
    
    private let toyAtRestThreshold: Float = 0.001 // 1 cm
    
    // ARKit로부터 받아 업데이트 된 앵커를 기반 현재 모든 월드 앵커 dictionary
    private var worldAnchors: [UUID: WorldAnchor] = [:]
    
    // 배치된 객체 월드앵커를 JSON 파일로 저장
    static let toysDatabaseFileName = "persistentToys.json"
    
    // 월드 앵커로 유지한 객체를 로드할 3D 모델 dictionary 파일
    private var persistedToyFileNamePerAnchor: [UUID: String] = [:]
    
    var placeableToysByFileName: [String: PlaceableToy] = [:]
    
    private var rootEntity: Entity
    
    init(worldTracking: WorldTrackingProvider, rootEntity: Entity) {
        self.worldTracking = worldTracking
        self.rootEntity = rootEntity
    }
    
    /// 배치된 객체의 월드앵커가 매핑된  문서 디렉토리에 JSON파일 Deserialize
    func loadPersistedToys() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = documentsDirectory.first?.appendingPathComponent(PersistenceManager.toysDatabaseFileName)
        
        guard let filePath, FileManager.default.fileExists(atPath: filePath.path(percentEncoded: true)) else {
            print("Couldn’t find file: '\(PersistenceManager.toysDatabaseFileName)' - skipping deserialization of persistent toys.")
            return
        }
        
        do {
            let data = try Data(contentsOf: filePath)
            persistedToyFileNamePerAnchor = try JSONDecoder().decode([UUID: String].self, from: data)
        } catch {
            print("Failed to restore the mapping from world anchors to persisted toys.")
        }
    }
    
    /// 배치된 Toy의 월드앵커가 매핑된  문서 디렉토리에 JSON파일 Serialize
    func saveWorldAnchorsToysMapToDisk() {
        var worldAnchorsToFileNames: [UUID: String] = [:]
        for (anchorID, toy) in anchoredToys {
            worldAnchorsToFileNames[anchorID] = toy.fileName
        }
        
        let encoder = JSONEncoder()
        do {
            let jsonString = try encoder.encode(worldAnchorsToFileNames)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsDirectory.appendingPathComponent(PersistenceManager.toysDatabaseFileName)
            
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
    func attachPersistedToyToAnchor(_ modelFileName: String, anchor: WorldAnchor) {
        guard let placeableToy = placeableToysByFileName[modelFileName] else {
            print("No toy available for '\(modelFileName)' - it will be ignored.")
            return
        }
        
        let toy = placeableToy.materialize()
        toy.position = anchor.originFromAnchorTransform.translation
        toy.orientation = anchor.originFromAnchorTransform.rotation
        toy.isEnabled = anchor.isTracked
        rootEntity.addChild(toy)
        
        anchoredToys[anchor.id] = toy
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
            // world tracking provider 시작시 이전 월드앵커가 있는지 확인
            if let persistedToyFileName = persistedToyFileNamePerAnchor[anchor.id] {
                attachPersistedToyToAnchor(persistedToyFileName, anchor: anchor)
            } else if let toyBeingAnchored = toysBeingAnchored[anchor.id] {
                toysBeingAnchored.removeValue(forKey: anchor.id)
                anchoredToys[anchor.id] = toyBeingAnchored
                
                // 지금 앵커 추가 성공
                rootEntity.addChild(toyBeingAnchored)
            } else {
                if anchoredToys[anchor.id] == nil {
                    Task {
                        // 바로 월드앵커 지우기
                        print("No toy is attached to anchor \(anchor.id) - it can be deleted.")
                        await removeAnchorWithID(anchor.id)
                    }
                }
            }
            fallthrough
        case .updated:
            // 실좌표와 동기화해서 배치된 객체 월드앵커 위치 유지 앵커가 추적중이 아니면 객체 숨김
            let toy = anchoredToys[anchor.id]
            toy?.position = anchor.originFromAnchorTransform.translation
            toy?.orientation = anchor.originFromAnchorTransform.rotation
            toy?.isEnabled = anchor.isTracked
        case .removed:
            // 실좌표에서 월드 앵커를 지웠으면 배치된 겍체 지움
            let toy = anchoredToys[anchor.id]
            toy?.removeFromParent()
            anchoredToys.removeValue(forKey: anchor.id)
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
    func attachToyToWorldAnchor(_ toy: PlacedToy) async {
        // 먼저 새로운 월드 앵커 만들고 world tracking provider를 추가
        let anchor = WorldAnchor(originFromAnchorTransform: toy.transformMatrix(relativeTo: nil))
        movingToys.removeAll(where: { $0 === toy })
        toysBeingAnchored[anchor.id] = toy
        do {
            try await worldTracking.addAnchor(anchor)
        } catch {
            // 월드 앵커 추가 실패, 갯수 제한 도달시 기존 월드 앵커는 유지 되지만 attach 안된 객체는 전부 삭제됨
            
            if let worldTrackingError = error as? WorldTrackingProvider.Error, worldTrackingError.code == .worldAnchorLimitReached {
                print(
"""
Unable to place toy "\(toy.name)". You’ve placed the maximum number of toys.
Remove old toys before placing new ones.
"""
                )
            } else {
                print("Failed to add world anchor \(anchor.id) with error: \(error).")
            }
            
            toysBeingAnchored.removeValue(forKey: anchor.id)
            toy.removeFromParent()
            return
        }
    }
    
    @MainActor
    private func detachToyFromWorldAnchor(_ toy: PlacedToy) {
        guard let anchorID = anchoredToys.first(where: { $0.value === toy })?.key else {
            return
        }
        
        // 움직이고 있기에 앵커된 객체 삭제
        anchoredToys.removeValue(forKey: anchorID)
        Task {
            // 월드앵커 불필요해서 삭제
            await removeAnchorWithID(anchorID)
        }
    }
    
    @MainActor
    func placedToy(for entity: Entity) -> PlacedToy? {
        return anchoredToys.first(where: { $0.value === entity })?.value
    }
    
    @MainActor
    func toy(for entity: Entity) -> PlacedToy? {
        if let placedToy = placedToy(for: entity) {
            return placedToy
        }
        if let movingToy = movingToys.first(where: { $0 === entity }) {
            return movingToy
        }
        if let anchoringToy = toysBeingAnchored.first(where: { $0.value === entity })?.value {
            return anchoringToy
        }
        return nil
    }
    
    @MainActor
    func removeToy(_ toy: PlacedToy) async {
        guard let anchorID = anchoredToys.first(where: { $0.value === toy })?.key else {
            return
        }
        await removeAnchorWithID(anchorID)
    }
    
    @MainActor
    func checkIfAnchoredToysNeedToBeDetached() async {
        let anchoredToysBeforeCheck = anchoredToys
        
        // 월드 앵커로 부터 detach가 필요하거나 더이상 rest 상태가 아닌지 확인
        for (anchorID, toy) in anchoredToysBeforeCheck {
            guard let anchor = worldAnchors[anchorID] else {
                toy.positionAtLastReanchoringCheck = toy.position(relativeTo: nil)
                movingToys.append(toy)
                anchoredToys.removeValue(forKey: anchorID)
                continue
            }
            
            let distanceToAnchor = toy.position(relativeTo: nil) - anchor.originFromAnchorTransform.translation
            
            if length(distanceToAnchor) >= toyAtRestThreshold {
                toy.atRest = false
                
                toy.positionAtLastReanchoringCheck = toy.position(relativeTo: nil)
                movingToys.append(toy)
                detachToyFromWorldAnchor(toy)
            }
        }
    }
    
    @MainActor
    func checkIfMovingToysCanBeAnchored() async {
        let movingToysBeforeCheck = movingToys
        
        // 지금 앵커 없는 객체인지 앞으로 attach할 새로운 월드앵커인지 확인
        for toy in movingToysBeforeCheck {
            guard !toy.isBeingDragged else { continue }
            guard let lastPosition = toy.positionAtLastReanchoringCheck else {
                toy.positionAtLastReanchoringCheck = toy.position(relativeTo: nil)
                continue
            }
            
            let currentPosition = toy.position(relativeTo: nil)
            let movementSinceLastCheck = currentPosition - lastPosition
            toy.positionAtLastReanchoringCheck = currentPosition
            
            if length(movementSinceLastCheck) < toyAtRestThreshold {
                toy.atRest = true
                await attachToyToWorldAnchor(toy)
            }
        }
    }
}
