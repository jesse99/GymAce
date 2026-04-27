import SwiftUI
import SwiftData

@main
struct GymAceApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Program.self,
            WeightSet.self
        ])
        let config = ModelConfiguration("store1", schema: schema, isStoredInMemoryOnly: false)

        do {
            // TODO sounds like we need to explicitly save (this does happen automatically but not very often)
            let container = try ModelContainer(for: schema, configurations: [config])
            
            try container.mainContext.delete(model: Program.self)    // blow away old store
            
            var descriptor = FetchDescriptor<Program>()
            descriptor.fetchLimit = 1
            guard try container.mainContext.fetch(descriptor).count == 0 else {return container}
            
            // If there are currently no programs add an empty one. TODO later use a wizard?
            let program = makePreviewProgram()
//            let program = Program(name: "My")
//            program.active = true
            
            container.mainContext.insert(program)
            try container.mainContext.save()

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
