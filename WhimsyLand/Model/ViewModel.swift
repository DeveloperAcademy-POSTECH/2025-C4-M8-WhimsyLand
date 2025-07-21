//
//  ViewModel.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/9/25.
//

import SwiftUI

/// The data that the app uses to configure its views.
@MainActor
@Observable
class ViewModel {
    // MARK: - immersive
    let immersiveSpaceID = "Object Placement"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    // MARK: - Navigation
    var navigationPath: [Module] = []
    
    // MARK: - threeLittlePigs
    var isShowBrickHouse = false
    
}
