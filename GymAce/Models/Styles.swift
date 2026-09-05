import Foundation

/// Controls how an exercise is performed: rest, reps, progression, etc.
enum Style: Codable {
    /// Reps increase to a max then weight increases and expected reps is set to min.
    case double_progression(DoubleProgressionInfo)
    
    /// Exercise is done for a specified number of seconds up to a target value.
    case durations(DurationsInfo)

    /// Four week blocks with increasing weight but fewer reps each week. Last week
    /// has an AMRAP set which controls whether weight is increased.
    case gzcl(GzclInfo)
    
    /// Used for exercises that have a styleName that isn't in the program. This allows the
    /// logic to be simplified.
    case missing
    
    /// Uses the exercise's formalName to find an exercise with that same formalName
    /// that also has a baseWeight. That exercise is used as the style except that an
    /// extra percentage is applied to weight. TODO validate needs to verify that there is one match
    case percent(PercentInfo)
    
    /// Exercise is done for an arbitrary amount of time, e.g. jogging.
    case timed
}

struct DoubleProgressionInfo: Codable {
    var warmup: [FixedReps]
    var workset: [VariableReps]
    var backoff: [FixedReps]
    var rest: Int?
    
    /// warmup is formatted as reps/percent, e.g. "5/60 8/80".
    /// workset entries are formatted as "5", "8-12", or "3+" followed by an optional "/90"
    /// rest is formatted as "2.5m", "150s", "150", or "2h"
    init?(warmup: String, workset: String, backoff: String? = nil, rest: String) {
        switch parseFixedReps(warmup) {
        case .success(let reps): self.warmup = reps
        case .failure: return nil
        }

        switch parseVarReps(workset) {
        case .success(let reps): self.workset = reps
        case .failure: return nil
        }
        
        if let b = backoff {
            switch parseFixedReps(b) {
            case .success(let reps): self.backoff = reps
            case .failure: return nil
            }
        } else {
            self.backoff = []
        }

        switch parseRest(rest) {
        case .success(let secs): self.rest = secs
        case .failure: return nil
        }
    }
}

struct DurationsInfo: Codable {
    var secs: [Int]
    var targetSecs: Int?
    
    init?(secs: String, targetSecs: String) {
        switch parseDurations(secs) {
        case .success(let s): self.secs = s
        case .failure: return nil
        }

        switch parseRest(targetSecs) {
        case .success(let secs): self.targetSecs = secs
        case .failure: return nil
        }
    }
}

struct GzclInfo: Codable {
    var rest: Int?
}

struct PercentInfo: Codable {
    var percent: Float
    var rest: Int?
    
    init?(percent: Float, rest: String) {
        self.percent = percent

        switch parseRest(rest) {
        case .success(let secs): self.rest = secs
        case .failure: return nil
        }
    }
}

extension Exercise {
    func numSets(_ program: Program) -> Int {
        switch program.findStyle(self.styleName) {
        case .double_progression(let info):
            return info.warmup.count + info.workset.count + info.backoff.count
        case .durations(let info):
            return info.secs.count
        case .gzcl(_):
            fatalError("not implemented")
        case .missing:
            return 1
        case .percent(_):
            if let (e, _) = findOtherExercise(program) {
                return e.numSets(program)
            } else {
                return 1
            }
        case .timed:
            return 1
        }
    }

    /// The minimum weight used by a workset.
    func bottomWeight(_ model: Model, _ program: Program, _ percent: Float = 1.0) -> ActualWeight? {
        switch program.findStyle(self.styleName) {
        case .double_progression(let info):
            var percents: [Int] = []
            for s in info.workset {
                switch s {
                case .amrap(_, let percent):
                    percents.append(percent)
                case .fixed(_, let percent):
                    percents.append(percent)
                case .variable:
                    percents.append(100)
                }
            }
            if let p = percents.min() {
                let q = Float(p) / 100.0
                return findActualWeight(model, program, q * percent)
            }
        case .durations, .missing, .timed:
            return findActualWeight(model, program, percent)
        case .gzcl(_):
            fatalError("not implemented")
        case .percent(let info):
            if let (e, _) = findOtherExercise(program), let w = e.bottomWeight(model, program, info.percent) {
                return w
            }
        }
        return nil
    }
        
    /// The maximum weight used by a workset.
    func topWeight(_ model: Model, _ program: Program, _ percent: Float = 1.0) -> ActualWeight? {
        switch program.findStyle(self.styleName) {
        case .double_progression(let info):
            var percents: [Int] = []
            for s in info.workset {
                switch s {
                case .amrap(_, let percent):
                    percents.append(percent)
                case .fixed(_, let percent):
                    percents.append(percent)
                case .variable:
                    percents.append(100)
                }
            }
            if let p = percents.max() {
                let q = Float(p) / 100.0
                return findActualWeight(model, program, q * percent)
            }
        case .durations, .missing, .timed:
            return findActualWeight(model, program, percent)
        case .gzcl(_):
            fatalError("not implemented")
        case .percent(let info):
            if let (e, _) = findOtherExercise(program), let w = e.topWeight(model, program, info.percent) {
                return w
            }
        }
        return nil
    }
            
    func planSets(_ model: Model, _ program: Program, _ workout: Workout, parentPercent: Float = 1.0, rest: Int? = nil) -> [PlanSet] {
        var sets: [PlanSet] = []
        switch program.findStyle(self.styleName) {
        case .double_progression(let info):
            for (i, s) in info.warmup.enumerated() {
                let k = PlanSet.Kind.warmup(index: i, count: info.warmup.count)
                let e = PlanSet.Amount.reps(min: s.reps, max: s.reps)
                let p = (Float(s.percent) / 100.0) * parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: nil)
                sets.append(set)
            }
            for (i, s) in info.workset.enumerated() {
                let k = PlanSet.Kind.workset(index: i, count: info.workset.count)
                let r: Int? = if let last = workout.entries.last, last.name == name, i == info.workset.count - 1, info.backoff.isEmpty {
                    nil     // don't use rest for the last set of the last exercise in a workout
                } else {
                    rest ?? self.rest(program, workout)
                }
                switch s {
                case .amrap(_, let percent):
                    let m = findMinExpected(model, program, workout, s, i)
                    let e = PlanSet.Amount.amrap(min: m)
                    let p = (Float(percent) / 100.0) * parentPercent
                    let w = findActualWeight(model, program, p)
                    let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: r)
                    sets.append(set)
                case .fixed(let reps, let percent):
                    let e = PlanSet.Amount.reps(min: reps, max: reps)
                    let p = (Float(percent) / 100.0) * parentPercent
                    let w = findActualWeight(model, program, p)
                    let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: r)
                    sets.append(set)
                case .variable(_, let max):
                    let m = findMinExpected(model, program, workout, s, i)
                    let e = PlanSet.Amount.reps(min: m, max: max)
                    let p = parentPercent
                    let w = findActualWeight(model, program, p)
                    let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: r)
                    sets.append(set)
                }
            }
            for (i, s) in info.backoff.enumerated() {
                let k = PlanSet.Kind.backoff(index: i, count: info.warmup.count)
                let e = PlanSet.Amount.reps(min: s.reps, max: s.reps)
                let p = (Float(s.percent) / 100.0) * parentPercent
                let w = findActualWeight(model, program, p)
                let r: Int? = if let last = workout.entries.last, last.name == name, i == info.backoff.count - 1 {
                    nil     // don't use rest for the last set of the last exercise in a workout
                } else {
                    rest ?? self.rest(program, workout)
                }
                let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: r)
                sets.append(set)
            }
        case .durations(let info):
            for (i, s) in info.secs.enumerated() {
                let k = PlanSet.Kind.workset(index: i, count: info.secs.count)
                let e = PlanSet.Amount.duration
                let p = parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: s)
                sets.append(set)
            }
        case .gzcl(_):
            fatalError("not implemented")
        case .missing:
            let k = PlanSet.Kind.workset(index: 0, count: 1)
            let e = PlanSet.Amount.reps(min: 5, max: 5)
            let p = parentPercent
            let w = findActualWeight(model, program, p)
            let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: rest)
            sets.append(set)
        case .percent(let info):
            if let (e, w) = findOtherExercise(program) {
                return e.planSets(model, program, w, parentPercent: parentPercent * info.percent, rest: info.rest)
            } else {
                return []   // validate will have complained
            }
        case .timed:
            let k = PlanSet.Kind.timed
            let e = PlanSet.Amount.timed
            let p = parentPercent
            let w = findActualWeight(model, program, p)
            let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: nil)
            sets.append(set)
        }
        return sets
    }
    
    func validateStyle(_ program: Program) -> Bool {
        var valid = true
        switch program.findStyle(self.styleName) {
        case .double_progression:
            if baseWeight == nil {
                print("Program \(program.name) exercise \(name) is missing a base weight (it's double progression style)")
                valid = false
            }
        case .durations:
            break
        case .gzcl:
            if baseWeight != nil {
                print("Program \(program.name) exercise \(name) should not have a base weight (it's gzcl style)")
                valid = false
            }
        case .missing:
            valid = false
        case .percent:
            if baseWeight != nil {
                print("Program \(program.name) exercise \(name) should not have a base weight (it's percent style)")
                valid = false
            }
            
            var count = 0
            for w in program.workouts { // logic needs to match findOtherExercise
                for n in w.entries {
                    if let e = program.findExercise(n.name), e.formalName == formalName {
                        let style = program.findStyle(e.styleName)
                        if case .percent = style {
                            continue
                        }
                        if case .missing = style {
                            continue
                        }
                        count += 1
                    }
                }
            }
            if count != 1 {
                print("Program \(program.name) exercise \(name) has \(count) other exercises (expected 1)")
                valid = false
            }
        case .timed:
            break
        }
        return valid
    }
    
    func usesOther(_ program: Program) -> Bool {
        switch program.findStyle(self.styleName) {
        case .double_progression, .durations, .missing, .timed: return false
        case .gzcl, .percent: return true
        }
    }
    
    func usesPercents(_ program: Program) -> Bool {
        switch program.findStyle(self.styleName) {
        case .double_progression(let info):
            for s in info.workset {
                switch s {
                case .amrap(_, let percent): if percent != 100 {return true}
                case .fixed(_, let percent): if percent != 100 {return true}
                case .variable: continue
                }
            }
            return false
        case .durations, .missing, .timed: return false
        case .gzcl, .percent: return true
        }
    }
    
    private func findActualWeight(_ model: Model, _ program: Program, _ percent: Float) -> ActualWeight? {
        assert(!usesOther(program))
        if let b = baseWeight {
            if let wn = weightSet, let ws = model.weightSets[wn] {
                if percent < 1.0 {
                    return ws.closest(target: percent*b)
                } else {
                    return ws.lower(target: percent*b)
                }
            } else {
                return ActualWeight(discrete: percent*b, .None)
            }
        }
        return nil
    }
    
    private func rest(_ program: Program, _ workout: Workout) -> Int? {   // TODO may also want min/max rest (these would be recommendations)
        switch program.findStyle(self.styleName) {
        case .double_progression(let info):
            return info.rest
        case .durations:
            return nil
        case .gzcl(let info):
            return info.rest
        case .missing:
            return nil
        case .percent(let info):
            if let r = info.rest {
                return r            // percent style rest can override other rest
            }
            if let (e, w) = findOtherExercise(program) {
                return e.rest(program, w)
            } else {
                return nil
            }
        case .timed:
            return nil
        }
    }

    // Return the first exercise with the same formalName that doesn't use percent style.
    func findOtherExercise(_ program: Program) -> (Exercise, Workout)? {
        for w in program.workouts {
            for n in w.entries {
                if let e = program.findExercise(n.name), e.formalName == formalName {
                    let style = program.findStyle(e.styleName)
                    if case .percent = style {
                        continue
                    }
                    if case .missing = style {
                        continue
                    }
                    return (e, w)
                }
            }
        }
        return nil
    }
    
    private func findMinExpected(_ model: Model, _ program: Program, _ workout: Workout, _ reps: VariableReps, _ index: Int) -> Int {
        switch reps {
        case .amrap(let min, _):
            // For AMRAP if the user did the top weight last workout and more reps than min
            // then use those reps as the min.
            if let last = latestCompleted(), typeMatches(program, last, self), index < last.values.count {
                if let top = topWeight(model, program)?.value(), let old = last.maxWeight(), old >= top {
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
            if let last = latestCompleted(), typeMatches(program, last, self) {
                if let top = topWeight(model, program)?.value(), let old = last.maxWeight() {
                    if top < old {
                        // 1) the user has dropped the weight
                        // Possible that they can't now do max, but they should be close to that...
                        return max
                    } else if top == old && index < last.values.count {
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
}

fileprivate func parseFixedReps(_ text: String) -> Result<[FixedReps], MyError> {
    var reps: [FixedReps] = []
    for s in text.split(separator: " ") {
        if let r = FixedReps(String(s)) {
            reps.append(r)
        } else {
            let err = MyError(err: "Expected a number for reps and a percent, e.g. 5/80, not '\(s)'.")
            return .failure(err)
        }
    }
    return .success(reps)
}

fileprivate func parseVarReps(_ text: String) -> Result<[VariableReps], MyError> {
    var reps: [VariableReps] = []
    for s in text.split(separator: " ") {
        if let r = VariableReps(String(s)) {
            reps.append(r)
        } else {
            let err = MyError(err: "Expected a rep, rep range, or As Many Reps As Possible, not '\(s)'.")
            return .failure(err)
        }
    }
    return .success(reps)
}

fileprivate func parseDurations(_ text: String) -> Result<[Int], MyError> {
    var secs: [Int] = []
    for s in text.split(separator: " ") {
        if let s = parseShortSecs(String(s)) {
            secs.append(s)
        } else {
            let err = MyError(err: "Expected a number followed by an optional time suffix, not '\(s)'.")
            return .failure(err)
        }
    }
    return .success(secs)
}

fileprivate func parseRest(_ text: String) -> Result<Int?, MyError> {
    if let s = parseShortSecs(text) {
        return .success(s)
    } else if text.isBlankOrEmpty {
        return .success(nil)
    } else {
        let err = MyError(err: "Expected nothing or a number with an optional time suffix, not '\(text)'.")
        return .failure(err)
    }
}

