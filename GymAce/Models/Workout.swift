import Foundation

/// List of exercises to be performed on a particular day.
@Observable
final class Workout: Codable, Identifiable {   // TODO may want to use CustomReflectable for some of the more complex model types
    var name: String
    
    var schedule: Schedule
    
    /// These are ordered in the order the user (normally) wants to do them.
    var entries: [ExerciseEntry] = []
    
    var enabled: Bool = true    // TODO support this
    
    var version: Int = 1

    var notes = ""      // TODO support this?

    var id = UUID()

    init(_ name: String, _ schedule: Schedule) {
        self.name = name
        self.schedule = schedule
    }

    func addExercise(name: String) {
        let entry = ExerciseEntry(name: name)
        entries.append(entry)
    }
}
