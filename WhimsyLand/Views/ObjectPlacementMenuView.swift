import SwiftUI

struct ObjectPlacementMenuView: View {
    let mixedImmersiveState: MixedImmersiveState
    let placeableItemStore: PlaceableItemStore

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var presentConfirmationDialog = false

    var body: some View {
        VStack(spacing: 20) {
            ObjectSelectionView(
                modelDescriptors: placeableItemStore.modelDescriptors,
                selectedFileName: placeableItemStore.selectedFileName
            ) { descriptor in
                if let model = placeableItemStore.placeableObjectsByFileName[descriptor.fileName] {
                    mixedImmersiveState.placementManager?.selectObject(model)
                }
            }

            Button("Remove all objects", systemImage: "trash") {
                presentConfirmationDialog = true
            }
            .font(.subheadline)
            .buttonStyle(.borderless)
            .confirmationDialog("Remove all objects?", isPresented: $presentConfirmationDialog) {
                Button("Remove all", role: .destructive) {
                    Task {
                        await mixedImmersiveState.placementManager?.removeAllPlacedObjects()
                    }
                }
            }

            Button("Leave", systemImage: "xmark.circle") {
                Task {
                    await dismissImmersiveSpace()
                    mixedImmersiveState.didLeaveMixedImmersiveSpace()
                }
            }
            .font(.subheadline)
            .buttonStyle(.borderless)
        }
    }
}
