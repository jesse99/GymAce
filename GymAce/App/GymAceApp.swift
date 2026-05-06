import SwiftUI
import SwiftData

@main
struct GymAceApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            Program.self,
            WeightSet.self
        ])
        let config = ModelConfiguration("store1", schema: schema, isStoredInMemoryOnly: false)

        do {
            // TODO sounds like we need to explicitly save (this does happen automatically but not very often)
            let container = try ModelContainer(for: schema, configurations: [config])
            
            try container.mainContext.delete(model: Program.self)    // TODO for now blow away old store
            
            var descriptor = FetchDescriptor<Program>()
            descriptor.fetchLimit = 1
            guard try container.mainContext.fetch(descriptor).count == 0 else {return container}
            
            // If there are currently no programs add an empty one. TODO later use a wizard? or a mostly empty program?
//            for ws in testWeightSets.values {
//                container.mainContext.insert(ws)
//            }
//            for exercise in testExercises.values {
//                container.mainContext.insert(exercise)
//            }
            let program = testProgram
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
