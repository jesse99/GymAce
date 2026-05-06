import Foundation
import SwiftData

/// List of exercises to be performed on a particular day.
@Model
final class Workout {   // TODO may want to use CustomReflectable for some of the more complex Model types
    var name: String
    
    var schedule: Schedule
    
    var entries: [ExerciseEntry] = []
    
    // TODO support enabled/disabled
    // TODO add completed

    init(_ name: String, _ schedule: Schedule) {
        self.name = name
        self.schedule = schedule
    }

    func addExercise(exercise: Exercise) {
        let entry = ExerciseEntry(exercise: exercise, order: entries.count)
        entries.append(entry)
    }
}
