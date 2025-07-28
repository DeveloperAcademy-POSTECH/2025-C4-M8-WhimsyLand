//
//  ToyData.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/22/25.
//

import SwiftUI

struct ToyItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let ImageName: String
    let label: String
    let ModelName: String
    
    var module: ToyModule? {
        ToyModule(rawValue: ImageName)
    }
    var fullInfoCardContent: FullInfoCardContent? {
        FullInfoCardContent(rawValue: ImageName)
    }
}

@MainActor
@Observable
class ToyModel {
    
    var selectedItem: ToyItem? = nil
    var isSecondaryWindowShown: Bool = false
    
    var items: [ToyItem] = [
        ToyItem(ImageName: "RagHouse",label: "첫째 돼지집", ModelName: "Firewood"),
        ToyItem(ImageName: "TreeHouse",label: "둘째 돼지집", ModelName: "Cube"),
        ToyItem(ImageName: "BrickHouse",label: "셋째 돼지집", ModelName: "Cylinder"),
        ToyItem(ImageName: "Fence1",label: "울타리 1", ModelName: "Fence1"),
        ToyItem(ImageName: "Fence2",label: "울타리 2", ModelName: "Fence2"),
        ToyItem(ImageName: "Tree1",label: "나무 1", ModelName: "Tree1"),
        ToyItem(ImageName: "Tree2",label: "나무 2", ModelName: "Tree2"),
        ToyItem(ImageName: "Tree3",label: "나무 3", ModelName: "Tree3"),
        ToyItem(ImageName: "BlueFlower",label: "파란꽃", ModelName: "BlueFlower"),
        ToyItem(ImageName: "RedFlower",label: "빨간꽃", ModelName: "RedFlower"),
        ToyItem(ImageName: "Grass",label: "풀1", ModelName: "Grass"),
        ToyItem(ImageName: "Grass2",label: "풀2", ModelName: "Grass2"),
        ToyItem(ImageName: "Firewood",label: "장작나무", ModelName: "Firewood"),
        ToyItem(ImageName: "OX",label: "도끼", ModelName: "OX"),
    ]
}
