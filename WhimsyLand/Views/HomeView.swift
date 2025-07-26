//
//  HomeView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI

// TODO : 별도 파일로 빼기
enum FrameSize {
    case small, medium, large
}

struct HomeView: View {
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(ViewModel.self) private var model
    @Environment(PlaceableItemStore.self) var placeableItemStore
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isDetailActive = false
    @State private var currentSize: FrameSize = .medium
    
    // TODO : extension으로 가능 ?
    private var frameWidth: CGFloat {
        switch currentSize {
        case .small: return 274
        case .medium: return 1067
        case .large: return 1020
        }
    }
    
    // TODO : extension으로 가능 ?
    private var frameHeight: CGFloat {
        switch currentSize {
        case .small: return 439
        case .medium: return 353
        case .large: return 678
        }
    }
    
    var body: some View {
        NavigationStack{
            HStack{
                Group{
                    if currentSize == .small {
                        VStack {
                            Image("ThreeLittlePigs")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                            HStack{
                                Button(action: {
                                    isDetailActive = true
                                    currentSize = .large
                                }){
                                    Text("아이템 배치하기")
                                        .font(.pretendard(.semibold, size: 24))
                                }.frame(width: 150, height: 44)
                                
                                Button(action: {
                                    currentSize = .medium
                                }) {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    
                                }.frame(width: 60, height: 60)
                            }
                        }
                    }else {
                        Image("ThreeLittlePigs")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        
                        VStack(alignment: .leading, spacing: 20){
                            Text("아기돼지 삼형제")
                                .font(.pretendard(.semibold, size: 38))
                            
                            Text("아기돼지 삼형제의 집을 여러분의 공간에 배치해보세요.\n집안에 들어가 다양한 콘텐츠를 즐겨 보세요")
                                .font(.pretendard(.regular, size: 24))
                                .lineLimit(nil)
                                .padding(.top, 16)
                            
                            Spacer()
                            
                            HStack{
                                Button(action: {
                                    isDetailActive = true
                                    currentSize = .large
                                }){
                                    Text("아이템 배치하기")
                                        .font(.pretendard(.semibold, size: 24))
                                        .padding(.horizontal, 24)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    currentSize = .small
                                }) {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                }.frame(width: 60, height: 60)
                                
                            }
                        }
                    }
                }
            }
            .glassBackgroundEffect()
            .padding(32)
            .navigationDestination(isPresented: $isDetailActive){
                ListView()
                    .environment(placeableItemStore)
                    .environment(model)
            }
            .onAppear{
                currentSize = .medium
            }
        }
        .frame(width:  frameWidth, height: frameHeight)
        .animation(.easeInOut, value: currentSize )
        .task {
            if model.mixedImmersiveState.allRequiredProvidersAreSupported {
                await model.mixedImmersiveState.requestWorldSensingAuthorization()
            }
        }
        .onChange(of: isDetailActive) {
            if !isDetailActive {
                model.mixedImmersiveState.mixedImmersiveMode = .viewing
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase != .active {
                Task {
                    model.handleAppDidDeactivate(dismiss: dismissImmersiveSpace.callAsFunction)
                }
            }
        }
    }
}
