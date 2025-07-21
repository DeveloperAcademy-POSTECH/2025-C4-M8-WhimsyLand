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
    @Environment(ViewModel.self) private var model
    
    @State private var isDetailActive = false
    @State private var currentSize: FrameSize = .medium
    
    // TODO : extension으로 가능 ?
    private var frameWidth: CGFloat {
        switch currentSize {
               case .small: return 258
               case .medium: return 1067
               case .large: return 1020
               }
    }
    
    // TODO : extension으로 가능 ?
    private var frameHeight: CGFloat {
          switch currentSize {
          case .small: return 435
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
                                            .font(.system(size: 24, weight: .semibold))
                                            .padding(.horizontal, 24)
                                    }
                                    
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
                                    .font(.system(size: 38 ))
                                    .bold()
                                
                                Text("아기돼지 삼형제의 집을 여러분의 공간에 배치해보세요.\n집안에 들어가 다양한 콘텐츠를 즐겨 보세요")
                                    .font(.system(size: 32))
                                    .lineLimit(nil)
                                    .padding(.top, 16)
                            
                                Spacer()
                            
                                HStack{

                                    Button(action: {
                                        isDetailActive = true
                                        currentSize = .large
                                    }){
                                        Text("아이템 배치하기")
                                            .font(.system(size: 24, weight: .semibold))
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
                }
                .onAppear{
                    currentSize = .medium
                }
            }
            .frame(width:  frameWidth, height: frameHeight)
            .animation(.easeInOut, value: currentSize )
        }
       
    }

//
//#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 1060, height: 360)) {
//    HomeView()
//}
