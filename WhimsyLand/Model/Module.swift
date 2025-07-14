//
//  ViewModel.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/9/25.
//

import Foundation

/// A description of the modules that the app can present.
enum Module: String, Identifiable, CaseIterable, Equatable {
    
    case threeLittlePigs, fairyTale2, fairyTale3, fairyTale4
    var id: Self { self }
    var name: String { rawValue.capitalized }
    
    var fairyTaleImg: String {
        switch self {
        case .threeLittlePigs:
            return "ThreeLittlePigs"
        case .fairyTale2:
            return ""
        case .fairyTale3:
            return ""
        case .fairyTale4:
            return ""
        }
    }
    
    var fairyTaleTitle: String {
        switch self {
        case .threeLittlePigs:
            return "The Three Little Pigs"
        case .fairyTale2:
            return ""
        case .fairyTale3:
            return ""
        case .fairyTale4:
            return ""
        }
    }
}

