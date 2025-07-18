//
//  PlaceableItemStore.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/18/25.
//

import Foundation

@Observable
class PlaceableItemStore {
    var selectedFileName: String?
    private(set) var placeableObjectsByFileName: [String: PlaceableObject] = [:] // 배치 가능한 오브젝트 저장 및 오브젝트 파일명
    private(set) var modelDescriptors: [ModelDescriptor] = []
    
    func setPlaceableObjects(_ objects: [PlaceableObject]) {
        placeableObjectsByFileName = objects.reduce(into: [:]) { map, placeableObject in
            map[placeableObject.descriptor.fileName] = placeableObject
        }

        // Sort descriptors alphabetically.
        modelDescriptors = objects.map { $0.descriptor }.sorted { lhs, rhs in
            lhs.displayName < rhs.displayName
        }
   }
}
