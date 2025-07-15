//
//  ListView.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI

struct ListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppState.self) private var appState
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @State private var searchText = ""
    let immersiveSpaceIdentifier: String
    var module: Module
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Object(10)")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Mixed Immersive Enter Button
                Button("Try Enter") {
                    Task {
                        await appState.requestWorldSensingAuthorization()
                        
                        switch await openImmersiveSpace(id: immersiveSpaceIdentifier) {
                        case .opened:
                            print("Immersive space opened successfully: \(immersiveSpaceIdentifier)")
                            break
                        case .error:
                            print("An error occurred when trying to open the immersive space \(immersiveSpaceIdentifier)")
                        case .userCancelled:
                            print("The user declined opening immersive space \(immersiveSpaceIdentifier)")
                        @unknown default:
                            break
                        }
                    }
                }
                .disabled(!appState.canEnterImmersiveSpace)
                
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
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
            
            // Book Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)
                ], spacing: 30) {
                
                    // Additional placeholder books for scrolling
                    ForEach(1..<10) { index in
                        VStack(spacing: 20) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.6))
                                .frame(width:304, height: 328)
                            
                            Text("Book Title \(index)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(width:1020, height: 678)
        .cornerRadius(20)
    }
}

#Preview("ThreeLittlePigs") {
    NavigationStack {
        ListView(
            immersiveSpaceIdentifier: "Object Placement",
            module: .threeLittlePigs
        )
        .environment(AppState())
    }
}
