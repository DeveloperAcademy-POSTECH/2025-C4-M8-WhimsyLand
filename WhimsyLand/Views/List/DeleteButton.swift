//
//  DeleteButton.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/15/25.
//
import SwiftUI

struct DeleteButton: View {
    var deletionHandler: (() -> Void)?

    var body: some View {
        Button {
            if let deletionHandler {
                deletionHandler()
            }
        } label: {
            Image(systemName: "trash")
        }
        .accessibilityLabel("Delete toy")
        .glassBackgroundEffect()
    }
}

#Preview(windowStyle: .plain) {
    DeleteButton()
}
