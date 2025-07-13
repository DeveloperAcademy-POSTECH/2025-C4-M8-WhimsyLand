//
//  WhimsyLandApp.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/8/25.
//

import SwiftUI

@main
struct WhimsyLandApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
        
        WindowGroup(id: "first") {
            ChildView(id: "first", title: "first", color: .red)
            // Assets에 image 파일이 없으므로 오류를 피하기 위해 주석 처리. image 파일 추가 후 주석 삭제.

            //                      , image: "image1")
        }
        .windowStyle(.plain)
        .defaultSize(.infinity)

        WindowGroup(id: "second") {
            ChildView(id: "second", title: "second", color: .yellow)
//            , image: "image2")
        }
        .windowStyle(.plain)
        .defaultSize(.infinity)
    }
}
