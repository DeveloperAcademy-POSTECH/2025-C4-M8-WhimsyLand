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
    
    // item에 따라 다른 immersion 스타일
    @State private var houseImmersionStyle: ImmersionStyle = .full


    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(model)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1020, height: 540)
        
        // scene 일부분을 immersive space로 정의
        ImmersiveSpace(id: Module.threeLittlePigs.name ) {
            House()
                .onAppear {
                    model.isShowBrickHouse = true
                }
                .onDisappear {
                    model.isShowBrickHouse = false
                }
        }.immersionStyle(selection: $houseImmersionStyle, in: .full)
    }
}
