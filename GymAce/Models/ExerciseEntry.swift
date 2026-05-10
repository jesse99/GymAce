import Foundation

/// Used to maintain the transient state associated with an exercise in a workout.
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
    var current: Completed? = nil

    var enabled: Bool = true    // TODO support this
    
    var version: Int = 1

    init (name: String) {
        self.name = name
        self.setIndex = 0
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

    /// The reps that the user is expected to do. only used when the number of reps is variable.
    func expectedReps(_ exercise: Exercise) -> Int {
        if case let .reps(d) = exercise.data {
            var index = fixedIndex(exercise)
            index -= d.warmups.count
            if index >= 0 && index < current!.sets.count {
                switch current!.sets[index] {
                case .reps(let n): return n
                default: return 0
                }
            }
        }
        return 0
    }
    
    func setActualReps(_ exercise: Exercise, _ actual: Int) {
        if case let .reps(d) = exercise.data {
            var index = fixedIndex(exercise)
            index -= d.warmups.count
            current!.sets[index] = .reps(actual)
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
    
    func rest(_ exercise: Exercise) -> Int? {
        switch exercise.data {
        case .durations(let d):
            if setIndex >= 0 && setIndex < d.secs.count {
                return d.secs[setIndex]
            }
        case .percent(let d):
            return d.rest
        case .reps(let d):
            var index = fixedIndex(exercise)
            index -= d.warmups.count
            if index >= 0 && index < d.worksets.count {
                return d.rest    // TODO should return nil for the last set of the last exercise in a workout
            }
        }
        return nil
    }
    
    /// Called when the user starts an exercise. Resets setIndex and current if needed.
    func started(_ program: Program, _ exercise: Exercise) {
        if let c = self.current {
            if c.isStale {
                reset(program, exercise)
            }
        } else {
            reset(program, exercise)
        }
    }

    /// Start the exercise all over (or for the first time).
    func reset(_ program: Program, _ exercise: Exercise) {
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
        
        setIndex = 0
        current = Completed(weight: exercise.findWeight(program))
        
        // Pre-populate sets with whatever the user is expected to do. For reps, at
        // least, we'll normally give the user a chance to over-write this with how
        // much they actually did.
        switch exercise.data {
        case .durations(let d):
            for s in d.secs {
                current!.sets.append(.duration(s))
            }
        case .reps(let d):
            for (index, reps) in d.worksets.enumerated() {
                let r = findExpected(exercise, reps, index)
                current!.sets.append(.reps(r))
            }
        case .percent(let d):
            for reps in d.worksets {
                current!.sets.append(.reps(reps))
            }
        }
    }
    
    /// Called after each set is completed.
    func completedSet() {
        setIndex += 1
    }
    
    /// Called when the user completes an exercise. Adds current to Exercise.history and then resets
    /// current.
    func completedAll(_ exercise: Exercise) {
        if var c = current {
            c.completed = Date()
            exercise.history.append(c)
        }
        setIndex = 0
        current = nil
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
            case .percent(_):
                return "Set \(index + 1)?"
        }
        return ""
    }
    
    // Shown second in the exercise view, e.g. "5 reps @ 140 lbs" or "30s".
    func subhead(_ model: Model, _ program: Program, _ exercise: Exercise) -> String {
        var suffix = ""
        if let actual = actualWeight(model, program) {
            suffix = " @ \(actual.text())"
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
                    if d.worksets[index].min == d.worksets[index].max {
                        return "\(d.worksets[index].min) reps" + suffix
                    } else {
                        return "\(d.worksets[index].min)-\(d.worksets[index].max) reps" + suffix
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
    func footer(_ model: Model, _ program: Program) -> String? {
        if let actual = actualWeight(model, program) {
            return actual.details()
        }
        return nil
    }
    
    // Shown fourth in the exercise view, e.g. "90% of 225 lbs".
    func subfooter(_ model: Model, _ program: Program, _ exercise: Exercise) -> String? {
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
            if let exercise = program.findExercise(name), let weight = exercise.findWeight(program) {
                var weightStr: String
                if let wn = exercise.weightSet, let ws = model.weightSets[wn] {
                    weightStr = formatWeight(weight, ws.units)
                } else {
                    weightStr = formatWeight(weight, .None)
                }
                
                let index = fixedIndex(exercise)
                if index < d.warmups.count {
                    return "\(d.warmups[index].percent)% of \(weightStr)"
                }
            }
        }
        return nil
    }
    
    private func actualWeight(_ model: Model, _ program: Program) -> ActualWeight? {
        if let exercise = program.findExercise(name), let weight = exercise.weight {
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
                            let p = Float(d.warmups[index].percent) / 100.0
                            return ws.closest(target: p*weight)
                        }
                        
                        index -= d.warmups.count
                        if index < d.worksets.count {
                            return ws.lower(target: weight)
                        }
                }
            }
            return ActualWeight(discrete: weight, .None)
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
