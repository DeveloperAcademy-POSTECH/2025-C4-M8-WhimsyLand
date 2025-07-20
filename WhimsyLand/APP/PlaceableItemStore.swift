//
//  PlaceableItemStore.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/18/25.
//

import Foundation

@Observable
class PlaceableItemStore {
    // 배치 가능한 오브젝트 저장 및 오브젝트 파일
    private(set) var placeableObjectsByFileName: [String: PlaceableObject] = [:]
    private(set) var modelDescriptors: [ModelDescriptor] = []
    var selectedFileName: String?
    
    func setPlaceableObjects(_ objects: [PlaceableObject]) {
        placeableObjectsByFileName = objects.reduce(into: [:]) { map, placeableObject in
            map[placeableObject.descriptor.fileName] = placeableObject
        }
   }
}
