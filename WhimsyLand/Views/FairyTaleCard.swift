//
//  FairyTaleCard.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/13/25.
//

import SwiftUI

struct FairyTaleCard: View {
    var module: Module
    
    var body: some View {
        VStack {
            Image(module.fairyTaleImg)
                .resizable()
                .frame(width: 232, height: 265)
            Text("\(module.fairyTaleTitle)")
        }.frame(width: 276, height: 344)
    }
}

#Preview {
    HStack {
        FairyTaleCard(module:.threeLittlePigs)
    }
    .padding()
    .glassBackgroundEffect()
}
