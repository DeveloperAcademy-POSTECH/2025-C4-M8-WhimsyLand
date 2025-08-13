//
//  ThirdHouse.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/22/25.
//

import SwiftUI
import RealityKit

struct ThirdHouse: View {
    @Environment(ViewModel.self) private var model
    @State private var session: SpatialTrackingSession?
    
    var body: some View {
        RealityView(
            make: { content, attachments in
                if let immersiveContentEntity = try? await Entity(named: "Immersive") {
                    
                    if let firewood = immersiveContentEntity.findEntity(named: "firewood") {
                        
                        let highlightStyle = HoverEffectComponent.HighlightHoverEffectStyle(
                            color: .white,
                            strength: 0.8
                        )
                        let hoverEffect = HoverEffectComponent(.highlight(highlightStyle))
                        
                        firewood.components.set(hoverEffect)
                    }
                    
                    content.add(immersiveContentEntity)
                }
                
                if let exitButtonAttachment = attachments.entity(for: "exitButtonView") { // ID로 어태치먼트 가져오기
                    exitButtonAttachment.transform.translation = [0.3, 1.5, -0.3] // X, Y, Z (미터 단위)
                    
                    content.add(exitButtonAttachment)
                }
                
                let session = SpatialTrackingSession()
                let configuration = SpatialTrackingSession.Configuration(tracking: [.hand])
                _ = await session.run(configuration)
                self.session = session

                let rightHandAnchor = AnchorEntity(.hand(.right, location: .palm), trackingMode: .continuous)
                let leftHandAnchor = AnchorEntity(.hand(.left, location: .palm), trackingMode: .continuous)
                
                if let gauntletRightEntity = try? await Entity(named: "Pighand_R"), let gauntletLeftEntity = try? await Entity(named: "Pighand_L") {
                   
                    //Child the gauntlet scene to the handAnchor.
                    rightHandAnchor.addChild(gauntletRightEntity)
                    leftHandAnchor.addChild(gauntletLeftEntity)
                    
                    // Add the handAnchor to the RealityView scene.
                    content.add(rightHandAnchor)
                    content.add(leftHandAnchor)
                   
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
        .upperLimbVisibility(.hidden)
        .gesture(TapGesture().targetedToAnyEntity()
            .onEnded({ value in
                _ = value.entity.applyTapForBehaviors()
            })
        )
    }
}
