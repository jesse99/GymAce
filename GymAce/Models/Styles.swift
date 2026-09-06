import Foundation

/// Controls how an exercise is performed: rest, reps, progression, etc.
enum Style: Codable {
    /// Workset reps are fixed, but last set is AMRAP. Progress is based on the results of
    /// the AMRAP set.
    case amrap(AMRAPInfo)

    /// Workset reps are fixed and progress happens if user hits requsted reps.
    case beginner(BeginnerInfo)
    
    /// Reps increase to a max then weight increases and expected reps is set to min.
    case variable(VariableInfo)
    
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

struct AMRAPInfo: Codable {
    var warmup: [OtherReps]
    var workset: [Int]
    var backoff: [OtherReps]
    var rest: Int?
    
    /// warmup is formatted as reps/percent, e.g. "5/60 8/80".
    /// rest is formatted as "2.5m", "150s", "150", or "2h"
    init?(warmup: String, workset: [Int], backoff: String? = nil, rest: String) {
        switch parseOtherReps(warmup) {
        case .success(let reps): self.warmup = reps
        case .failure: return nil
        }

        self.workset = workset

        if let b = backoff {
            switch parseOtherReps(b) {
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

struct BeginnerInfo: Codable {
    var warmup: [OtherReps]
    var workset: [Int]
    var rest: Int?
    
    /// warmup is formatted as reps/percent, e.g. "5/60 8/80".
    /// rest is formatted as "2.5m", "150s", "150", or "2h"
    init?(warmup: String, workset: [Int], rest: String) {
        switch parseOtherReps(warmup) {
        case .success(let reps): self.warmup = reps
        case .failure: return nil
        }

        self.workset = workset
        
        switch parseRest(rest) {
        case .success(let secs): self.rest = secs
        case .failure: return nil
        }
    }
}

struct VariableInfo: Codable {
    var warmup: [OtherReps]
    var workset: [VariableReps]
    var backoff: [OtherReps]
    var rest: Int?
    
    /// warmup is formatted as reps/percent, e.g. "5/60 8/80".
    /// workset entries are formatted as "5" or "8-12" followed by an optional "/90"
    /// rest is formatted as "2.5m", "150s", "150", or "2h"
    init?(warmup: String, workset: String, backoff: String? = nil, rest: String) {
        switch parseOtherReps(warmup) {
        case .success(let reps): self.warmup = reps
        case .failure: return nil
        }

        switch parseVarReps(workset) {
        case .success(let reps): self.workset = reps
        case .failure: return nil
        }
        
        if let b = backoff {
            switch parseOtherReps(b) {
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
    var percent: Int
    var rest: Int?
    
    init?(percent: Int, rest: String) {
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
        case .amrap(let info):
            return info.warmup.count + info.workset.count + info.backoff.count
        case .beginner(let info):
            return info.warmup.count + info.workset.count
        case .variable(let info):
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
        case .amrap(let info):
            return findActualWeight(model, program, percent)
        case .beginner(let info):
            return findActualWeight(model, program, percent)
        case .variable(let info):
            var percents: [Int] = []
            for s in info.workset {
                percents.append(s.percent)
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
            let p = Float(info.percent) / 100.0
            if let (e, _) = findOtherExercise(program), let w = e.bottomWeight(model, program, p * percent) {
                return w
            }
        }
        return nil
    }
        
    /// The maximum weight used by a workset.
    func topWeight(_ model: Model, _ program: Program, _ percent: Float = 1.0) -> ActualWeight? {
        switch program.findStyle(self.styleName) {
        case .amrap(let info):
            return findActualWeight(model, program, percent)
        case .beginner(let info):
            return findActualWeight(model, program, percent)
        case .variable(let info):
            var percents: [Int] = []
            for s in info.workset {
                percents.append(s.percent)
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
            let p = Float(info.percent) / 100.0
            if let (e, _) = findOtherExercise(program), let w = e.topWeight(model, program, p * percent) {
                return w
            }
        }
        return nil
    }
            
    func planSets(_ model: Model, _ program: Program, _ workout: Workout, parentPercent: Float = 1.0, rest: Int? = nil) -> [PlanSet] {
        var sets: [PlanSet] = []
        switch program.findStyle(self.styleName) {
        case .amrap(let info):
            for (i, s) in info.warmup.enumerated() {        // TODO some duplication here
                let k = PlanSet.Kind.warmup(index: i, count: info.warmup.count)
                let e = PlanSet.Amount.reps(min: s.reps, max: s.reps)
                let p = (Float(s.percent) / 100.0) * parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: nil)
                sets.append(set)
            }
            for (i, reps) in info.workset.enumerated() {
                let k = PlanSet.Kind.workset(index: i, count: info.workset.count)
                let r: Int? = if let last = workout.entries.last, last.name == name, i == info.workset.count - 1, info.backoff.isEmpty {
                    nil     // don't use rest for the last set of the last exercise in a workout
                } else {
                    rest ?? self.rest(program, workout)
                }

                let e = if i == info.workset.count - 1 {
                    PlanSet.Amount.amrap(min: findMinAMRAP(model, program, reps, i))
                } else {
                    PlanSet.Amount.reps(min: reps, max: reps)
                }
                let p = parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: r)
                sets.append(set)
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
        case .beginner(let info):
            for (i, s) in info.warmup.enumerated() {
                let k = PlanSet.Kind.warmup(index: i, count: info.warmup.count)
                let e = PlanSet.Amount.reps(min: s.reps, max: s.reps)
                let p = (Float(s.percent) / 100.0) * parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: nil)
                sets.append(set)
            }
            for (i, reps) in info.workset.enumerated() {
                let k = PlanSet.Kind.workset(index: i, count: info.workset.count)
                let r: Int? = if let last = workout.entries.last, last.name == name, i == info.workset.count - 1 {
                    nil     // don't use rest for the last set of the last exercise in a workout
                } else {
                    rest ?? self.rest(program, workout)
                }

                let e = PlanSet.Amount.reps(min: reps, max: reps)
                let p = parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: r)
                sets.append(set)
            }
        case .variable(let info):
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
                let m = findMinVariable(model, program, s, i)
                let e = PlanSet.Amount.reps(min: m, max: s.maxReps)
                let p = parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: baseWeight, percent: p, weight: w, rest: r)
                sets.append(set)
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
            let p = Float(info.percent) / 100.0
            if let (e, w) = findOtherExercise(program) {
                return e.planSets(model, program, w, parentPercent: p * parentPercent, rest: info.rest)
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
        case .amrap:
            if baseWeight == nil {
                print("Program \(program.name) exercise \(name) is missing a base weight (it's AMRAP style)")
                valid = false
            }
        case .beginner:
            if baseWeight == nil {
                print("Program \(program.name) exercise \(name) is missing a base weight (it's beginner style)")
                valid = false
            }
        case .variable:
            if baseWeight == nil {
                print("Program \(program.name) exercise \(name) is missing a base weight (it's variable style)")
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
        case .amrap, .beginner, .variable, .durations, .missing, .timed: return false
        case .gzcl, .percent: return true
        }
    }
    
    func usesPercents(_ program: Program) -> Bool {
        switch program.findStyle(self.styleName) {
        case .amrap, .beginner, .durations, .missing, .timed: return false
        case .variable(let info):
            for s in info.workset {
                if s.percent != 100 {return true}
            }
            return false
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
        case .amrap(let info):
            return info.rest
        case .beginner(let info):
            return info.rest
        case .variable(let info):
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
    
    private func findMinAMRAP(_ model: Model, _ program: Program, _ reps: Int, _ index: Int) -> Int {
        // For AMRAP if the user did the top weight last workout and more reps than min
        // then use those reps as the min.
        if let last = latestCompleted(), typeMatches(program, last, self), index < last.values.count {
            if let top = topWeight(model, program)?.value(), let old = last.maxWeight(), old >= top {
                let r = last.values[index]
                if r > reps {
                    return r
                }
            }
        }
        return reps
    }

    private func findMinVariable(_ model: Model, _ program: Program, _ reps: VariableReps, _ index: Int) -> Int {
        // Usually we'll just return min except for a few cases:
        if let last = latestCompleted(), typeMatches(program, last, self) {
            if let top = topWeight(model, program)?.value(), let old = last.maxWeight() {
                if top < old {
                    // 1) the user has dropped the weight
                    // Possible that they can't now do max, but they should be close to that...
                    return reps.maxReps
                } else if top == old && index < last.values.count {
                    // 2) the user is doing the same weight so the expected is whatever
                    // they last did clamped to what the current min/max is.
                    let r = last.values[index]
                    if r >= reps.minReps && r < reps.maxReps {
                        return r
                    } else if r >= reps.maxReps {
                        return reps.maxReps
                    }
                }
            }
        }
        return reps.minReps
    }
}

fileprivate func parseOtherReps(_ text: String) -> Result<[OtherReps], MyError> {
    var reps: [OtherReps] = []
    for s in text.split(separator: " ") {
        if let r = OtherReps(String(s)) {
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

