//
//  EnterFullButton.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/25/25.
//
import SwiftUI

struct EnterFullButton: View {
    @Environment(ViewModel.self) private var model

    var toyItem: ToyItem
    
    var body : some View {
        Button("시작하기") {
            if model.immersiveSpaceState != .inTransition {
                Task {
                    await model.switchToImmersiveMode(.full)
                    // 여기서 full 이 어떤 full 을 보여줄지 item 으로 결정하기
                }
            }
            print("선택한 item name : \(toyItem.ImageName)")
        }
        .buttonStyle(.bordered)
        //.disabled(item.fullModule == nil) // 여기서 만약 item이 full 에 대한 정보를 갖고 있지 않으면 disable 하도록 하기
    }
}
