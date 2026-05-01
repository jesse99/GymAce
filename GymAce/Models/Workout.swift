import Foundation
import SwiftData

/// List of exercises to be performed on a particular day.
@Model
final class Workout {   // TODO may want to use CustomReflectable for some of the more complex Model types
    // TODO support enabled/disabled
    // TODO add completed
    var name: String
    
    var schedule: Schedule
    
    // TODO SwiftData won't preserve the ordering here: do we need to manage sorting ourself?
    var exercises: [Exercise] = []
    
    init(_ name: String, _ schedule: Schedule) {
        self.name = name
        self.schedule = schedule
    }

    func addDurations(name: String, formalName: String, secs: [Int]) {
        let durations = DurationsData(secs: secs, targetSecs: nil)
        let exercise = Exercise(name: name, formalName: formalName, order: exercises.count, durations: durations)
        exercises.append(exercise)
    }

    func addReps(name: String, formalName: String, worksets: [Int]) {
        let reps = RepsData(warmups: [], worksets: worksets.map {VariableReps(min: $0, max: $0)}, backoff: [])
        let exercise = Exercise(name: name, formalName: formalName, order: exercises.count, reps: reps)
        exercises.append(exercise)
    }
}
