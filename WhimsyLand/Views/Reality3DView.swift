
//
//  Reality3DView.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/14/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct Reality3DView: View {
    let toyName: String

    var body: some View {
        RealityView { content in
            if let entity = try? await Entity(named: toyName, in: realityKitContentBundle) {
                content.add(entity)
            }
        }
    }
}
