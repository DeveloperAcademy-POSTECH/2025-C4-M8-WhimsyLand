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
    case RagHouse, TreeHouse, BrickHouse, Fence1, Fence2, Tree1, Tree2, Tree3
    var id: String { rawValue.capitalized }
    var name: String {
        switch self {
        case .RagHouse: return "첫째 돼지의 집"
        case .TreeHouse: return "둘째 돼지의 집"
        case .BrickHouse: return "셋째 돼지의 집"
        case .Fence1: return "울타리 1"
        case .Fence2: return "울타리 2"
        case .Tree1: return "나무 1"
        case .Tree2: return "나무 2"
        case .Tree3: return "나무 3"
        }
    }
    var overview: String {
        switch self {
        case .RagHouse: return "바람에 쉽게 날아가는 가장 약한 구조의 집"
        case .TreeHouse: return "바람에 날아가지 않지만 불에 약한 집"
        case .BrickHouse: return "바람과 불에 강한 튼튼한 집"
        case .Fence1: return "기본 울타리"
        case .Fence2: return "나름 튼튼한 울타리"
        case .Tree1: return "얇은 형태의 나무"
        case .Tree2: return "중간 크기의 나무"
        case .Tree3: return "풍성한 나무"
        }
    }
    var owner: String {
        switch self {
        case .RagHouse: return "첫째 돼지"
        case .TreeHouse: return "둘째 돼지"
        case .BrickHouse: return "셋째 돼지"
        case .Fence1: return "기본 울타리"
        case .Fence2: return "나름 튼튼한 울타리"
        case .Tree1: return "얇은 형태의 나무"
        case .Tree2: return "중간 크기의 나무"
        case .Tree3: return "풍성한 나무"
        }
    }
    var material: String {
            switch self {
            case .RagHouse: return "지푸라기"
            case .TreeHouse: return "나무"
            case .BrickHouse: return "벽돌"
            case .Fence1: return "기본 울타리"
            case .Fence2: return "나름 튼튼한 울타리"
            case .Tree1: return "얇은 형태의 나무"
            case .Tree2: return "중간 크기의 나무"
            case .Tree3: return "풍성한 나무"
            }
        }
        var description: String {
            switch self {
            case .RagHouse: return "첫째 돼지는 일을 빨리 끝내고 놀고 싶어 지푸라기로 급하게 집을 지었어요. 하지만 늑대가 불자마자 집은 날아가 버리고 말았죠."
            case .TreeHouse: return "둘째 돼지는 일을 잘 안 하잖아요. 그래서 나무로 집을 지었어요. 하지만 늑대가 불을 질러 다 타버리고 말았죠"
            case .BrickHouse: return "셋째 돼지는 근면 성실하여 오랜기간동안 튼튼한 벽돌 집을 지었어요 늑대가 과연 어떻게 할까요?"
            case .Fence1: return "2중 구조의 가장 기본인 되는 울타리"
            case .Fence2: return "3중 구조의 튼튼한 울타리"
            case .Tree1: return "금방 부러질것 같은 양상한 나무"
            case .Tree2: return "어느정도 단단해 보이는 나무"
            case .Tree3: return "크기도 굵기도 튼튼해 보이는 나무"
            }
        }
        var callToAction: String {
            switch self {
            case .RagHouse: return "첫째 돼지 집에서 아기 돼지 삼형제의 이야기를 들어보세요."
            case .TreeHouse: return "둘째 돼지 집에서 내부를 구경해보세요"
            case .BrickHouse: return "셋째 돼지 집에서 소품을 만져보세요"
            case .Fence1: return "원하는 공간에 기본 울타리를 배치해보세요"
            case .Fence2: return "원하는 공간에 나름 튼튼한 울타리를 배치해보세요"
            case .Tree1: return "어디에나 잘어울리는 작은 나무 배치해보세요"
            case .Tree2: return "어디에나 잘어울리는 중간 크기 나무 배치해보세요"
            case .Tree3: return "중심에 되는 풍성한 나무를 배치해보세요"
            }
        }
    }

