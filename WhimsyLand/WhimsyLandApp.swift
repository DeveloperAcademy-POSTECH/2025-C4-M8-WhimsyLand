//
//  WhimsyLandApp.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/8/25.
//

import SwiftUI

@main
struct WhimsyLandApp: App {
    // view model
    @State private var model = ViewModel()
    @State private var extractedObject: ObjectModule? = nil

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(model)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1020, height: 540)

        WindowGroup(id: "ExtractedObject") {
            if let object = extractedObject {
                Reality3DView(objectName: object.rawValue)
            }
        }
        .defaultSize(width: 0.4, height: 0.4, depth: 0.4, in: .meters)
        .windowStyle(.volumetric)
    }
}
