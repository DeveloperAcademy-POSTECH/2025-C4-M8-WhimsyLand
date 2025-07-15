/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that describes the current app state.
*/

import SwiftUI

struct InfoLabel: View {
    let appState: AppState
    
    var body: some View {
        Text(infoMessage)
            .font(.subheadline)
            .multilineTextAlignment(.center)
    }

    var infoMessage: String {
        if !appState.allRequiredProvidersAreSupported {
            return "This app requires functionality that isn’t supported in Simulator."
        } else if !appState.allRequiredAuthorizationsAreGranted {
            return "This app is missing necessary authorizations. You can change this in Settings > Privacy & Security."
        } else {
            return "Place and move 3D models in your physical environment. The system maintains their placement across app launches."
        }
    }
}
