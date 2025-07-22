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

enum ToyModule: String, Identifiable, CaseIterable, Equatable {
    case ragHouse, treeHouse, brickHouse
    var id: String { rawValue.capitalized }
    var name: String {
        switch self {
        case .ragHouse: return "첫째 돼지의 집"
        case .treeHouse: return "둘째 돼지의 집"
        case .brickHouse: return "셋째 돼지의 집"
        }
    }
    var overview: String {
        switch self {
        case .ragHouse: return "바람에 쉽게 날아가는 가장 약한 구조의 집"
        case .treeHouse: return ""
        case .brickHouse: return ""
        }
    }
    var owner: String {
        switch self {
        case .ragHouse: return "첫째 돼지"
        case .treeHouse: return "둘째 돼지"
        case .brickHouse: return "셋째 돼지"
        }
    }
    var material: String {
        switch self {
        case .ragHouse: return "지푸라기"
        case .treeHouse: return "나무"
        case .brickHouse: return "벽돌"
        }
    }
    var description: String {
        switch self {
        case .ragHouse: return "첫째 돼지는 일을 빨리 끝내고 놀고 싶어 지푸라기로 급하게 집을 지었어요. 하지만 늑대가 불자마자 집은 날아가 버리고 말았죠."
        case .treeHouse: return ""
        case .brickHouse: return ""
        }
    }
    var callToAction: String {
        switch self {
        case .ragHouse: return "첫째 돼지 집에서 아기 돼지 삼형제의 이야기를 들어보세요."
        case .treeHouse: return ""
        case .brickHouse: return ""
        }
    }
    var toy3D: String {
        switch self {
        case .ragHouse: return "RagHouse"
        case .treeHouse: return "TreeHouse"
        case .brickHouse: return "BrickHouse"
        }
    }
}
