import Foundation
import SwiftData

/// List of exercises to be performed on a particular day.
@Model
final class Workout {
    init(_ name: String, _ schedule: Schedule) {
        self.name = name
        self.schedule = schedule
    }
    
    func addExercise(_ exercise: Exercise) {
        self.exercises.append(exercise)
    }
    
    // TODO support enabled/disabled
    // TODO add completed
    var name: String

    var schedule: Schedule

    // TODO SwiftData won't preserve the ordering here: do we need to manage sorting ourself?
    private var exercises: [Exercise] = []
}
