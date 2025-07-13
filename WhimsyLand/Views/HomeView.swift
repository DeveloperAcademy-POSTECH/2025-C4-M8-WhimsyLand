//
//  HomeView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI

struct Book {
    let id = UUID()
    let title: String
    let imageName: String?
    let coverColor: Color
}

struct HomeView: View {
    //    @Environment(ViewModel.self) private var model
    @State private var searchText = ""
    @State private var currentPage = 0
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        //        @Bindable var model = model
        
        NavigationStack{
            VStack {
                // Header
                HStack {
                    Text("WhimsyLand")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.gray)
                        
                        TextField("Search", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    .frame(width: 300)
                }.padding(20)
                
                Spacer()
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 20) {
                        ForEach(Module.allCases) { module in
                            NavigationLink(destination: ListView(module: module)) {
                                FairyTaleCard(module: module)
                            }.buttonBorderShape(.roundedRectangle(radius: 20))
                            .frame(width: 276, height: 344)
                        }
                    }
                    .padding(.horizontal, 20)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            }
        }
    }
}


#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 1020, height: 540)) {
    HomeView()
}
