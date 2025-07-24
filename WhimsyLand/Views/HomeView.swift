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
                    ListView()
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
            if model.mixedImmersiveState.allRequiredProvidersAreSupported {
                await model.mixedImmersiveState.requestWorldSensingAuthorization()
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
