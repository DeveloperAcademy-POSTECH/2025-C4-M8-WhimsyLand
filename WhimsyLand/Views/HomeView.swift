//
//  HomeView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(PlaceableItemStore.self) var placeableItemStore
    @Environment(ViewModel.self) var model
    @State private var isDetailActive = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack{
                let isControl = geometry.size.width < 300 || geometry.size.height < 400
                HStack{
                    Group{
                        if isControl {
                            VStack {
                                Image("ThreeLittlePigs")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 300)
                                
                                Button("시작하기") {
                                    isDetailActive = true
                                }
                            }
                        }else {
                            Image("ThreeLittlePigs")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 300)
                            
                            VStack(alignment: .leading){
                                Text("아기돼지 삼형제")
                                    .font(.system(size: 38 ))
                                    .bold()
                                
                                Text("아기돼지 삼형제의 집을 여러분의 공간에 배치해보세요.\n집안에 들어가 다양한 콘텐츠를 즐겨 보세요")
                                    .font(.system(size: 32))
                                    .lineLimit(nil)
                                    .padding(.top, 16)
                                
                                Button("시작하기") {
                                    isDetailActive = true
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .background(.pink)
                .navigationDestination(isPresented: $isDetailActive){
                    ListView(modelDescriptors: placeableItemStore.modelDescriptors)
                        .environment(placeableItemStore)
                        .environment(model)
                }
            }
            .padding(30)
        }
        .background(.blue)
        .frame(width: isDetailActive ?  1020 : 1060, height: isDetailActive ? 678 :  360)
        .animation(.easeInOut, value: isDetailActive )
        
        .task {
            // 1. 권한 요청
            await model.mixedImmersiveState.requestWorldSensingAuthorization()
            
            // 2. 조건 체크
            if model.mixedImmersiveState.canEnterMixedImmersiveSpace {
                // 3. 진입 가능 시 immersive 열기
                await model.switchToImmersiveMode(
                    .mixed,
                    open: { id in await openImmersiveSpace(id: id) },
                    dismiss: dismissImmersiveSpace.callAsFunction
                )
            } else {
                // 4. 진입 불가
                print("⚠️ Mixed Immersive 공간 진입 불가: 센서 권한 또는 디바이스 미지원")
            }
        }
        .onChange(of: isDetailActive) {
            if !isDetailActive {
                model.mixedImmersiveState.mixedImmersiveMode = .viewing
                print("🛠️ mixedImmersiveMode = viewing")
            }
        }
    }
}

//
//#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 1060, height: 360)) {
//    HomeView()
//}
