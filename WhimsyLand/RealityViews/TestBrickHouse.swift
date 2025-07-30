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
    @Environment(ViewModel.self) private var model
    
    var body: some View {
        RealityView(
            make: { content, attachments in
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
                
                if let exitButtonAttachment = attachments.entity(for: "exitButtonView") { // ID로 어태치먼트 가져오기
                    exitButtonAttachment.transform.translation = [0, 1.5, 0] // X, Y, Z (미터 단위)
                    
                    content.add(exitButtonAttachment)
                }
                
            }, update: { content, attachments in
                if attachments.entity(for: "exitButtonView") != nil {
                }
            },
            //        }
            // MARK: - Attachments 정의
            attachments: {
                Attachment(id: "exitButtonView") {
                    VStack(alignment: .center) {
                        Text("셋째 돼지집에서 나가시겠습니까?")
                            .font(.pretendard(.bold, size: 19))
                        Divider()
                        Button {
                            Task {
                                if model.immersiveSpaceState != .inTransition {
                                    Task {
                                        await model.switchToImmersiveMode(.mixed)
                                    }
                                }
                            }
                        } label: {
                            Text("나가기")
                                .font(.pretendard(.semibold, size: 17))
                                .frame(width:230, height: 44)
                        }
                    }
                    .frame(width: 320, height: 125)
                    .glassBackgroundEffect()
                }
            }
        )
        // 이 부분이 중요합니다! RealityComposerPro에서 제스쳐랑 애니메이션 다 구현하는 상황에서는 RealityView에 제스쳐 코드 작성해야합니다.
        .gesture(TapGesture().targetedToAnyEntity()
            .onEnded({ value in
                _ = value.entity.applyTapForBehaviors()
            })
        )
    }
}

