//
//  ViewModel.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/9/25.
//

import SwiftUI

enum ImmersiveMode {
    case none       // immersive space 없음
    case mixed      // 배치 공간
    case full       // 내부 탐색 공간
}

enum FullImmersiveContent {
    case none
    case ragHouse
    case treeHouse
    case brickHouse
}

/// The data that the app uses to configure its views.
@MainActor
@Observable
class ViewModel {
    // MARK: - Window
    let HomeViewID = "HomeView"
    let ListViewID = "ListView"
    let ToyDetailViewID = "ToyDetailView"
    
    var isListWindowShown: Bool = false
    var isSecondaryWindowShown: Bool = false
    
    // MARK: - immersive
    let ImmersiveId = "Immersive"
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var currentImmersiveMode: ImmersiveMode = .none
    var immersionStyle: ImmersionStyle = .mixed
    
    var mixedImmersiveState = MixedImmersiveState()
    var extractedToy: String? = nil
    var fullImmersiveContent: FullImmersiveContent = .none
    
    func switchToImmersiveMode(
        _ mode: ImmersiveMode
    ) async {
        if currentImmersiveMode == mode { return }
        
        currentImmersiveMode = mode
        switch mode {
        case .mixed: immersionStyle = .mixed
        case .full:
            immersionStyle = .full
            mixedImmersiveState.didLeaveMixedImmersiveSpace()
        case .none: break
        }
    }
    
    func switchFullImmersiveContent(
        _ content: FullImmersiveContent
    ) {
        fullImmersiveContent = content
    }
    
    // MARK: - Navigation
    var navigationPath: [Module] = []
    
    // MARK: - threeLittlePigs
    var isShowBrickHouse = false
    
   
    // App이 갑자기 종료되었을 때, immersive 상태를 관리하는 함수
    func handleAppDidDeactivate(dismiss: @escaping () async -> Void) {
        print("앱 종료 함수 호출됨")
        guard immersiveSpaceState == .open
        else { return }
        
        Task {
            await dismiss()
            immersiveSpaceState = .closed
            
            if currentImmersiveMode != .none {
                mixedImmersiveState.didLeaveMixedImmersiveSpace()
            }
            
            currentImmersiveMode = .none
        }
    }
}
