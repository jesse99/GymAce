import Foundation

/// List of exercises to be performed on a particular day.
@Observable
final class Workout: Codable, Identifiable {   // TODO may want to use CustomReflectable for some of the more complex model types
    var name: String
    
    var schedule: Schedule
    
    /// These are ordered in the order the user (normally) wants to do them.
    var entries: [ExerciseEntry] = []
    
    var enabled: Bool = true    // TODO support this
    
    /// The week of the very first workout in a program is considered to be week 1. Workouts may be
    /// optionally scheduled to happen only during a range of weeks, e.g. weeks 1-6 for regular
    /// workouts and week 7 for a rest workout.
    var weeks: ClosedRange<Int>? = nil
    
    var notes = ""
    
    /// Set when the first exercise in the workout starts.
    var started: Date? = nil
    
    /// Amount of time the user spent doing the exercises in the workout.
    var elapsed: TimeInterval? = nil

    var version: Int = 1

    var id = UUID()

    init(_ name: String, _ schedule: Schedule) {
        self.name = name
        self.schedule = schedule
    }

    func fixup(_ program: Program) {
//        if program.name == "My" {
//            if weeks == nil {
//                if name != "Rest" {
//                    weeks = 1...7
//                } else {
//                    weeks = 8...8
//                }
//            }
//        } else if program.name == "Preview" {
//            if weeks == nil {
//                if name != "Active Rest" {
//                    weeks = 1...3
//                    schedule = Schedule.anyDay
//                } else {
//                    weeks = 4...4
//                }
//            }
//        }
        for e in entries {
            e.fixup()
        }
    }
        
    var isStale: Bool {
        if let s = started {
            let delta = s.distance(to: Date.now)
            return delta/3600.0 > 12.0   // aka more than 12 hours
        } else {
            return true
        }
    }

    func addExercise(name: String) {
        let entry = ExerciseEntry(name: name)
        entries.append(entry)
    }

    func removeExercise(name: String) {
        if let index = entries.firstIndex(where: {name == $0.name}) {
            entries.remove(at: index)
        }
    }
}
