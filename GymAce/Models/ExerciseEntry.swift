import Foundation

struct MyError: Error {
    let err: String
}

enum Mode: Codable {             // can't name this "State"
    /// The user is currently executing the exercise.
    case performing
    
    /// The timer is running because the exercise has rest. The date is the time rest should end.
    case resting(Date)

    /// The timer is running because the user has manually started a timer. The date is the
    /// time the user started the timer (we may not know how long the timer should run so
    /// we just let it run until the user stops it). The int is 0 if prior state was performing and
    /// 2 for finished.
    case manualTimer(Date, Int)
    
    /// The timer is running because this is a timed exercise.
    case timing
        
    /// The user has finished all of the sets.
    case finished
}

/// Results of a in progress exercise. Once the exercise is completed this will be converted to
/// a Completed value and appended onto the exercise history.
struct Working: Codable {
    var values: [Int]
    var type: ValueType
    var expected: [Int]     // only used for work sets, starts as expected and becomes actual
    var weights: [Float]?
    var units: Units
    var started: Date
    var data: ExerciseData
    
    /// Returns true if the exercise was started long enough ago that it should be considered an exercise
    /// that the user has abandoned.
    var isStale: Bool {
        let delta = started.distance(to: Date.now)
        return delta/3600.0 > 4.0   // aka more than 4 hours
    }
    
    init(_ plan: ExercisePlan, _ exercise: Exercise, _ units: Units) {
        self.expected = []
        for s in plan.sets {
            if case .workset = s.kind {
                switch s.expected {
                case .amrap(let min):
                    self.expected.append(min)
                case .reps(let min, _):
                    self.expected.append(min)
                case .duration:
                    self.expected.append(s.rest ?? 0)
                case .timed:
                    break
                }
            }
        }
        
        self.values = []
        self.weights = if plan.hasWeights() {[]} else {nil}
        self.units = units
        self.started = Date()
        self.data = exercise.data
        switch exercise.data {
        case .oneRepMax, .reps(_), .percent(_):
            self.type = .reps
        case .durations(_), .timed:
            self.type = .secs
        }
    }
    
    func compatible(_ rhs: ExerciseData) -> Bool {
        switch data {
        case .durations(let d1):
            switch rhs {
            case .durations(let d2):
                return d1.secs.count == d2.secs.count
            default:
                return false
            }
        case .oneRepMax:
            switch rhs {
            case .oneRepMax:
                return true
            default:
                return false
            }
        case .percent(let d1):
            switch rhs {
            case .percent(let d2):
                return d1.warmups.count == d2.warmups.count && d1.workset.count == d2.workset.count
            default:
                return false
            }
        case .reps(let d1):
            switch rhs {
            case .reps(let d2):
                return d1.warmups.count == d2.warmups.count && d1.workset.count == d2.workset.count && d1.backoff.count == d2.backoff.count
            default:
                return false
            }
        case .timed:
            switch rhs {
            case .timed:
                return true
            default:
                return false
            }
        }
    }
    
    /// Used to show the user what happened for that workout.
    func details() -> String {
        return completedDetails(values, type, weights, units, nil)
    }
}

/// Used to maintain the state associated with an exercise in a workout. Note that most of
/// this is transient state that is maintained as the user performs the exercise.
@Observable
final class ExerciseEntry: Codable {
    /// The name of the actual exercise.
    var name: String

    /// The set the user is currently performing in an exercise screen (this doesn't
    /// belong to the view because we want the user to be able to go to another
    /// exercise to super set or goto settings without losing their place). Note that
    /// if this is >= the number of sets the user is considered to have finished the
    /// exercise.
    var setIndex: Int
        
    /// Set if the user is currently performing the exercise. Added to Exercise.history if the user finishes the exercise.
    var working: Working? = nil

    var enabled: Bool = true
    
    // This is here instead of ExerciseView so that the user can back up to do things
    // like supersets without losing stuff like timers.
    var mode: Mode = .performing
    
    var version: Int = 1

    init (name: String) {
        self.name = name
        self.setIndex = 0
    }

    func fixup() {
//        if name == "DB OHP" {
//            self.enabled = false
//        }
    }
        
    func isFinished(_ exercise: Exercise) -> Bool {
        return setIndex >= exercise.data.numSets()
    }
    
    /// Returns true if the user is on a workset where the actual rep count should be recorded.
    func canSetActualReps(_ plan: ExercisePlan) -> Bool {
        if setIndex < plan.sets.count, case .workset = plan.sets[setIndex].kind {
            switch plan.sets[setIndex].expected {
            case .amrap:
                return true
            case .duration:
                return false
            case .reps(_, _):
                // fixed reps are a bit of a weird case, but even there the user may have a bad
                // day or may have upped the weight too much and we need a way to indicate that.
                return true
            case .timed:
                return false
            }
        }
        return false
    }

    /// The reps that the user is expected to do. Note that this is only called if canSetActualReps is true.
    func expectedReps(_ plan: ExercisePlan) -> Int {
        if setIndex < plan.sets.count, case .workset = plan.sets[setIndex].kind {
            let numWarmups = plan.sets.count(where: {
                switch $0.kind {
                case .warmup: return true
                    default: return false}})
            return working?.expected[setIndex - numWarmups] ?? 0  // this can be called before ExerciseView onAppear so we need to handle nil working
        }
        return 0
    }
    
    func setActualReps(_ plan: ExercisePlan, _ actual: Int) {
        let numWarmups = plan.sets.count(where: {
            switch $0.kind {
            case .warmup: return true
            default: return false}})
        working!.expected[setIndex - numWarmups] = actual
    }
    
    func maxEpectedHint(_ plan: ExercisePlan) -> Int {
        if setIndex < plan.sets.count {
            switch plan.sets[setIndex].expected {
            case .amrap(min: let min):
                return min+10
            case .duration:
                return 0
            case .reps(min: _, let max):
                return max
            case .timed:
                return 0
            }
        }
        return 0
    }
    
    func rest(_ plan: ExercisePlan) -> Int? {
        if setIndex < plan.sets.count {
            return plan.sets[setIndex].rest
        }
        return nil
    }
    
    /// Called when the user starts an exercise. Resets setIndex and working if needed.
    func started(_ model: Model, _ program: Program, _ workout: Workout, _ exercise: Exercise) {
        if let w = self.working {
            if w.isStale || !w.compatible(exercise.data) {
                reset(model, program, workout, exercise)
                if workout.isStale {
                    workout.started = Date()
                    workout.elapsed = 0.0
                }
            }
        } else {
            reset(model, program, workout, exercise)
            if workout.isStale {
                workout.started = Date()
                workout.elapsed = 0.0
            }
        }
    }

    /// Start the exercise all over (or for the first time).
    func reset(_ model: Model, _ program: Program, _ workout: Workout, _ exercise: Exercise) {
        let plan = ExercisePlan(model, program, workout, exercise)
        let hasWeights: Bool = plan.hasWeights()
        var units: Units = .None
        if hasWeights, let wn = exercise.weightSet, let ws = model.weightSets[wn] {
            units = ws.units
        }
        
        setIndex = 0
        working = Working(plan, exercise, units)
        mode = .performing
    }
    
    /// Called after each set is completed.
    func completedSet(_ plan: ExercisePlan) {
        if setIndex < plan.sets.count, case .workset = plan.sets[setIndex].kind {
            let numWarmups = plan.sets.count(where: {
                switch $0.kind {
                case .warmup: return true
                default: return false}})
            let index = setIndex - numWarmups

            if index < working!.expected.count {
                let actual = working!.expected[index]
                working!.values.append(actual)
            }
            
            if let w = plan.sets[setIndex].weight, w.value() > 0.0 {
                working!.weights!.append(w.value())
            }
        }
        setIndex += 1
    }
    
    /// Called when the user completes an exercise. Adds current to Exercise.history.
    func completedLast(_ workout: Workout, _ exercise: Exercise) {
        if var w = self.working {
            if case .oneRepMax = exercise.data, let weight = w.weights?.last, weight > 0.0, let reps = w.values.last {
                if let orm = compute1RM(weight: weight, reps: reps) {
                    exercise.weight = orm.rounded() // looks a lot nicer if we round and no one cares about a tenth of a pound or kilogram here
                }
            }
            
            if let e = workout.elapsed {
                let elapsed = Date().timeIntervalSince(w.started)
                workout.elapsed = e + elapsed
            }
            
            let c = if case .timed = exercise.data {
                Completed(values: [Int(Date().timeIntervalSince(w.started))], type: w.type, weights: w.weights, units: w.units, distance: healthKit.enabled ? healthKit.distance : nil)
            } else {
                Completed(values: w.values, type: w.type, weights: w.weights, units: w.units)
            }
            exercise.history.append(c)
            w.values = []
            self.working = w
        }
    }
    
    func finishedExercise() {
        setIndex = 0
        working = nil
    }
}

// Headers
extension ExerciseEntry {
    // Shown first in the exercise view, e.g. "Workset 1 of 3" or "Set 1 of 3".
    func headline(_ plan: ExercisePlan) -> String {
        if setIndex >= plan.sets.count {
            return "Done"
        }
        switch plan.sets[setIndex].kind {
        case .warmup(index: let index, count: let count):
            return "Warmup \(index + 1) of \(count)"
        case .workset(index: let index, count: let count):
            return "Workset \(index + 1) of \(count)"
        case .backoff(index: let index, count: let count):
            return "Backoff \(index + 1) of \(count)"
        case .timed:
            return "Set 1 of 1"
        }
    }
    
    // Shown second in the exercise view, e.g. "5 reps @ 140 lbs" or "30s".
    func subhead(_ plan: ExercisePlan, _ model: Model, _ exercise: Exercise) -> String {
        if setIndex >= plan.sets.count {
            // We need to print the weight when the user finishes because they
            // may bump it up or down.
            if let w = exercise.weight {
                if let wn = exercise.weightSet, let ws = model.weightSets[wn] {
                    return ws.lower(target: w).text()
                } else {
                    return formatWeight(w, .None)
                }
            }
            return ""
        }
        let prefix = switch plan.sets[setIndex].expected {
        case .amrap(let min):
            "\(min)+ reps"
        case .reps(min: let min, max: let max):
            if min < max {
                "\(min)-\(max) reps"
            } else if min == 1{
                "1 rep"
            } else {
                "\(min) reps"
            }
        case .duration:
            secsToLongStr(plan.sets[setIndex].rest ?? 0)
        case .timed:
            ""
        }
        
        let suffix = plan.sets[setIndex].weight?.text() ?? ""
        if prefix.isBlankOrEmpty {
            return suffix
        } else if suffix.isBlankOrEmpty {
            return prefix
        } else {
            return "\(prefix) @ \(suffix)"
        }
    }
    
    // Shown third in the exercise view, e.g. "45 + 2.5".
    func footer(_ plan: ExercisePlan) -> String? {
        if setIndex >= plan.sets.count {
            return ""
        }
        if let actual = plan.sets[setIndex].weight, actual.value() > 0.0 {
            return actual.details()
        }
        return nil
    }
    
    // Shown fourth in the exercise view, e.g. "90% of 225 lbs".
    func subfooter(_ plan: ExercisePlan, _ model: Model, _ exercise: Exercise) -> String? {
        if setIndex >= plan.sets.count {
            return nil
        }
        
        if let base = plan.sets[setIndex].baseWeight, base > 0.0, let actual = plan.sets[setIndex].weight {
            let percent = Int(100.0 * actual.value() / base)
            if percent != 100 {
                if let wn = exercise.weightSet, let ws = model.weightSets[wn] {
                    return "\(percent)% of \(formatWeight(base, ws.units))"
                } else {
                    return "\(percent)% of \(formatWeight(base, .None))"
                }
            }
        }
        return nil
    }
}

// If the exercise type changes then it doesn't make sense to use the last completed to figure
// out expected...
func typeMatches(_ completed: Completed, _ exercise: Exercise) -> Bool {
    switch completed.type {
    case .reps:
        switch exercise.data {
        case .oneRepMax, .percent(_), .reps(_): return true
        case .durations(_), .timed: return false
        }
    case .secs:
        switch exercise.data {
        case .oneRepMax, .percent(_), .reps(_): return false
        case .durations(_), .timed: return true
        }
    }
}

// References:
// https://www.nsca.com/contentassets/61d813865e264c6e852cadfe247eae52/nsca_training_load_chart.pdf?srsltid=AfmBOopfqWIOmJzGNEuYohCPYo-13gCVBjb6Nh6t9rKbfprUXsSeY6E6
// https://theathletesphysique.com/wp-content/uploads/2020/08/1RM-500-600-Max-Tables.pdf
func compute1RM(weight: Float, reps: Int) -> Float? {
    //                       0    1    2     3     4     5     6     7     8     9     10    11    12 reps
    let percents: [Float] = [0.0, 1.0, 0.95, 0.93, 0.90, 0.87, 0.85, 0.83, 0.80, 0.77, 0.75, 0.70, 0.67]
    
    if reps >= 1 && reps < percents.count {
        return weight / percents[reps]
    } else {
        return nil
    }
}
