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

/// The data that the app uses to configure its views.
@MainActor
@Observable
class ViewModel {
    // MARK: - immersive
    let mixedImmersiveID = "MixedImmersive"
    let fullImmersiveID = "FullImmersive"
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var currentImmersiveMode: ImmersiveMode = .none
    var mixedImmersiveState = MixedImmersiveState()
    
    var extractedObject: String? = nil
    
    // MARK: - Navigation
    var navigationPath: [Module] = []
    
    // MARK: - threeLittlePigs
    var isShowBrickHouse = false

    func switchToImmersiveMode(
        _ mode: ImmersiveMode,
        open: @escaping (_ id: String) async -> OpenImmersiveSpaceAction.Result,
        dismiss: @escaping () async -> Void
    ) async {
        guard immersiveSpaceState != .inTransition else { return }
        immersiveSpaceState = .inTransition
        
        // 1. 기존 immersiveSpace 닫기
        if immersiveSpaceState == .open {
            await dismiss()
            immersiveSpaceState = .closed
        }
        
        // 2. 새로운 immersiveSpace 열기
        let idToOpen: String
        switch mode {
        case .mixed:
            idToOpen = mixedImmersiveID
        case .full:
            idToOpen = fullImmersiveID
        case .none:
            currentImmersiveMode = .none
            immersiveSpaceState = .closed
            return
        }
        
        let result = await open(idToOpen)
        switch result {
        case .opened:
            immersiveSpaceState = .open
            currentImmersiveMode = mode
        default:
            immersiveSpaceState = .closed
            currentImmersiveMode = .none
        }
    }
    
    // App이 갑자기 종료되었을 때, immersive 상태를 관리하는 함수
    func handleAppDidDeactivate(dismiss: @escaping () async -> Void) {
        guard immersiveSpaceState == .open
        else { return }

        Task {
            await dismiss()
            immersiveSpaceState = .closed
            
            if currentImmersiveMode == .mixed {
                mixedImmersiveState.didLeaveMixedImmersiveSpace()
            }
            
            currentImmersiveMode = .none
        }
    }
}
