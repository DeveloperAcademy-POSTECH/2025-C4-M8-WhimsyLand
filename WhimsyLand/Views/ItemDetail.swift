//
//  ItemDetail.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/14/25.
//

import SwiftUI

struct ItemDetail: View {
    let descriptor: ModelDescriptor
    let description: String
    let onClose: () -> Void
    let onExtract: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text(descriptor.displayName)
                    .font(.largeTitle.bold())
                Spacer()
                Button("닫기", action: onClose)
                    .buttonStyle(.borderedProminent)
            }
            Text(description)
                .font(.body)
            Reality3DView(objectName: descriptor.fileName)
                .frame(height: 250)
            Button("꺼내서 조작하기", action: onExtract)
                .buttonStyle(.bordered)
        }
        .padding(32)
        .cornerRadius(32)
        .shadow(radius: 20)
        .frame(width:680, height: 580)
    }
}

#Preview {
    NavigationStack{
        ItemDetail(
            descriptor: ModelDescriptor(fileName: "strawHouse", displayName: "초가집"),
            description: "첫째 아기돼지는 지푸라기로 된 집을 지었어요",
            onClose: {},
            onExtract: {}
        )
    }
}
