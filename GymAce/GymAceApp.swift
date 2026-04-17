import SwiftUI
import SwiftData

@main
struct GymAceApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Program.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            // TODO sounds like we need to explicitly save (this does happen automatically but not very often)
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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
