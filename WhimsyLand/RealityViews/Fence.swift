//
//  Home.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/9/25.
//

import SwiftUI
import RealityKit

struct Fence: View {
    var body: some View {
        VStack{
            HStack{
                Text("Reality3DView")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                
                
                RealityView { content in
                    if let entity = try? await Entity(named: "Box") {
                        entity.setPosition([0, -0.01, 0], relativeTo: nil)
                        content.add(entity)
                    }
                }
            }
            
        }.padding(20)
       
    }
}


#Preview(immersionStyle: .mixed){
    Fence().environment(ViewModel())
}
