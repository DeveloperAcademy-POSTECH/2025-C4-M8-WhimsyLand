//
//  HomeView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    @State private var isDetailActive = false
    
    var body: some View {
        Group{
            if viewModel.currentSize == .small {
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
                                .font(.pretendard(.semibold, size: 16))
                        }.frame(width: 150, height: 44)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.currentSize = .medium
                        }) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .frame(width: 22, height: 22)
                        }
                        .frame(width: 44, height: 44)
                    }
                    .frame(width: 210, height: 44)
                    
                }.frame(width:  viewModel.frameWidth, height: viewModel.frameHeight)

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
                        
                        Spacer()
                        
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
                                viewModel.currentSize = .small
                            }) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .frame(width: 44, height: 44)
                                    .padding(8)
                            }.frame(width: 60, height:60)
                        }
                    }
                }
                .frame(width:  viewModel.frameWidth, height: viewModel.frameHeight)
                .padding(32)
            }
        }
        .glassBackgroundEffect()
        .onAppear{
            viewModel.currentSize = .medium
            
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
