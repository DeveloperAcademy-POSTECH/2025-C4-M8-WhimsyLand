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
    let SpatialModelName : String
    
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
   
    var items: [ToyItem] = [
        ToyItem(ImageName: "FirstHouse",label: "첫째 돼지집", ModelName: "FirstHouse", SpatialModelName:"FirstHouse" ),
        ToyItem(ImageName: "SecondHouse",label: "둘째 돼지집", ModelName: "SecondHouse",SpatialModelName:"SecondHouse"),
        ToyItem(ImageName: "ThirdHouse",label: "셋째 돼지집", ModelName: "ThirdHouse", SpatialModelName:"ThirdHouse"),
        ToyItem(ImageName: "Fence1",label: "울타리 1", ModelName: "Fence1", SpatialModelName:"Fence1"),
        ToyItem(ImageName: "Fence2",label: "울타리 2", ModelName: "Fence2", SpatialModelName:"Fence2"),
        ToyItem(ImageName: "Tree1",label: "나무 1", ModelName: "Tree1", SpatialModelName:"Tree1"),
        ToyItem(ImageName: "Tree2",label: "나무 2", ModelName: "Tree2", SpatialModelName:"Tree2"),
        ToyItem(ImageName: "Tree3",label: "나무 3", ModelName: "Tree3", SpatialModelName:"Tree3"),
        ToyItem(ImageName: "BlueFlower",label: "파란꽃", ModelName: "BlueFlower", SpatialModelName:"BlueFlower"),
        ToyItem(ImageName: "RedFlower",label: "빨간꽃", ModelName: "RedFlower", SpatialModelName:"RedFlower"),
        ToyItem(ImageName: "Grass",label: "풀1", ModelName: "Grass",SpatialModelName:"Grass"),
        ToyItem(ImageName: "Grass2",label: "풀2", ModelName: "Grass2", SpatialModelName:"Grass2"),
        ToyItem(ImageName: "Firewood",label: "장작나무", ModelName: "Firewood", SpatialModelName:"Firewood"),
        ToyItem(ImageName: "Ox",label: "도끼", ModelName: "Ox", SpatialModelName:"Ox"),
        ToyItem(ImageName: "Pond",label: "연못", ModelName: "Pond", SpatialModelName:"Spatial_Pond"),
        ToyItem(ImageName: "Stone",label: "돌멩이", ModelName: "Stone", SpatialModelName:"Stone"),
    ]
}
