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
    
    /// This is actually a HealthKit HKWorkoutActivityType (but that doesn't support Codable so we use UInt).
    /// If it's nil then HealthKit recording is disabled.
    var type: UInt? = nil
    
    var id = UUID()

    init(_ name: String, _ schedule: Schedule) {
        self.name = name
        self.schedule = schedule
        self.type = 50              // traditionalStrengthTraining
    }

    func fixup(_ program: Program) {
        for e in entries {
            e.fixup()
        }
    }
        
    func valid(_ model: Model, _ program: Program) -> Bool {
        func badWeight(_ plan: ExercisePlan, _ workout: String, _ exercise: Exercise, _ index: Int?) {
            let warmups = plan.sets.filter({if case .warmup = $0.kind {$0.weight != nil} else {false}})
            let workset = plan.sets.filter({if case .workset = $0.kind {$0.weight != nil} else {false}})

            if let index = index {
                print("Warmup \(index) in workout \(workout) for exercise \(exercise.name) with style \(exercise.styleName) doesn't increase weight:")
            } else {
                print("Workset 0 in workout \(workout) for exercise \(exercise.name) with style \(exercise.styleName) doesn't increase weight:")
            }
            for (i, s) in warmups.enumerated() {
                print("   warmup \(i) weight: \(s.weight!.text()) percent: \(s.percent)")
            }
            
            if let s = workset.first {    // note that timed exercises don't have work sets
                print("   workset 0 weight: \(s.weight!.text()) percent: \(s.percent)")
            }
        }
        
        var valid = true
        for name in entries.findDupes(using: {$0.name}) {   // technically OK but shouldn't normally happen
            print("There's already an exercise named \(name) in \(self.name)")
            valid = false
        }
        for entry in entries {
            if let exercise = program.findExercise(entry.name) {
                let plan = ExercisePlan(model, program, self, exercise)
                let warmups = plan.sets.filter({if case .warmup = $0.kind {$0.weight != nil} else {false}})
                let workset = plan.sets.filter({if case .workset = $0.kind {$0.weight != nil} else {false}})
                
                // Warmup weights must increase
                var priorWeight = Float(-1.0)
                for (i, s) in warmups.enumerated() {
                    if s.weight!.value() <= priorWeight {
                        badWeight(plan, name, exercise, i)
                        valid = false
                    }
                    priorWeight = s.weight!.value()
                }
                
                // Last warmup weight must be less than first workset weight
                if let s = workset.first {    // note that timed exercises don't have work sets
                    if s.weight!.value() <= priorWeight {
                        badWeight(plan, name, exercise, nil)
                        valid = false
                    }
                }
            } else {
                print("Couldn't find exercise \(entry.name) from workout \(name)")
                valid = false
            }
            
            // Group must be present
            if let group = entry.group {
                if let groups = program.groups {
                    if groups[group] == nil {
                        print("Exercise \(entry.name) has group \(group) but the program has no group with that name")
                        valid = false
                    }
                } else {
                    print("Exercise \(entry.name) has group \(group) but the program has no groups")
                    valid = false
                }
            }
        }
        return valid
    }

    func dump(_ model: Model, _ program: Program) -> String {
        var result = ""
        result += "   schedule: " + schedule.dump()
        for entry in entries {
            result += entry.dump(model, program)
            result += "\n"
        }
        return result
    }
        
    var isStale: Bool {
        if let s = started {
            let delta = s.distance(to: Date.now)
            return delta/3600.0 > 12.0   // aka more than 12 hours
        } else {
            return true
        }
    }
    
    func allFinished(_ program: Program) -> Bool {
        for entry in entries where entry.enabled {
            if let exercise = program.findExercise(entry.name), !entry.isFinished(program, exercise) {
                return false
            }
        }
        return true
    }

    func addExercise(name: String, enabled: Bool = true) {
        let entry = ExerciseEntry(name: name)
        entry.enabled = enabled
        entries.append(entry)
    }

    func removeExercise(name: String) {
        if let index = entries.firstIndex(where: {name == $0.name}) {
            entries.remove(at: index)
        }
    }
}
