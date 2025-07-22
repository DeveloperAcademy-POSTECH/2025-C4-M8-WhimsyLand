//
//  ToyCard.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/22/25.
//

import SwiftUI

struct ToyCard: View {
    
    let imageName: String
    let label: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                
                Text(label)
                    .font(.pretendard(.semibold, size: 24))
            }
            .padding()
            .background(.fill.quaternary)
            .cornerRadius(16)
            .hoverEffect()
            .onTapGesture {
                onTap()
            }
        }
    }
}

//#Preview {
//    ToyCard()
//}
