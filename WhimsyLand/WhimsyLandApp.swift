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

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(model)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1020, height: 540)
    }
}
