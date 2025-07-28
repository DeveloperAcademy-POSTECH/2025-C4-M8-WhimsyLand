//
//  EnterFullButton.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/25/25.
//
import SwiftUI

struct EnterFullButton: View {
    @Environment(ViewModel.self) private var model
//    아래 주석 참고.
//    아래 코드도 테스트시 활성화
//    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
//

    var toyItem: ToyItem
    
    var body : some View {
        Button("시작하기") {
            if model.immersiveSpaceState != .inTransition {
                Task {
                    await model.switchToImmersiveMode(.full)
                    // 테스트를 위한 임시 코드
                    // Simulator 환경일 때, ToyDetail에서 바로 full 로 진입하고 싶으면 사용
                    // 단, Full을 탈출할때 처리 함수가 구현이 안되어있으므로
                    // Full 진입 후 탈출 시 앱이 종료되는것이 정상
                    // 버튼 활성화를 위해서는
                    // ToyDetail 에서 변경 사항
                    // .disabled(model.currentImmersiveMode != .mixed)
                    // 위의 코드를 주석 처리해야됨.
//                    if model.immersiveSpaceState == .closed {
//                        let result = await openImmersiveSpace(id: model.ImmersiveId)
//                        if case .opened = result {
//                            model.immersiveSpaceState = .open
//                        }
//                    }
                    //
                    if let fullImmersiveContent = toyItem.fullInfoCardContent?.fullImmersiveContent {
                        model.switchFullImmersiveContent(fullImmersiveContent)
                    }
                    else {
                        model.switchFullImmersiveContent(.none)
                    }
                }
            }
        }
        .buttonStyle(.bordered)
        .padding(.top, 34)
        .disabled(toyItem.fullInfoCardContent == nil)
    }
}
