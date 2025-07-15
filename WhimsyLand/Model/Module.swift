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

enum ObjectModule: String, Identifiable, CaseIterable, Equatable {
    case strawHouse, stickHouse, brickHouse
    var id: Self { self }
    var name: String { rawValue.capitalized }

    var heading: String {
        switch self {
        case .strawHouse:
            String(localized: "초가집", comment: "첫째 돼지의 초가집")
        case .stickHouse:
            String(localized: "나무집", comment: "둘째 돼지의 나무집")
        case .brickHouse:
            String(localized: "벽돌집", comment: "셋째 돼지의 튼튼한 벽돌집")
        }
    }

    var abstract: String {
        switch self {
        case .strawHouse:
            String(localized: "첫째 아기돼지는 지푸라기로 된 집을 지었어요", comment: "Detail text explaining the Planet Earth module.")
        case .stickHouse:
            String(localized: "둘째 아기돼지는 나무로 된 집을 지었어요. 집이 예뻐요. 돼지는 집이 아주 맘에 들어요", comment: "Detail text explaining the Objects in Orbit module.")
        case .brickHouse:
            String(localized: "셋째 아기돼지는 벽돌로 된 집을 지었어요. 돼지는 기뻤어요.", comment: "Detail text explaining the Solar System module.")
        }
    }
}
