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
    case timing(Date, Int)
        
    /// The user has finished all of the sets.
    case finished
}

/// Results of a in progress exercise. Once the exercise is completed this will be converted to
/// a Completed value and appended onto the exercise history.
struct Working: Codable {
    var sets: [CompletedSet]
    var expected: [Int]     // only used for variable reps
    var weight: Float?
    var units: Units
    var started: Date
    
    /// Returns true if the exercise was started long enough ago that it should be considered an exercise
    /// that the user has abandoned.
    var isStale: Bool {
        let delta = started.distance(to: Date.now)
        return delta/3600.0 > 4.0   // aka more than 4 hours
    }
    
    init(weight: Float?, units: Units) {
        self.sets = []
        self.expected = []
        self.weight = weight
        self.units = units
        self.started = Date()
    }
    
    /// Used to show the user what happened for that workout.
    func details() -> String {
        return completedDetails(sets, weight, units)
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
        
    /// Returns true if the user is on a workset with an expected rep that may be changed to an actual rep.
    func hasExpected(_ exercise: Exercise) -> Bool {
        if case let .reps(d) = exercise.data {
            if d.isVariable, !finished(exercise) {
                var index = fixedIndex(exercise)
                index -= d.warmups.count
                if index >= 0 && index < d.worksets.count {
                    let min = d.worksets[index].min
                    let max = d.worksets[index].max
                    return min < max
                }
            }
        }
        return false
    }

    /// The reps that the user is expected to do, only used when the number of reps is variable.
    func expectedReps(_ exercise: Exercise) -> Int {
        if case let .reps(d) = exercise.data {
            var index = fixedIndex(exercise)
            index -= d.warmups.count
            if let w = self.working, index >= 0 && index < w.expected.count {
                return w.expected[index]
            }
        }
        return 0
    }
    
    func setActualReps(_ exercise: Exercise, _ actual: Int) {
        if case let .reps(d) = exercise.data {
            var index = fixedIndex(exercise)
            index -= d.warmups.count
            working!.expected[index] = actual
        }
    }
    
    func maxEpectedReps(_ exercise: Exercise) -> Int {
        if case let .reps(d) = exercise.data {
            var index = fixedIndex(exercise)
            index -= d.warmups.count
            return d.worksets[index].max
        }
        return 0
    }
    
    func rest(_ workout: Workout, _ exercise: Exercise) -> Int? {
        switch exercise.data {
        case .durations(let d):
            if setIndex >= 0 && setIndex < d.secs.count {
                return d.secs[setIndex]
            }
        case .percent(let d):
            var index = fixedIndex(exercise)
            index -= d.warmups.count
            if index >= 0 && index < d.worksets.count {
                // Don't rest for the last set and last execise in a workout.
                if let last = workout.entries.last, last.name == exercise.name, index == d.worksets.count - 1 {
                    return nil
                }
                return d.rest
            }
            return nil
        case .reps(let d):
            var index = fixedIndex(exercise)
            index -= d.warmups.count
            if index >= 0 && index < d.worksets.count {
                if let last = workout.entries.last, last.name == exercise.name, index == d.worksets.count - 1 {
                    return nil
                }
                return d.rest
            }

            index -= d.worksets.count
            if index >= 0 && index < d.backoff.count {
                if let last = workout.entries.last, last.name == exercise.name, index == d.backoff.count - 1 {
                    return nil
                }
                return d.rest
            }
        }
        return nil
    }
    
    /// Called when the user starts an exercise. Resets setIndex and working if needed.
    func started(_ model: Model, _ program: Program, _ exercise: Exercise) {
        if let w = self.working {
            if w.isStale {
                reset(model, program, exercise)
            }
        } else {
            reset(model, program, exercise)
        }
    }

    /// Start the exercise all over (or for the first time).
    func reset(_ model: Model, _ program: Program, _ exercise: Exercise) {
        setIndex = 0
        if let w = exercise.findWeight(program) {
            if let wn = exercise.weightSet, let ws = model.weightSets[wn] {
                let weight = ws.lower(target: w)
                working = Working(weight: weight.value(), units: ws.units)
            } else {
                working = Working(weight: w, units: .None)
            }
        } else {
            working = Working(weight: nil, units: .None)
        }
        
        switch exercise.data {
        case .reps(let d):
            if d.isVariable {
                for (index, reps) in d.worksets.enumerated() {
                    let r = findExpected(exercise, reps, index)
                    working!.expected.append(r)
                }
            } else {
                for reps in d.worksets {
                    working!.expected.append(reps.min)
                }
            }
        case .durations(let d):
            for s in d.secs {
                working!.expected.append(s)
            }
        case .percent(let d):
            for reps in d.worksets {
                working!.expected.append(reps)
            }
        }
                
        mode = .performing
    }
    
    /// Called after each set is completed.
    func completedSet(_ exercise: Exercise) {
        switch exercise.data {
        case .reps(let d):
            var index = fixedIndex(exercise)
            index -= d.warmups.count
            if index >= 0 && index < working!.expected.count {
                let actual = working!.expected[index]
                working!.sets.append(.reps(actual))
            }
        case .durations(let d):
            if setIndex >= 0 && setIndex < d.secs.count {
                working!.sets.append(.duration(d.secs[setIndex]))
            }
        case .percent(let d):
            var index = fixedIndex(exercise)
            index -= d.warmups.count
            if index >= 0 && index < working!.expected.count {
                let actual = working!.expected[index]
                working!.sets.append(.reps(actual))
            }
        }
        setIndex += 1
    }
    
    /// Called when the user completes an exercise. Adds current to Exercise.history and then resets
    /// current.
    func completedAll(_ exercise: Exercise) {
        if let w = self.working {
            let c = Completed(sets: w.sets, weight: w.weight, units: w.units)
            exercise.history.append(c)
        }
        setIndex = 0
        working = nil
    }
    
    func finished(_ exercise: Exercise) -> Bool {
        switch exercise.data {
            case .durations(let d): return setIndex >= d.secs.count
            case .reps(let d): return setIndex >= d.warmups.count + d.worksets.count + d.backoff.count
            case .percent(let d): return setIndex >= d.warmups.count + d.worksets.count
        }
    }
    
    // Shown first in the exercise view, e.g. "Workset 1 of 3" or "Set 1 of 3".
    func headline(_ exercise: Exercise) -> String {
        if finished(exercise) {
            return "Done"
        }
        var index = fixedIndex(exercise)
        switch exercise.data {
            case .durations(let d):
                return "Set \(index + 1) of \(d.secs.count)"
            case .reps(let d):
                if index < d.warmups.count {
                    return "Warmup \(index + 1) of \(d.warmups.count)"
                }
                
                index -= d.warmups.count
                if index < d.worksets.count {
                    return "Workset \(index + 1) of \(d.worksets.count)"
                }
                
                index -= d.worksets.count
                if index < d.backoff.count {
                    return "Backoff \(index + 1) of \(d.backoff.count)"
                }
            case .percent(let d):
                if index < d.warmups.count {
                    return "Warmup \(index + 1) of \(d.warmups.count)"
                }
                
                index -= d.warmups.count
                if index < d.worksets.count {
                    return "Workset \(index + 1) of \(d.worksets.count)"
                }
        }
        return ""
    }
    
    // Shown second in the exercise view, e.g. "5 reps @ 140 lbs" or "30s".
    func subhead(_ model: Model, _ program: Program, _ exercise: Exercise) -> String {
        var suffix = ""
        if let actual = actualWeight(model, program) {
            suffix = "\(actual.text())"
        }
        
        if finished(exercise) {
            if suffix.isEmpty {
                return ""
            }
            return "\(suffix) next"
        }
        if !suffix.isEmpty {
            suffix = " @ \(suffix)"
        }

        let index = fixedIndex(exercise)
        switch exercise.data {
            case .durations(let d):
                return secsToStr(d.secs[index]) + suffix
            case .reps(let d):
                var index = index
                if index < d.warmups.count {
                    return "\(d.warmups[index].reps) reps" + suffix
                }
                
                index -= d.warmups.count
                if index < d.worksets.count {
                    var minReps = self.expectedReps(exercise)
                    if minReps == 0 {
                        minReps = d.worksets[index].min
                    }
                    if minReps == d.worksets[index].max {
                        return "\(minReps) reps" + suffix
                    } else {
                        return "\(minReps)-\(d.worksets[index].max) reps" + suffix
                    }
                }
                
                index -= d.worksets.count
                if index < d.backoff.count {
                    return "\(d.backoff[index].reps) reps" + suffix
                }
            case .percent(let d):
                var index = index
                if index < d.warmups.count {
                    return "\(d.warmups[index].reps) reps" + suffix
                }
                
                index -= d.warmups.count
                if index < d.worksets.count {
                    return "\(d.worksets[index]) reps" + suffix
                }
        }
        return ""
    }
    
    // Shown third in the exercise view, e.g. "45 + 2.5".
    func footer(_ model: Model, _ program: Program, _ exercise: Exercise) -> String? {
        if finished(exercise) {
            return ""
        }
        if let actual = actualWeight(model, program) {
            return actual.details()
        }
        return nil
    }
    
    // Shown fourth in the exercise view, e.g. "90% of 225 lbs".
    func subfooter(_ model: Model, _ program: Program, _ exercise: Exercise) -> String? {
        if finished(exercise) {
            return ""
        }
        switch exercise.data {
        case .reps(let d):
            if let exercise = program.findExercise(name), let weight = exercise.findWeight(program) {
                var weightStr: String
                if let wn = exercise.weightSet, let ws = model.weightSets[wn] {
                    weightStr = formatWeight(weight, ws.units)
                } else {
                    weightStr = formatWeight(weight, .None)
                }
                
                var index = fixedIndex(exercise)
                if index < d.warmups.count {
                    return "\(d.warmups[index].percent)% of \(weightStr)"
                }
                
                index -= d.warmups.count
                if index < d.worksets.count {
                    return nil
                }
                
                index -= d.worksets.count
                if index < d.backoff.count {
                    return "\(d.backoff[index].percent)% of \(weightStr)"
                }
            }
        case .durations(_):
            break
        case .percent(let d):
            if let thisExercise = program.findExercise(name), let bweight = findBaseWeight(program) {
                switch bweight {
                case .success(let weight):
                    var weightStr: String
                    if let wn = thisExercise.weightSet, let ws = model.weightSets[wn] {
                        weightStr = formatWeight(weight, ws.units)
                    } else {
                        weightStr = formatWeight(weight, .None)
                    }
                    
                    var index = fixedIndex(exercise)
                    if index < d.warmups.count {
                        let p = Int(Float(d.percent) * Float(d.warmups[index].percent) / 100.0)
                        return "\(p)% of \(weightStr)"
                    }

                    index -= d.warmups.count
                    if index < d.worksets.count {
                        return "\(d.percent)% of \(weightStr)"
                    }
                case .failure(let mesg):
                    return mesg.err
                }
            }
        }
        return nil
    }
    
    func history(_ exercise: Exercise) -> HistorySnapshot {
        return HistorySnapshot(entry: self, exercise: exercise)
    }

    private func actualWeight(_ model: Model, _ program: Program) -> ActualWeight? {
        if let exercise = program.findExercise(name), let bweight = findBaseWeight(program), case .success(let weight) = bweight {
            if let wn = exercise.weightSet, let ws = model.weightSets[wn] {
                switch exercise.data {
                    case .durations(_):
                        return ws.lower(target: weight)
                    case .reps(let d):
                        var index = fixedIndex(exercise)
                        if index < d.warmups.count {
                            let p = Float(d.warmups[index].percent) / 100.0
                            return ws.closest(target: p*weight)
                        }
                        
                        index -= d.warmups.count
                        if index < d.worksets.count {
                            return ws.lower(target: weight)
                        }
                        
                        index -= d.worksets.count
                        if index < d.backoff.count {
                            let p = Float(d.backoff[index].percent) / 100.0
                            return ws.closest(target: p*weight)
                        }
                    case .percent(let d):
                        var index = fixedIndex(exercise)
                        if index < d.warmups.count {
                            let p = Float(d.percent) / 100.0
                            let q = Float(d.warmups[index].percent) / 100.0
                            return ws.closest(target: p*q*weight)
                        }
                        
                        index -= d.warmups.count
                        if index < d.worksets.count {
                            let p = Float(d.percent) / 100.0
                            return ws.lower(target: p*weight)
                        }
                }
            }
            return ActualWeight(discrete: weight, .None)
        }
        return nil
    }
    
    private func findBaseWeight(_ program: Program) -> Result<Float, MyError>? {
        if let thisExercise = program.findExercise(name) {
            switch thisExercise.data {
            case .durations(_), .reps(_):
                if let w = thisExercise.weight {
                    return .success(w)
                }
            case .percent(let d):
                if let otherExercise = program.findExercise(d.other) {
                    if let last = otherExercise.history.last {
                        if let weight = last.weight {
                            return .success(weight)
                        }
                    }
                    if let w = otherExercise.weight {
                        return .success(w)
                    }
                } else {
                    let e = MyError(err: "Couldn't find \(d.other) exercise.")
                    return .failure(e)
                }
            }
        }
        return nil
    }
    
    private func fixedIndex(_ exercise: Exercise) -> Int {
        switch exercise.data {
            case .durations(let d):
                return setIndex >= d.secs.count ? d.secs.count - 1 : setIndex
            case .reps(let d):
                let count = d.warmups.count + d.worksets.count + d.backoff.count
                return setIndex >= count ? count - 1 : setIndex
            case .percent(let d):
                let count = d.warmups.count + d.worksets.count
                return setIndex >= count ? count - 1 : setIndex
        }
    }
}

struct Snapshot {
    let current: Completed
    let prior: Completed?
    let finished: Bool
    let index: Int          // for ForEach
}

struct HistorySnapshot: RandomAccessCollection {
    let entry: ExerciseEntry
    let exercise: Exercise
    let maxItems = 20
    
    var startIndex: Int {0}
    var endIndex: Int {Swift.min(exercise.history.endIndex, maxItems) + (entry.working != nil ? 1 : 0)}
    
    subscript(position: Int) -> Snapshot {
        var index = position
        if let w = entry.working {
            if index == 0 {
                let c = Completed(sets: w.sets, weight: w.weight, units: w.units)
                return Snapshot(current: c, prior: nil, finished: false, index: index)  // nil prior since we can't compare the two yet
            }
        } else {
            index += 1
        }
        
        let i = exercise.history.count - index
        return Snapshot(current: exercise.history[i], prior: previous(index), finished: true, index: position)
    }
    
    private func previous(_ position: Int) -> Completed! {
        let i = exercise.history.count - position - 1
        if i >= 0 && i < exercise.history.count {
            return exercise.history[i]
        } else {
            return nil
        }
    }
}

func findExpected(_ exercise: Exercise, _ reps: VariableReps, _ index: Int) -> Int {
    // Usually we'll just return reps.min except for a few cases:
    if let last = exercise.latestCompleted() {
        if let new = exercise.weight, let old = last.weight {
            if new < old {
                // 1) the user has dropped the weight
                // Possible that they can't now do max, but they should be close to that...
                return reps.max
            } else if new == old {
                // 2) the user is doing the same weight so the expected is whatever
                // they last did clamped to what the current min/max is.
                if index < last.sets.count {
                    switch last.sets[index] {
                    case .reps(let n): return reps.clamp(n)
                    default: return reps.min
                    }
                }
            }
        }
    }
    return reps.min
}
