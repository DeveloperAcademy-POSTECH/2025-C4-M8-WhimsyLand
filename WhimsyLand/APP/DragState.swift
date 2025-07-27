//
//  DragState.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/10/25.
//
//  드래그 상태 및 위치 관리

import Foundation

struct DragState {
    var draggedToy: PlacedToy
    var initialPosition: SIMD3<Float>
    
    @MainActor
    init(toyToDrag: PlacedToy) {
        draggedToy = toyToDrag
        initialPosition = toyToDrag.position
    }
}

