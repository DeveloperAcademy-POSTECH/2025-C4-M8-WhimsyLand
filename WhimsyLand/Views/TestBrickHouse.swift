//
//  TestBrickHouse.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/22/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct TestBrickHouse: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(ViewModel.self) private var model
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                
                if let skull = immersiveContentEntity.findEntity(named: "Skull") {
                    
                    let highlightStyle = HoverEffectComponent.HighlightHoverEffectStyle(
                        color: .white,
                        strength: 0.8
                    )
                    let hoverEffect = HoverEffectComponent(.highlight(highlightStyle))
                    
                    skull.components.set(hoverEffect)
                }
                
                content.add(immersiveContentEntity)
                
                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
            
        }
        // 이 부분이 중요합니다! RealityComposerPro에서 제스쳐랑 애니메이션 다 구현하는 상황에서는 RealityView에 제스쳐 코드 작성해야합니다.
        .gesture(TapGesture().targetedToAnyEntity()
            .onEnded({ value in
                _ = value.entity.applyTapForBehaviors()
            })
        )
        .overlay(alignment: .topTrailing) {
            Button {
                Task {
                    if model.immersiveSpaceState != .inTransition {
                        Task {
                            await model.switchToImmersiveMode(.mixed)
                        }
                    }
                }
            } label: {
                Text("셋째 돼지 집 나가기")
                    .font(.title2)
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
            }
            .padding(40)
        }
    }
}
