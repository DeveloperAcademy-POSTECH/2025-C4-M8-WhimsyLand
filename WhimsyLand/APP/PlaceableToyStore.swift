//
//  PlaceableToyStore.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/18/25.
//

import Foundation

@Observable
class PlaceableToyStore {
    // 배치 가능한 Toy 저장 및 Toy 파일
    private(set) var placeableToysByFileName: [String: PlaceableToy] = [:]
    private(set) var modelDescriptors: [ModelDescriptor] = []
    var selectedFileName: String?
    
    func setPlaceableToys(_ toys: [PlaceableToy]) {
        placeableToysByFileName = toys.reduce(into: [:]) { map, placeableToy in
            map[placeableToy.descriptor.fileName] = placeableToy
        }
   }
}
