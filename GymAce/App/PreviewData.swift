import Foundation
import SwiftData

// ModelContainer for use by preview views.
class PreviewData {
    static let shared = PreviewData()        // this is the only way to access the PreviewData instance
    let container: ModelContainer
    
    var context: ModelContext {
        container.mainContext
    }
    
    var defaultProgram: Program {
        testProgram
    }
    
    private init() {
        let schema = Schema([
            Program.self,
            WeightSet.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            context.insert(testProgram)
            try context.save()
        } catch {
            fatalError("Could not create ModelContainer: \(error)") // prints to console and exits
        }
    }
}

// ModelContainer for use by preview views that doesn't have any programs.
class NoPreviewData {
    static let shared = NoPreviewData()
    let modelContainer: ModelContainer
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    var defaultProgram: Program {
        testProgram
    }
    
    private init() {
        let schema = Schema([
            Program.self,
            WeightSet.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)") // prints to console and exits
        }
    }
}
