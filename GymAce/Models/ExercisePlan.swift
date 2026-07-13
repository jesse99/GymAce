import Foundation

/// This is a version of Exercise and ExerciseData that:
/// 1) Has been flattened into one array.
/// 2) Uses the latest completed to figure out expected reps.
/// 3) Applies set percentages to weights.
/// 4) Uses weight sets to figure out the actual weights.
final class ExercisePlan {
    let sets: [PlanSet]
    
    // Note that we don't cache this because
    // 1) It's fast to compute.
    // 2) That avoids issues with stale caches if users do things like edit the exercise while it's underway.
    init(_ model: Model, _ program: Program, _ workout: Workout, _ exercise: Exercise) {
        var sets : [PlanSet] = []
        
        switch exercise.data {
        case .durations(let d):
            for (i, s) in d.secs.enumerated() {
                sets.append(PlanSet(model, program, exercise, secs: s, index: i, count: d.secs.count))
            }
        case .oneRepMax(let d):
            for (i, s) in d.warmups.enumerated() {
                let kind = PlanSet.Kind.warmup(index: i, count: d.warmups.count)
                sets.append(PlanSet(model, program, exercise, kind: kind, fixed: s, rest: nil))
            }
            let s = VariableReps.variable(1, 12)
            sets.append(PlanSet(model, program, exercise, variable: s, index: 0, count: 1, rest: nil))
        case .percent(let d):
            for (i, s) in d.warmups.enumerated() {
                let kind = PlanSet.Kind.warmup(index: i, count: d.warmups.count)
                sets.append(PlanSet(model, program, exercise, kind: kind, fixed: s, rest: nil))
            }
            for (i, s) in d.workset.enumerated() {
                // Don't rest for the last set and last execise in a workout.
                let rest: Int? = if let last = workout.entries.last, last.name == exercise.name, i == d.workset.count - 1 {
                    nil
                } else {
                    d.rest
                }
                sets.append(PlanSet(model, program, exercise, variable: s, index: i, count: d.workset.count, rest: rest))
            }
        case .reps(let d):
            for (i, s) in d.warmups.enumerated() {
                let kind = PlanSet.Kind.warmup(index: i, count: d.warmups.count)
                sets.append(PlanSet(model, program, exercise, kind: kind, fixed: s, rest: nil))
            }
            for (i, s) in d.workset.enumerated() {
                let rest: Int? = if let last = workout.entries.last, last.name == exercise.name, i == d.workset.count - 1, d.backoff.isEmpty {
                    nil
                } else {
                    d.rest
                }
                sets.append(PlanSet(model, program, exercise, variable: s, index: i, count: d.workset.count, rest: rest))
            }
            for (i, s) in d.backoff.enumerated() {
                let kind = PlanSet.Kind.backoff(index: i, count: d.backoff.count)
                let rest: Int? = if let last = workout.entries.last, last.name == exercise.name, i == d.backoff.count - 1 {
                    nil
                } else {
                    d.rest
                }
                sets.append(PlanSet(model, program, exercise, kind: kind, fixed: s, rest: rest))
            }
        case .timed:
            sets.append(PlanSet(model, program, exercise, timed: true))
        }
        self.sets = sets
    }
    
    func hasWeights() -> Bool {
        for s in sets {
            if case .workset = s.kind {
                if let a = s.weight, a.value() > 0.0 {
                    return true
                }
            }
        }
        
        return false
    }

    /// Shown in WorkoutView next to the exercise name: brief summary of what the user is expected to do.
    /// For example, "30sx3" or "8-12x3 @ 135 lbs".
    func details(_ exercise: Exercise) -> String {
        var amounts: [String] = []
        var weights: [ActualWeight] = []
        for s in sets {
            switch s.kind {
            case .workset, .timed:
                switch s.expected {
                case .amrap(let min):
                    amounts.append("\(min)+")
                case .reps(let min, let max):
                    if min == max {
                        if min == 1 {
                            amounts.append("1")
                        } else {
                            amounts.append("\(min)")
                        }
                    } else {
                        amounts.append("\(min)-\(max)")
                    }
                case .duration:
                    amounts.append(secsToShortStr(s.rest ?? 0))
                case .timed:
                    if let c = exercise.history.last {
                        amounts.append(c.details())
                    }
                }
                
                if let a = s.weight {
                    weights.append(a)
                }
            default:
                break
            }
        }

        if let min = weights.min(by: {$0.value() < $1.value()}), min.value() > 0.0 {
            if let max = weights.max(by: {$0.value() < $1.value()}) {
                if min.value() < max.value() {
                    return "\(joinLabels(amounts)) @ \(min.text())-\(max.text())"
                }
            }
            return "\(joinLabels(amounts)) @ \(min.text())"
        }
        return joinLabels(amounts)
    }
}

struct PlanSet {
    enum Kind {
        case warmup(index: Int, count: Int)
        case workset(index: Int, count: Int)
        case backoff(index: Int, count: Int)
        case timed
    }

    enum Amount {
        case amrap(min: Int)
        case reps(min: Int, max: Int)
        case duration       // the secs here are bundled into rest
        case timed
    }
    
    /// Warmup, workset, etc.
    let kind: Kind
    
    /// What we expect the user to do. This is typically the min of what the exercise calls for but may be
    /// adjusted by the latest completed.
    let expected: Amount
    
    /// Typically the maximum weight the user can use for this exercise though it is possible that the
    /// actual weight is larger than this if percent is greater than 1.0.
    let baseWeight: Float?
    
    /// The percent of baseWeight the user wants to use for this set.
    let percent: Float
    
    /// Percent times baseWeight mapped onto a WeightSet. Note that this may contain an error,
    /// e.g. if a percent exercise is missing the other exercise.
    let weight: ActualWeight?
    
    /// Seconds to rest after the set.
    let rest: Int?
    
    fileprivate init(_ model: Model, _ program: Program, _ exercise: Exercise, secs: Int, index: Int, count: Int) {
        self.kind = .workset(index: index, count: count)
        self.expected = .duration
        (self.baseWeight, self.percent, self.weight) = PlanSet.getWeight(model, program, exercise, 100)
        self.rest = secs
    }
    
    fileprivate init(_ model: Model, _ program: Program, _ exercise: Exercise, timed: Bool) {
        self.kind = .timed
        self.expected = .timed
        (self.baseWeight, self.percent, self.weight) = PlanSet.getWeight(model, program, exercise, 100)
        self.rest = nil
    }

    fileprivate init(_ model: Model, _ program: Program, _ exercise: Exercise, kind: Kind, fixed: FixedReps, rest: Int?) {
        let a = PlanSet.Amount.reps(min: fixed.reps, max: fixed.reps)
        self.kind = kind
        self.expected = a
        (self.baseWeight, self.percent, self.weight) = PlanSet.getWeight(model, program, exercise, fixed.percent)
        self.rest = rest
    }

    fileprivate init(_ model: Model, _ program: Program, _ exercise: Exercise, variable: VariableReps, index: Int, count: Int, rest: Int?) {
        self.kind = .workset(index: index, count: count)
        switch variable {
        case .amrap(_, let percent):
            let m = findMinExpected(exercise, variable, index)
            self.expected = Amount.amrap(min: m)
            (self.baseWeight, self.percent, self.weight) = PlanSet.getWeight(model, program, exercise, percent)
        case .fixed(let r, let percent):
            let a = Amount.reps(min: r, max: r)
            self.expected = a
            (self.baseWeight, self.percent, self.weight) = PlanSet.getWeight(model, program, exercise, percent)
        case .variable(_, let max):
            let m = findMinExpected(exercise, variable, index)
            self.expected = Amount.reps(min: m, max: max)
            (self.baseWeight, self.percent, self.weight) = PlanSet.getWeight(model, program, exercise, 100)
        }
        self.rest = rest
    }
    
    private static func getWeight(_ model: Model, _ program: Program, _ exercise: Exercise, _ setPercent: Int) -> (Float?, Float, ActualWeight?) {
        if case .percent(let d) = exercise.data {
            switch findBaseWeight(program, exercise) {
            case .success(let baseWeight):
                let p = Float(d.percent) / 100.0
                let q = Float(setPercent) / 100.0
                let percent = p*q
                if let wn = exercise.weightSet, let ws = model.weightSets[wn] {
                    let weight = ws.lower(target: percent*baseWeight)
                    return (baseWeight, percent, weight)
                } else {
                    let weight = ActualWeight(discrete: percent*baseWeight, .None)
                    return (baseWeight, percent, weight)
                }
            case .failure(let e):
                let weight = ActualWeight(error: e.localizedDescription, 0.0)
                return (nil, 1.0, weight)
            case nil:
                return (nil, 1.0, nil)
            }
        } else {
            let percent = Float(setPercent) / 100.0
            if let baseWeight = exercise.weight {
                if let wn = exercise.weightSet, let ws = model.weightSets[wn] {
                    let weight = ws.lower(target: percent*baseWeight)
                    return (baseWeight, percent, weight)
                } else {
                    let weight = ActualWeight(discrete: percent*baseWeight, .None)
                    return (baseWeight, percent, weight)
                }
            } else {
                return (nil, 1.0, nil)
            }
        }
    }
}

fileprivate func findMinExpected(_ exercise: Exercise, _ reps: VariableReps, _ index: Int) -> Int {
    switch reps {
    case .amrap(let min, _):
        // For AMRAP we'll just do the default unless the user did better last time at
        // the current weight.
        if let last = exercise.latestCompleted(), typeMatches(last, exercise), index < last.values.count {
            if let new = exercise.weight, let old = last.weight, new == old {
                let r = last.values[index]
                if r > min {
                    return r
                }
            }
        }
        return min
    case .fixed(let r, _):
        return r
    case .variable(let min, let max):
        // Usually we'll just return min except for a few cases:
        if let last = exercise.latestCompleted(), typeMatches(last, exercise) {
            if let new = exercise.weight, let old = last.weight {
                if new < old {
                    // 1) the user has dropped the weight
                    // Possible that they can't now do max, but they should be close to that...
                    return max
                } else if new == old && index < last.values.count {
                    // 2) the user is doing the same weight so the expected is whatever
                    // they last did clamped to what the current min/max is.
                    let r = last.values[index]
                    if r >= min && r < max {
                        return r
                    } else if r >= max {
                        return max
                    }
                }
            }
        }
        return min
    }
}

fileprivate func findBaseWeight(_ program: Program, _ exercise: Exercise) -> Result<Float, MyError>? {
    if let thisExercise = program.findExercise(exercise.name) {
        switch thisExercise.data {
        case .durations(_), .oneRepMax, .reps(_), .timed:
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
