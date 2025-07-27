//
//  EnterFullButton.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/25/25.
//
import SwiftUI

struct EnterFullButton: View {
    @Environment(ViewModel.self) private var model

    var item: ToyItem
    
    var body : some View {
        Button("시작하기") {
            if model.immersiveSpaceState != .inTransition {
                Task {
                    await model.switchToImmersiveMode(.full)
                    
                    if let fullInfoCardContent = item.fullInfoCardContent?.fullImmersiveContent {
                        model.switchFullImmersiveContent(fullInfoCardContent)
                    }
                    else {
                        model.switchFullImmersiveContent(.none)
                    }
                }
            }
        }
        .buttonStyle(.bordered)
        .padding(.top, 34)
        .disabled(item.fullInfoCardContent == nil)
    }
}
