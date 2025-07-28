//
//  HomeView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI

// TODO : 별도 파일로 빼기
enum FrameSize {
    case small, medium
}

struct HomeView: View {
    
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    @State private var isDetailActive = false
    @State private var currentSize: FrameSize = .medium
    
    // TODO : extension으로 가능 ?
    private var frameWidth: CGFloat {
        switch currentSize {
        case .small: return 274
        case .medium: return 1067
        }
    }
    
    // TODO : extension으로 가능 ?
    private var frameHeight: CGFloat {
        switch currentSize {
        case .small: return 439
        case .medium: return 353
        }
    }
    
    var body: some View {
        Group{
            if currentSize == .small {
                VStack {
                    Image("ThreeLittlePigs")
                        .resizable()
                        .frame(width: 210, height: 315)
                    HStack{
                        Button(action: {
                            isDetailActive = true
                            openWindow(id: viewModel.ListViewID)
                        }){
                            Text("아이템 배치하기")
                                .font(.pretendard(.semibold, size: 18))
                        }.frame(width: 150, height: 44)
                        
                        Button(action: {
                            currentSize = .medium
                        }) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .frame(width: 22, height: 22)
                                .padding(11)
                            
                        }.frame(width: 44, height: 44)
                    }.padding(.top, 16)
                }.frame(width:  frameWidth, height: frameHeight)
                    .padding(32)
            }else {
                HStack{
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
                        
                        HStack{
                            Button(action: {
                                isDetailActive = true
                                openWindow(id: viewModel.ListViewID)
                            }){
                                Text("아이템 배치하기")
                                    .font(.pretendard(.semibold, size: 24))
                                    .padding(24)
                            }
                            .frame(width: 280, height: 72)
                            
                            Spacer()
                            
                            Button(action: {
                                currentSize = .small
                            }) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .frame(width: 44, height: 44)
                                    .padding(8)
                            }.frame(width: 60, height:60)
                        }
                    }
                }
                .frame(width:  frameWidth, height: frameHeight)
            }
        }
        .glassBackgroundEffect()
        .onAppear{
            currentSize = .medium
            
            if viewModel.isSecondaryWindowShown {
                dismissWindow(id: viewModel.ToyDetailViewID)
            }
            
            if viewModel.isListWindowShown {
                dismissWindow(id: viewModel.ListViewID)
                viewModel.isListWindowShown = false
            }
        }
    }
}
