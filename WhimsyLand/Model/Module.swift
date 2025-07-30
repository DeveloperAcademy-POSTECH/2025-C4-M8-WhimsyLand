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
    case FirstHouse, SecondHouse, ThirdHouse,
         Fence1, Fence2,
         Tree1, Tree2, Tree3,
         RedFlower, BlueFlower,
         Firewood,
         Grass, Grass2,
         Pond,
         Stone,
         Ox
    var id: String { rawValue.capitalized }
    var name: String {
        switch self {
        case .FirstHouse: return "첫째 돼지의 집"
        case .SecondHouse: return "둘째 돼지의 집"
        case .ThirdHouse: return "셋째 돼지의 집"
        case .Fence1: return "나무 울타리"
        case .Fence2: return "튼튼 울타리"
        case .Tree1: return "작은 나무"
        case .Tree2: return "풍성 나무"
        case .Tree3: return "튼튼 나무"
        case .RedFlower: return "붉은 백합"
        case .BlueFlower: return "물망초"
        case .Firewood: return "통나무"
        case .Grass: return "솔잎풀"
        case .Grass2: return "넓잎풀"
        case .Pond: return "연못"
        case .Stone: return "돌"
        case .Ox: return "둘째 돼지의 도끼"
        }
    }
    var overview: String {
        switch self {
        case .FirstHouse: return "바람에 쉽게 날아가는 가장 약한 구조의 집"
        case .SecondHouse: return "바람에 날아가지 않지만 불에 약한 집"
        case .ThirdHouse: return "바람과 불에 강한 튼튼한 집"
        case .Fence1: return "가느다란 나뭇가지들을 엮어 만든 울타리"
        case .Fence2: return "통나무를 다듬어 만든 튼튼한 울타리"
        case .Tree1: return "바람에 잘 흔들리는 가늘고 긴 잎의 나무"
        case .Tree2: return "짙은 초록 잎을 가진 나무"
        case .Tree3: return "짧고 두꺼운 가지를 가진 나무"
        case .RedFlower: return "선명한 붉은 꽃잎의 백합꽃"
        case .BlueFlower: return "파란 쌍둥이 꽃이 나란히 피어 있는 귀여운 들꽃"
        case .Firewood: return "둘째 돼지의 오두막집에 사용된 나무"
        case .Grass: return "잎 끝이 뾰족한 풀"
        case .Grass2: return "풍성한 잎으로 공간을 채워주는 풀"
        case .Pond: return "잔잔한 물결의 작은 연못"
        case .Stone: return "자연스럽게 깎인 형태의 회색 돌"
        case .Ox: return "둘째 돼지가 통나무를 자를 때 사용한 손도끼"
        }
    }
    var owner: String {
        switch self {
        case .FirstHouse: return "첫째 돼지"
        case .SecondHouse: return "둘째 돼지"
        case .ThirdHouse: return "셋째 돼지"
        case .Fence1: return "없음"
        case .Fence2: return "없음"
        case .Tree1: return "없음"
        case .Tree2: return "없음"
        case .Tree3: return "없음"
        case .RedFlower: return "없음"
        case .BlueFlower: return "없음"
        case .Firewood: return "없음"
        case .Grass: return "없음"
        case .Grass2: return "없음"
        case .Pond: return "없음"
        case .Stone: return "없음"
        case .Ox: return "둘째 돼지"
        }
    }
    var material: String {
        switch self {
        case .FirstHouse: return "지푸라기"
        case .SecondHouse: return "나무"
        case .ThirdHouse: return "벽돌"
        case .Fence1: return "나뭇가지, 못"
        case .Fence2: return "통나무, 못"
        case .Tree1: return "나무"
        case .Tree2: return "나무"
        case .Tree3: return "나무"
        case .RedFlower: return "꽃"
        case .BlueFlower: return "꽃"
        case .Firewood: return "참나무"
        case .Grass: return "풀"
        case .Grass2: return "풀"
        case .Pond: return "자갈, 물, 연꽃"
        case .Stone: return "돌"
        case .Ox: return "참나무, 도끼날"
        }
    }
    var description: String {
        switch self {
        case .FirstHouse: return "첫째 돼지는 일을 빨리 끝내고 놀고 싶어 지푸라기로 급하게 집을 지었어요. 하지만 늑대가 불자마자 집은 날아가 버리고 말았죠."
        case .SecondHouse: return "둘째 돼지는 일을 잘 안 하잖아요. 그래서 나무로 집을 지었어요. 하지만 늑대가 불을 질러 다 타버리고 말았죠"
        case .ThirdHouse: return "셋째 돼지는 근면 성실하여 오랜기간동안 튼튼한 벽돌 집을 지었어요 늑대가 과연 어떻게 할까요?"
        case .Fence1: return "2중 구조의 가장 기본이 되는 울타리"
        case .Fence2: return "3중 구조의 튼튼한 울타리"
        case .Tree1: return "금방 부러질것 같은 양상한 나무"
        case .Tree2: return "어느정도 단단해 보이는 나무"
        case .Tree3: return "크기도 굵기도 튼튼해 보이는 나무"
        case .RedFlower: return ""
        case .BlueFlower: return ""
        case .Firewood: return ""
        case .Grass: return ""
        case .Grass2: return ""
        case .Pond: return ""
        case .Stone: return ""
        case .Ox: return ""
        }
    }
    var callToAction: String {
        switch self {
        case .FirstHouse: return "첫째 돼지 집에서 아기 돼지 삼형제의 이야기를 들어보세요"
        case .SecondHouse: return "둘째 돼지 집에서 내부를 구경해보세요"
        case .ThirdHouse: return "셋째 돼지 집에서 소품을 만져보세요"
        case .Fence1: return "원하는 공간에 기본 울타리를 배치해보세요"
        case .Fence2: return "원하는 공간에 나름 튼튼한 울타리를 배치해보세요"
        case .Tree1: return "어디에나 잘어울리는 작은 나무 배치해보세요"
        case .Tree2: return "어디에나 잘어울리는 중간 크기 나무 배치해보세요"
        case .Tree3: return "중심에 되는 풍성한 나무를 배치해보세요"
        case .RedFlower: return ""
        case .BlueFlower: return ""
        case .Firewood: return ""
        case .Grass: return ""
        case .Grass2: return ""
        case .Pond: return ""
        case .Stone: return ""
        case .Ox: return ""
        }
    }
}

enum FullInfoCardContent: String, Identifiable, CaseIterable, Equatable {
    case /*RagHouse, TreeHouse, */BrickHouse
    var id: String { rawValue.capitalized }
    var description: String {
        switch self {
//        case .RagHouse: return """
//            지푸라기로 급하게 지은 이 집 안엔
//            늘 놀고 싶어 하는 첫째 돼지의 재미난 동화책이 가득해요.
//            ‘아기돼지 삼형제’ 이야기를 함께 읽어볼까요?
//"""
//        case .TreeHouse: return """
//            둘째 돼지는 조금 더 튼튼하게, 나무로 집을 지었어요.
//            하지만 바람 앞에선 아직 부족했죠.
//            둘째 돼지의 슬픈 사연을 감상해 보세요!
//"""
        case .BrickHouse: return
            """
            셋째 돼지는 늑대의 침입을 대비해 튼튼히 지었어요.
            방 안을 천천히 탐색해보며 즐겨보세요.
            솥에 불을 붙여 늑대를 막을 준비를 해주세요!
"""
        }
    }
    
    var fullImmersiveContent : FullImmersiveContent {
        switch self {
//        case .RagHouse: return .ragHouse
//        case .TreeHouse: return .treeHouse
        case .BrickHouse: return .brickHouse
        }
    }
}
