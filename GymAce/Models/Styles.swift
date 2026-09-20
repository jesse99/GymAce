import Foundation

/// Controls how an exercise is performed: rest, reps, progression, etc.
enum Style: Codable {
    /// Workset reps are fixed, but last set is AMRAP. Progress is based on the results of
    /// the AMRAP set.
    case amrap(AMRAPInfo)

    /// Workset reps are fixed and progress happens if user hits requsted reps.
    case basic(BasicInfo)
    
    /// Exercise is done for a specified number of seconds up to a target value.
    case durations(DurationsInfo)

    /// Like variabl;e except weights only change via the user..
    case manual(VariableInfo)
    
    /// Used for exercises that have a styleName that isn't in the program. This allows the
    /// logic to be simplified.
    case missing
    
    /// Used to compute a one rep max. This is usally used in conjunction with the percent and/or amrap styles.
    case oneRepMax(OneRepMaxInfo)
    
    /// Exercise is done for an arbitrary amount of time, e.g. jogging.
    case timed

    /// Reps increase to a max then weight increases and expected reps is set to min.
    case variable(VariableInfo)
}

extension Style {
    func description() -> String {
        switch self {
        case .amrap:
            return "Worksets are for a fixed number of reps but the last set is As Many Reps As Possible. Weights increase based on the results of the AMRAP set."
        case .basic:
            return "Worksets are for a fixed number of reps. Weights are increased if you were able to do all the requested reps."
        case .durations:
            return "The exercise is done for a specified time with an optional target time. If you hit the target you may want to switch to a harder version of the exercise, e.g. planks to foot elevated planks."
        case .manual:
            return "Worksets are for a range of reps, e.g. 8-12. Weights are increased only via the user."
        case .missing:
            return "The style is missing from the program."
        case .oneRepMax:
            return "Used to compute a one rep max attached to an exercise's formal name. This is typically the 'other' exercise for exercises where the worksets use a percentage of the 1rm weight."
        case .timed:
            return "The exercise is done for an arbitrary amount of time, e.g. a walk."
        case .variable:
            return "Worksets are for a range of reps, e.g. 8-12. Weights are increased when you are able to do all sets at the max reps."
        }
    }
    
    func summary() -> [String] {
        switch self {
        case .amrap(let info): return info.summary()
        case .basic(let info): return info.summary()
        case .durations(let info): return info.summary()
        case .manual(let info): return info.summary()
        case .missing: return []
        case .oneRepMax(let info): return info.summary()
        case .timed: return []
        case .variable(let info): return info.summary()
        }
    }
    
    func dump(includeType: Bool, prefix: String = "") -> String {
        var result = ""
        switch self {
        case .amrap(let info):
            if includeType {
                result += "\(prefix)amrap\n"
            }
            result += info.dump(prefix)
        case .basic(let info):
            if includeType {
                result += "\(prefix)basic\n"
            }
            result += info.dump(prefix)
        case .durations(let info):
            if includeType {
                result += "\(prefix)durations\n"
            }
            result += info.dump(prefix)
        case .manual(let info):
            if includeType {
                result += "\(prefix)manual\n"
            }
            result += info.dump(prefix)
        case .missing:
            result += "\(prefix)missing\n"
        case .oneRepMax(let info):
            if includeType {
                result += "\(prefix)one rep max\n"
            }
            result += info.dump(prefix)
        case .timed:
            result += "\(prefix)timed\n"
        case .variable(let info):
            if includeType {
                result += "\(prefix)variable\n"
            }
            result += info.dump(prefix)
        }
        return result
    }
}

// Warmup percents must be increasing, and less than the first workset.
func validateWarmups(_ warmup: [OtherReps], _ workset: Int?) -> Bool {
    var prior = -1
    for s in warmup {
        if s.percent <= prior {
            return false
        }
        prior = s.percent
    }
    if let p = workset {
        if p <= prior {
            return false
        }
    }
    return true
}

struct AMRAPInfo: Codable {
    var warmup: [OtherReps]
    var workset: [PercentReps]
    var rest: Int?
    
    /// warmup is formatted as reps/percent, e.g. "5/60 8/80"
    /// workset is formatted as reps with an optional percent
    /// rest is formatted as "2.5m", "150s", "150", or "2h"
    init?(warmup: String, workset: String, rest: String) {
        switch parseOtherReps(warmup) {     // TODO should verify that these all increase and last is less than workset
        case .success(let reps): self.warmup = reps // TODO some below need to do the same thing
        case .failure: return nil
        }

        switch parsePercentReps(workset) {
        case .success(let reps): self.workset = reps
        case .failure: return nil
        }

        switch parseRest(rest) {
        case .success(let secs): self.rest = secs
        case .failure: return nil
        }
        if !validateWarmups(self.warmup, self.workset.first?.percent) {
            return nil
        }
    }
    
    func summary() -> [String] {
        var result: [String] = []
        if !warmup.isEmpty {
            result.append("Warmup: " + warmup.map({$0.asString()}).joined(separator: " "))
        }
        result.append("Workset: " + workset.map({$0.asString()}).joined(separator: " ") + "+")
        return result
    }
    
    func dump(_ prefix: String) -> String {
        var result = ""
        if !warmup.isEmpty {
            result += "\(prefix)warmup: " + warmup.map({$0.asString()}).joined(separator: " ") + "\n"
        }
        result += "\(prefix)workset: " + workset.map({$0.asString()}).joined(separator: " ") + "\n"
        if let r = rest {
            result += "\(prefix)rest: " + secsToShortStr(r) + "\n"
        } else {
            result += "\(prefix)rest: none\n"
        }
        return result
    }
}

struct BasicInfo: Codable {
    var warmup: [OtherReps]
    var workset: [PercentReps]
    var rest: Int?
    
    /// warmup is formatted as reps/percent, e.g. "5/60 8/80".
    /// workset is formatted as reps with an optional percent
    /// rest is formatted as "2.5m", "150s", "150", or "2h"
    init?(warmup: String, workset: String, rest: String) {
        switch parseOtherReps(warmup) {
        case .success(let reps): self.warmup = reps
        case .failure: return nil
        }

        switch parsePercentReps(workset) {
        case .success(let reps): self.workset = reps
        case .failure: return nil
        }

        switch parseRest(rest) {
        case .success(let secs): self.rest = secs
        case .failure: return nil
        }
        if !validateWarmups(self.warmup, self.workset.first?.percent) {
            return nil
        }
    }
    
    func summary() -> [String] {
        var result: [String] = []
        if !warmup.isEmpty {
            result.append("Warmup: " + warmup.map({$0.asString()}).joined(separator: " "))
        }
        result.append("Workset: " + workset.map({$0.asString()}).joined(separator: " "))
        return result
    }
    
    func dump(_ prefix: String) -> String {
        var result = ""
        if !warmup.isEmpty {
            result += "\(prefix)warmup: " + warmup.map({$0.asString()}).joined(separator: " ") + "\n"
        }
        result += "\(prefix)workset: " + workset.map({$0.asString()}).joined(separator: " ") + "\n"
        if let r = rest {
            result += "\(prefix)rest: " + secsToShortStr(r) + "\n"
        } else {
            result += "\(prefix)rest: none\n"
        }
        return result
    }
}

func validate1RMWarmups(_ warmup: [OtherReps], _ workset: [PercentReps]) -> Bool {
    if workset.count == 1 {
        // Warmups must all increase and be less than the first workset percent
        // (which is computed for the 1rm style when there is only one workset).
        let p = computePercent(reps: workset[0].reps) ?? 1.0
        if !validateWarmups(warmup, Int(100*p)) {
            return false
        }
    } else if let first = workset.first {
        // Warmups must all increase and be less than the first workset percent.
        if !validateWarmups(warmup, first.percent) {
            return false
        }
    } else {
        if !validateWarmups(warmup, nil) {
            return false
        }
    }
    return true
}

func validate1RMWorksets(_ warmup: [OtherReps], _ workset: [PercentReps]) -> Bool {
    // Last workset percent is computed
    if let s = workset.last, s.percent != 100 {
        return false
    }

    if workset.count > 1, let last = workset.last {
        // Workset percents must all be less than the last computed percent (they
        // should normally be increasing but that isn't a hard requirement).
        let p = Int(100.0 * (computePercent(reps: last.reps) ?? 1.0))
        for s in workset.dropLast() {
            if s.percent > p {
                return false
            }
        }
    }
    return true
}

struct OneRepMaxInfo: Codable {
    var warmup: [OtherReps]
    var workset: [PercentReps]
    var rest: Int?
    
    /// warmup is formatted as reps/percent, e.g. "5/60 8/80".
    /// workset is formatted as reps with an optional percent, though the last set must be at 100%
    /// rest is formatted as "2.5m", "150s", "150", or "2h"
    init?(warmup: String, workset: String, rest: String) {
        switch parseOtherReps(warmup) {
        case .success(let reps): self.warmup = reps
        case .failure: return nil
        }
        
        switch parsePercentReps(workset) {
        case .success(let reps): self.workset = reps
        case .failure: return nil
        }

        switch parseRest(rest) {
        case .success(let secs): self.rest = secs
        case .failure: return nil
        }
        
        if !validate1RMWarmups(self.warmup, self.workset) {
            return nil
        }
        if !validate1RMWorksets(self.warmup, self.workset) {
            return nil
        }
    }
    
//    enum CodingKeys: String, CodingKey {
//        case warmup, workset, rest
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        warmup = try container.decode(Array<OtherReps>.self, forKey: .warmup)
//        rest = try container.decodeIfPresent(Int.self, forKey: .rest)
//
//        do {
//            workset = try container.decode(Array<PercentReps>.self, forKey: .workset)
//        } catch {
//            let reps = try container.decode(Int.self, forKey: .workset)
//            workset = [PercentReps(reps: reps, percent: 100)]
//        }
//    }
        
    func summary() -> [String] {
        var result: [String] = []
        if !warmup.isEmpty {
            result.append("Warmup: " + warmup.map({$0.asString()}).joined(separator: " "))
        }
        result.append("Workset: \(workset)+")
        return result
    }
    
    func dump(_ prefix: String) -> String {
        var result = ""
        if !warmup.isEmpty {
            result += "\(prefix)warmup: " + warmup.map({$0.asString()}).joined(separator: " ") + "\n"
        }
        result += "\(prefix)workset: " + workset.map({$0.asString()}).joined(separator: " ") + "\n"
        if let r = rest {
            result += "\(prefix)rest: " + secsToShortStr(r) + "\n"
        } else {
            result += "\(prefix)rest: none\n"
        }
        return result
    }
}

struct VariableInfo: Codable {
    var warmup: [OtherReps]
    var workset: [VariableReps]
    var rest: Int?
    
    /// warmup is formatted as reps/percent, e.g. "5/60 8/80".
    /// workset entries are formatted as "5" or "8-12" followed by an optional "/90"
    /// rest is formatted as "2.5m", "150s", "150", or "2h"
    init?(warmup: String, workset: String, rest: String) {
        switch parseOtherReps(warmup) {
        case .success(let reps): self.warmup = reps
        case .failure: return nil
        }

        switch parseVarReps(workset) {
        case .success(let reps): self.workset = reps
        case .failure: return nil
        }
        
        switch parseRest(rest) {
        case .success(let secs): self.rest = secs
        case .failure: return nil
        }
        if !validateWarmups(self.warmup, self.workset.first?.percent) {
            return nil
        }
    }
    
    func summary() -> [String] {
        var result: [String] = []
        if !warmup.isEmpty {
            result.append("Warmup: " + warmup.map({$0.asString()}).joined(separator: " "))
        }
        result.append("Workset: " + workset.map({$0.asString()}).joined(separator: " "))
        return result
    }
    
    func dump(_ prefix: String) -> String {
        var result = ""
        if !warmup.isEmpty {
            result += "\(prefix)warmup: " + warmup.map({$0.asString()}).joined(separator: " ") + "\n"
        }
        result += "\(prefix)workset: " + workset.map({$0.asString()}).joined(separator: " ") + "\n"
        if let r = rest {
            result += "\(prefix)rest: " + secsToShortStr(r) + "\n"
        } else {
            result += "\(prefix)rest: none\n"
        }
        return result
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
    
    func summary() -> [String] {
        var result: [String] = []
        result.append("Durations: " + secs.map({secsToShortStr($0)}).joined(separator: " "))
        return result
    }
    
    func dump(_ prefix: String) -> String {
        var result = ""
        result += "\(prefix)secs: " + secs.map({secsToShortStr($0)}).joined(separator: " ") + "\n"
        if let t = targetSecs {
            result += "\(prefix)target: " + secsToShortStr(t) + "\n"
        } else {
            result += "\(prefix)target: none\n"
        }
        return result
    }
}

extension Exercise {
    /// Looks at completed and returns 1 if weight should be bumped by one increment, 2 if by two increments, -1 if weight should be dropped, etc.
    /// Returns nil if the style doesn't handle progression.
    func progress(_ program: Program) -> Int? {
        switch program.findStyle(self.styleName) {
        case .amrap(let info):
            if case .weight(let b) = self.baseWeight {
                let compatible: ([Int], Float?) -> Bool = {reps, baseWeight in
                    if let oldBase = baseWeight {
                        if oldBase < b {
                            return false
                        }
                    } else {
                        return false
                    }
                    return reps.count == info.workset.count
                }
                let canProgress: ([Int], Float?) -> Bool = {reps, weights in
                    let actual = reps.reduce(0, +)
                    let expected = info.workset.reduce(0, {$0 + $1.reps})
                    return actual > expected    // technically we could just check the last set, but what really matters is total volume so we check all sets
                }
                
                // Progress if the user did more than expected on the AMRAP set
                if let actual = getLastTotalReps(n: -1), checkReps(n: -1, with: compatible) {
                    let expected = info.workset.reduce(0, {$0 + $1.reps})
                    if actual > expected {
                        return min(actual - expected, 3)
                    }
                }

                if checkReps(n: -1, with: {reps, weights in compatible(reps, weights) && canProgress(reps, weights)}) {
                    return 1
                }

                // If the user stalled 3x in a row then regress.
                let failed1 = checkReps(n: -1, with: {reps, weights in compatible(reps, weights) && !canProgress(reps, weights)})
                let failed2 = checkReps(n: -2, with: {reps, weights in compatible(reps, weights) && !canProgress(reps, weights)})
                let failed3 = checkReps(n: -3, with: {reps, weights in compatible(reps, weights) && !canProgress(reps, weights)})
                if failed1 && failed2 && failed3 {
                    return -2
                }
                
                // Also regress if the user did badly on the AMRAP. Note that we consider one missed rep on the
                // AMRAP set as just a bad day and treat it as a stalled workout.
                if let expected = info.workset.last?.reps, let actual = getLastReps(n: -1), checkReps(n: -1, with: compatible) {
                    if expected == 1 && actual < 1 {
                        return -2
                    } else if expected > 1 && actual < expected - 1 {
                        return -2
                    }
                }
            }
            return 0
        case .basic(let info):
            if case .weight(let b) = self.baseWeight {
                let compatible: ([Int], Float?) -> Bool = {reps, baseWeight in
                    if let oldBase = baseWeight {
                        if oldBase < b {
                            return false
                        }
                    } else {
                        return false
                    }
                    return reps.count == info.workset.count
                }
                let canProgress: ([Int], Float?) -> Bool = {reps, weights in
                    let actual = reps.reduce(0, +)
                    let expected = info.workset.reduce(0, {$0 + $1.reps})
                    return actual >= expected
                }
                let terrible: ([Int], Float?) -> Bool = {reps, weights in
                    let actual = reps.reduce(0, +)
                    let expected = info.workset.reduce(0, {$0 + $1.reps})
                    return expected > 3*reps.count && actual < 3*reps.count
                }
                // If the user was able to do all the reps then progress.
                if checkReps(n: -1, with: {reps, weights in compatible(reps, weights) && canProgress(reps, weights)}) {
                    return 1
                }
                
                // If the user failed 3x in a row to do all the reps then regress.
                let failed1 = checkReps(n: -1, with: {reps, weights in compatible(reps, weights) && !canProgress(reps, weights)})
                let failed2 = checkReps(n: -2, with: {reps, weights in compatible(reps, weights) && !canProgress(reps, weights)})
                let failed3 = checkReps(n: -3, with: {reps, weights in compatible(reps, weights) && !canProgress(reps, weights)})
                if failed1 && failed2 && failed3 {
                    return -2
                }
                
                // If the user did less than three reps per set then regress: that's really not enough volume
                // for a beginner program.
                if checkReps(n: -1, with: {reps, weights in compatible(reps, weights) && terrible(reps, weights)}) {
                    return -2
                }
            }
            return 0
        case .manual:
            return nil
        case .oneRepMax:
            return 0    // we adjust the weight in completedLast since this is handled a bit differently than the other styles
        case .variable(let info):
            if case .weight(let b) = self.baseWeight {
                let compatible: ([Int], Float?) -> Bool = {reps, baseWeight in
                    if let oldBase = baseWeight {
                        if oldBase < b {
                            return false
                        }
                    } else {
                        return false
                    }
                    return reps.count == info.workset.count
                }
                let canProgress: ([Int], Float?) -> Bool = {reps, weights in
                    let actual = reps.reduce(0, +)
                    let expected = info.workset.reduce(0, {$0 + $1.maxReps})
                    return actual >= expected
                }
                // If the user was able to do all the reps then progress.
                if checkReps(n: -1, with: {reps, weights in compatible(reps, weights) && canProgress(reps, weights)}) {
                    return 1
                }
                
                // If the user failed to make progress 3x in a row then regress.
                if checkReps(n: -4, with: {reps, weights in compatible(reps, weights)}) &&
                    checkReps(n: -3, with: {reps, weights in compatible(reps, weights)}) &&
                    checkReps(n: -2, with: {reps, weights in compatible(reps, weights)}) &&
                    checkReps(n: -1, with: {reps, weights in compatible(reps, weights)})
                {
                    if let r4 = getTotalReps(n: -4), let r3 = getTotalReps(n: -3), let r2 = getTotalReps(n: -2), let r1 = getTotalReps(n: -1) {
                        if r1 <= r2 && r2 <= r3 && r3 <= r4 {
                            return -2
                        }
                    }
                }
                
                // If the user did less than min reps then regress
                if let actual = getTotalReps(n: -1), checkReps(n: -1, with: compatible) {
                    let expected = info.workset.reduce(0, {$0 + $1.minReps})
                    if actual < expected {
                        return -2
                    }
                }
            }
            return 0
        case .durations, .missing, .timed:
            return nil
        }
    }
    
    func progress1RM(_ model: Model, _ program: Program, actualWeight: Float, actualReps: Int) -> Int? {
        var progressed: Int? = nil
        if actualWeight > 0.0 {
            if actualReps == 0 {
                if let wn = self.weightSet, let ws = model.weightSets[wn] {
                    if case .weight(let old) = self.baseWeight {
                        self.baseWeight = .weight(ws.lower(target: old - 0.001).value())
                        progressed = -1
                    } else if case .other = self.baseWeight {
                        if let (other, _) = findOtherExercise(program) {
                            if let old = other.findBaseWeight(program) {
                                other.baseWeight = .weight(ws.lower(target: old - 0.001).value())
                                progressed = -1
                            }
                        }
                    }
                }
            } else if let orm = compute1RM(weight: actualWeight, reps: actualReps) {
                let new = orm.rounded() // looks a lot nicer if we round and no one cares about a tenth of a pound or kilogram here
                if case .weight(let old) = self.baseWeight {
                    if new > old {
                        progressed = 1
                    } else if new < old {
                        progressed = -1
                    }
                    self.baseWeight = .weight(new)
                } else if case .other = self.baseWeight {
                    if let (other, _) = findOtherExercise(program) {
                        if let old = other.findBaseWeight(program) {
                            if new > old {
                                progressed = 1
                            } else if new < old {
                                progressed = -1
                            }
                            other.baseWeight = .weight(new)
                        }
                    }
                }
            }
        }
        return progressed
    }
    
    private func getLastReps(n: Int) -> Int? {
        if self.history.count + n >= 0 {
            let c = self.history[self.history.count + n]
            if case .reps = c.type {
                return c.values.last
            }
        }
        return nil
    }

    private func getLastTotalReps(n: Int) -> Int? {
        if self.history.count + n >= 0 {
            let c = self.history[self.history.count + n]
            if case .reps = c.type {
                return c.values.reduce(0, +)
            }
        }
        return nil
    }

    private func checkReps(n: Int, with: (_ reps: [Int], _ baseWeight: Float?) -> Bool) -> Bool {
        if self.history.count + n >= 0 {
            let c = self.history[self.history.count + n]
            if case .reps = c.type {
                return with(c.values, c.baseWeight)
            }
        }
        return false
    }

    private func getTotalReps(n: Int) -> Int? {
        if self.history.count + n >= 0 {
            let c = self.history[self.history.count + n]
            if case .reps = c.type {
                return c.values.reduce(0, +)
            }
        }
        return nil
    }

    func numSets(_ program: Program) -> Int {
        switch program.findStyle(self.styleName) {
        case .amrap(let info):
            return info.warmup.count + info.workset.count
        case .basic(let info):
            return info.warmup.count + info.workset.count
        case .durations(let info):
            return info.secs.count
        case .manual(let info):
            return info.warmup.count + info.workset.count
        case .missing:
            return 1
        case .oneRepMax(let info):
            return info.warmup.count + info.workset.count
        case .timed:
            return 1
        case .variable(let info):
            return info.warmup.count + info.workset.count
        }
    }

    /// The minimum weight used by a workset.
    func bottomWeight(_ model: Model, _ program: Program, _ percent: Float = 1.0) -> ActualWeight? {
        switch program.findStyle(self.styleName) {
        case .amrap:
            return findActualWeight(model, program, percent)
        case .basic:
            return findActualWeight(model, program, percent)
        case .manual(let info), .variable(let info):
            var percents: [Int] = []
            for s in info.workset {
                percents.append(s.percent)
            }
            if let p = percents.min() {
                let q = Float(p) / 100.0
                return findActualWeight(model, program, q * percent)
            }
        case .durations, .missing, .oneRepMax, .timed:
            return findActualWeight(model, program, percent)
        }
        return nil
    }
        
    /// The maximum weight used by a workset.
    func topWeight(_ model: Model, _ program: Program, _ percent: Float = 1.0) -> ActualWeight? {
        switch program.findStyle(self.styleName) {
        case .amrap:
            return findActualWeight(model, program, percent)
        case .basic:
            return findActualWeight(model, program, percent)
        case .manual(let info), .variable(let info):
            var percents: [Int] = []
            for s in info.workset {
                percents.append(s.percent)
            }
            if let p = percents.max() {
                let q = Float(p) / 100.0
                return findActualWeight(model, program, q * percent)
            }
        case .durations, .missing, .oneRepMax, .timed:
            return findActualWeight(model, program, percent)
        }
        return nil
    }
            
    func planSets(_ model: Model, _ program: Program, _ workout: Workout, parentPercent: Float = 1.0, rest: Int? = nil) -> [PlanSet] {
        var sets: [PlanSet] = []
        switch program.findStyle(self.styleName) {
        case .amrap(let info):
            let b = findBaseWeight(program)
            for (i, s) in info.warmup.enumerated() {        // TODO some duplication here
                let k = PlanSet.Kind.warmup(index: i, count: info.warmup.count)
                let e = PlanSet.Amount.reps(min: s.reps, max: s.reps)
                let p = (Float(s.percent) / 100.0) * parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: nil)
                sets.append(set)
            }
            for (i, s) in info.workset.enumerated() {
                let k = PlanSet.Kind.workset(index: i, count: info.workset.count)
                let r: Int? = if let last = workout.entries.last, last.name == name, i == info.workset.count - 1 {
                    nil     // don't use rest for the last set of the last exercise in a workout
                } else {
                    rest ?? self.rest(program, workout)
                }

                let e = if i == info.workset.count - 1 {
                    PlanSet.Amount.amrap(min: findMinAMRAP(model, program, s.reps, i))
                } else {
                    PlanSet.Amount.reps(min: s.reps, max: s.reps)
                }
                let p = (Float(s.percent) / 100.0) * parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: r)
                sets.append(set)
            }
        case .basic(let info):
            let b = findBaseWeight(program)
            for (i, s) in info.warmup.enumerated() {
                let k = PlanSet.Kind.warmup(index: i, count: info.warmup.count)
                let e = PlanSet.Amount.reps(min: s.reps, max: s.reps)
                let p = (Float(s.percent) / 100.0) * parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: nil)
                sets.append(set)
            }
            for (i, s) in info.workset.enumerated() {
                let k = PlanSet.Kind.workset(index: i, count: info.workset.count)
                let r: Int? = if let last = workout.entries.last, last.name == name, i == info.workset.count - 1 {
                    nil     // don't use rest for the last set of the last exercise in a workout
                } else {
                    rest ?? self.rest(program, workout)
                }

                let e = PlanSet.Amount.reps(min: s.reps, max: s.reps)
                let p = (Float(s.percent) / 100.0) * parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: r)
                sets.append(set)
            }
        case .oneRepMax(let info):
            let b = findBaseWeight(program)
            for (i, s) in info.warmup.enumerated() {
                let k = PlanSet.Kind.warmup(index: i, count: info.warmup.count)
                let e = PlanSet.Amount.reps(min: s.reps, max: s.reps)
                let p = (Float(s.percent) / 100.0) * parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: nil)
                sets.append(set)
            }

            for (i, s) in info.workset.enumerated() {
                let k = PlanSet.Kind.workset(index: i, count: info.workset.count)
                let r: Int? = if let last = workout.entries.last, last.name == name, i == info.workset.count - 1 {
                    nil     // don't use rest for the last set of the last exercise in a workout
                } else {
                    rest ?? self.rest(program, workout)
                }

                let e = if i < info.workset.count - 1 {
                    PlanSet.Amount.reps(min: s.reps, max: s.reps)
                } else {
                    PlanSet.Amount.amrap(min: s.reps)
                }
                let p = if i < info.workset.count - 1 {
                    (Float(s.percent) / 100.0) * parentPercent
                } else {
                    computePercent(reps: s.reps) ?? 1.0
                }
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: r)
                sets.append(set)
            }
        case .manual(let info), .variable(let info):
            let b = findBaseWeight(program)
            for (i, s) in info.warmup.enumerated() {
                let k = PlanSet.Kind.warmup(index: i, count: info.warmup.count)
                let e = PlanSet.Amount.reps(min: s.reps, max: s.reps)
                let p = (Float(s.percent) / 100.0) * parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: nil)
                sets.append(set)
            }
            for (i, s) in info.workset.enumerated() {
                let k = PlanSet.Kind.workset(index: i, count: info.workset.count)
                let r: Int? = if let last = workout.entries.last, last.name == name, i == info.workset.count - 1 {
                    nil     // don't use rest for the last set of the last exercise in a workout
                } else {
                    rest ?? self.rest(program, workout)
                }
                let m = findMinVariable(model, program, s, i)
                let e = PlanSet.Amount.reps(min: m, max: s.maxReps)
                let p = parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: r)
                sets.append(set)
            }
        case .durations(let info):
            let b = findBaseWeight(program)
            for (i, s) in info.secs.enumerated() {
                let k = PlanSet.Kind.workset(index: i, count: info.secs.count)
                let e = PlanSet.Amount.duration
                let p = parentPercent
                let w = findActualWeight(model, program, p)
                let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: s)
                sets.append(set)
            }
        case .missing:
            let k = PlanSet.Kind.workset(index: 0, count: 1)
            let e = PlanSet.Amount.reps(min: 5, max: 5)
            let p = parentPercent
            let w = findActualWeight(model, program, p)
            let b = findBaseWeight(program)
            let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: rest)
            sets.append(set)
        case .timed:
            let k = PlanSet.Kind.timed
            let e = PlanSet.Amount.timed
            let p = parentPercent
            let w = findActualWeight(model, program, p)
            let b = findBaseWeight(program)
            let set = PlanSet(kind: k, expected: e, baseWeight: b, percent: p, weight: w, rest: nil)
            sets.append(set)
        }
        
        var filtered: [PlanSet] = []
        for s in sets {
            if case .warmup = s.kind {
                // When the weights are low warmup weights for different sets can be the same. It doesn't make
                // much sense to warmup with the same weight multiple times so we'll strip these out.
                if let newWeight = s.weight, let last = filtered.last, let priorWeight = last.weight {
                    if priorWeight.value() < newWeight.value() {
                        filtered.append(s)
                    }
                } else {
                    filtered.append(s)
                }
            } else if case .workset = s.kind, let last = filtered.last, case .warmup = last.kind, let newWeight = s.weight, let priorWeight = last.weight {
                // Similarly if the last warmup is larger than the first workset we'll drop the warmup.
                if priorWeight.value() >= newWeight.value() {
                    filtered = filtered.dropLast()
                }
                filtered.append(s)
            } else {
                filtered.append(s)
            }
        }
        return filtered
    }
    
    func validateStyle(_ program: Program) -> Bool {
        var valid = true
        let b = findBaseWeight(program)
        switch program.findStyle(self.styleName) {
        case .amrap:
            if b == nil { // other
                print("Program \(program.name) exercise \(name) is missing a base weight (it's AMRAP style)")
                valid = false
            }
        case .basic:
            if b == nil {
                print("Program \(program.name) exercise \(name) is missing a base weight (it's basic style)")
                valid = false
            }
        case .durations:
            break
        case .manual:
            if b == nil {
                print("Program \(program.name) exercise \(name) is missing a base weight (it's manual style)")
                valid = false
            }
        case .missing:
            print("Program \(program.name) exercise \(name) is the missing style)")
            valid = false
        case .oneRepMax:
            if b == nil {
                print("Program \(program.name) exercise \(name) is missing a base weight (it's one rep max style)")
                valid = false
            }
        case .timed:
            break
        case .variable:
            if b == nil {
                print("Program \(program.name) exercise \(name) is missing a base weight (it's variable style)")
                valid = false
            }
        }
        if case .other = self.baseWeight {
            var count = 0
            for w in program.workouts { // logic needs to match findOtherExercise
                for n in w.entries {
                    if let e = program.findExercise(n.name), e.formalName == formalName {
                        if case .weight = e.baseWeight {
                            count += 1
                        }
                    }
                }
            }
            if count != 1 {
                print("Program \(program.name) exercise \(name) has \(count) other exercises (expected 1)")
                valid = false
            }
        }
        return valid
    }
    
    func usesOther(_ program: Program) -> Bool {
        if case .other = self.baseWeight {
            return true
        }
        return false
    }
        
    private func findActualWeight(_ model: Model, _ program: Program, _ percent: Float) -> ActualWeight? {
        if let b = findBaseWeight(program) {
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
        case .basic(let info):
            return info.rest
        case .durations:
            return nil
        case .manual(let info):
            return info.rest
        case .missing:
            return nil
        case .oneRepMax(let info):
            return info.rest
        case .timed:
            return nil
        case .variable(let info):
            return info.rest
        }
    }
    
    func findBaseWeight(_ program: Program) -> Float? {
        switch baseWeight {
        case .none:
            return nil
        case .other:
            if let (e, _) = findOtherExercise(program) {    // TODO validate should verify that there is only one match
                return e.findBaseWeight(program)
            } else {
                return nil
            }
        case .weight(let w):
            return w
        }
    }

    // Return the first exercise with the same formalName that doesn't use percent style.
    func findOtherExercise(_ program: Program) -> (Exercise, Workout)? {
        for w in program.workouts {
            for n in w.entries {
                if let e = program.findExercise(n.name), e.formalName == formalName {
                    if case .weight = e.baseWeight {
                        return (e, w)
                    }
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

fileprivate func parsePercentReps(_ text: String) -> Result<[PercentReps], MyError> {
    var reps: [PercentReps] = []
    for s in text.split(separator: " ") {
        if let r = PercentReps(String(s)) {
            reps.append(r)
        } else {
            let err = MyError(err: "Expected a number for reps and an optional percent, e.g. 5/80, not '\(s)'.")
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

