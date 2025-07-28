/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 The class that loads available USDZs and reports loading progress.
 */

import Foundation
import RealityKit

@MainActor
@Observable
final class ModelLoader {
    private var didStartLoading = false
    private(set) var progress: Float = 0.0
    private(set) var placeableToys = [PlaceableToy]()
    private var fileCount: Int = 0
    private var filesLoaded: Int = 0
    
    init(progress: Float? = nil) {
        if let progress {
            self.progress = progress
        }
    }
    
    var didFinishLoading: Bool { progress >= 1.0 }
    
    private func updateProgress() {
        filesLoaded += 1
        if fileCount == 0 {
            progress = 0.0
        } else if filesLoaded == fileCount {
            progress = 1.0
        } else {
            progress = Float(filesLoaded) / Float(fileCount)
        }
    }
    
    func loadToys() async {
        // Only allow one loading operation at any given time.
        guard !didStartLoading else { return }
        didStartLoading.toggle()
        
        // Get a list of all USDZ files in this app’s main bundle and attempt to load them.
        let supportedExtensions = ["usdz", "usdc"]
        var usdzFiles: [String] = []
        
        for ext in supportedExtensions {
            if let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) {
                let names = urls.map { $0.deletingPathExtension().lastPathComponent }
                usdzFiles.append(contentsOf: names)
            }
        }
        
        assert(!usdzFiles.isEmpty, "Add USDZ files to this Xcode project.")
        
        fileCount = usdzFiles.count
        await withTaskGroup(of: Void.self) { group in
            for usdz in usdzFiles {
                group.addTask {
                    await self.loadToy(usdz)
                    await self.updateProgress()
                }
            }
        }
    }
    
    func loadToy(_ fileName: String) async {
        var modelEntity: ModelEntity
        var previewEntity: Entity
        do {
            // Load the USDZ as a ModelEntity.
            try await modelEntity = ModelEntity(named: fileName)
            
            // Load the USDZ as a regular Entity for previews.
            try await previewEntity = Entity(named: fileName)
            previewEntity.name = "Preview of \(modelEntity.name)"
        } catch {
            print("❌ Failed to load model: \(fileName), error: \(error)")
            return
        }
        
        // Set a collision component for the model so the app can detect whether the preview overlaps with existing placed toys.
        do {
            let shape = try await ShapeResource.generateConvex(from: modelEntity.model!.mesh)
            previewEntity.components.set(CollisionComponent(shapes: [shape], isStatic: false,
                                                            filter: CollisionFilter(group: PlaceableToy.previewCollisionGroup, mask: .all)))
            let previewInput = InputTargetComponent(allowedInputTypes: [.indirect])
            previewEntity.components[InputTargetComponent.self] = previewInput
        } catch {
            fatalError("Failed to generate shape resource for model \(fileName)")
        }
        
        let descriptor = ModelDescriptor(fileName: fileName, displayName: modelEntity.displayName)
        placeableToys.append(PlaceableToy(descriptor: descriptor, renderContent: modelEntity, previewEntity: previewEntity))
    }
}

fileprivate extension ModelEntity {
    var displayName: String? {
        !name.isEmpty ? name.replacingOccurrences(of: "_", with: " ") : nil
    }
}
