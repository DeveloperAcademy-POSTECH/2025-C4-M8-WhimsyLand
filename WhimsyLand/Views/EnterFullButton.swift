//
//  EnterFullButton.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/25/25.
//
import SwiftUI

struct EnterFullButton: View {
    @Environment(ViewModel.self) private var viewModel
//    아래 주석 참고.
//    아래 코드도 테스트시 활성화
//    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
//

    var toyItem: ToyItem
    
    var body : some View {
        Button("시작하기") {
            if viewModel.immersiveSpaceState != .inTransition {
                Task {
                    await viewModel.switchToImmersiveMode(.full)
                    // 테스트를 위한 임시 코드
                    // Simulator 환경일 때, ToyDetail에서 바로 full 로 진입하고 싶으면 사용
                    // 단, Full을 탈출할때 처리 함수가 구현이 안되어있으므로
                    // Full 진입 후 탈출 시 앱이 종료되는것이 정상
                    //
                    // Full을 열기 위해서 해야할 일
                    // (1) 버튼 활성화를 위해서 Views/ToyDetail.swift에서
                    //     EnterFullButton(toyItem: item)
                    //          .environment(viewModel)
                    //      위의 코드를 추가해야됨.
                    // (2) 환경변수가 필요하므로 Views/EnterFullButton.swift(현재파일)에서
                    //      13번째 줄의 openImmersiveSpace 를 주석 해제
                    // (3) immersiveSpace를 열기 위해 아래 코드를 주석 해제
//                    if viewModel.immersiveSpaceState == .closed {
//                        let result = await openImmersiveSpace(id: viewModel.ImmersiveId)
//                        if case .opened = result {
//                            viewModel.immersiveSpaceState = .open
//                        }
//                    }
//                    
                    if let fullImmersiveContent = toyItem.fullInfoCardContent?.fullImmersiveContent {
                        viewModel.switchFullImmersiveContent(fullImmersiveContent)
                    }
                    else {
                        viewModel.switchFullImmersiveContent(.none)
                    }
                }
            }
        }
        .buttonStyle(.bordered)
        .padding(.top, 34)
        .disabled(toyItem.fullInfoCardContent == nil)
    }
}
