///// Type specific data associated with an Exercise.
//enum ExerciseData: Codable {
//    /// An exercise that is performed for a fixed number of seconds, e.g. a plank.
//    case durations(DurationsData)
//    
//    /// These are always done for one set with 1-12 reps. After completing this the weight is
//    /// updated to an estimate of the user's one rep max.
//    case oneRepMax(OneRepMaxData)
//    
//    /// An exercise that uses weights that are a percentage of a base exercise, e.g. a light squat.
//    case percent(PercentData)
//    
//    /// An exercise that is done for either a fixed amount of reos, a variable amount of reps,
//    /// or As Many Reps As Possible, e.g. a heavy squat.
//    case reps(RepsData)
//    
//    /// An exercise that is performed for an indefinite amount of time, e.g. jogging.
//    case timed
//    
//    func numSets() -> Int {
//        switch self {
//        case .durations(let d): return d.secs.count
//        case .oneRepMax(let d): return d.warmups.count + 1
//        case .percent(let d): return d.warmups.count + d.workset.count
//        case .reps(let d): return d.warmups.count + d.workset.count + d.backoff.count
//        case .timed: return 1
//        }
//    }
//}
//
//struct DurationsData: Codable {
//    var secs: [Int]
//    var targetSecs: Int?
//    
//    init(secs: [Int], targetSecs: Int? = nil) {
//        self.secs = secs
//        self.targetSecs = targetSecs
//    }
//}
//
//struct OneRepMaxData: Codable {
//    var warmups: [FixedReps]
//        
//    init(warmups: [FixedReps]) {
//        self.warmups = warmups
//    }
//}
//
//struct PercentData: Codable {
//    /// The name of another exercise.
//    var other: String
//    
//    /// The weight for this exercise will be the last completed weight for the above named
//    /// exercise multipled by this percent.
//    var percent: Int
//    
//    var warmups: [FixedReps]
//    var workset: [VariableReps]
//    
//    var version: Int = 1
//    
//    var isVariable: Bool {
//        for s in workset {
//            switch s {
//            case .amrap(_, _): return true
//            case .fixed: break
//            case .variable(_, _): return true
//            }
//        }
//        return false
//    }
//}
//
//struct RepsData: Codable {
//    var warmups: [FixedReps]
//    var workset: [VariableReps]
//    var backoff: [FixedReps]        // TODO might be nice to make this variable tho it would need min, max, and percent. expected might be weird too
//    var version: Int = 1
//    
//    var isVariable: Bool {
//        for s in workset {
//            switch s {
//            case .amrap(_, _): return true
//            case .fixed: break
//            case .variable(_, _): return true
//            }
//        }
//        return false
//    }
//        
//    init(warmups: [FixedReps], worksets: [VariableReps], backoff: [FixedReps]) {
//        self.warmups = warmups
//        self.workset = worksets
//        self.backoff = backoff
//    }
//}

// TODO rename this file, maybe to Sets

/// Used for warmup and backoff sets.
struct OtherReps: Codable {
    var reps: Int
    var percent: Int
    
    init(reps: Int, percent: Int) {
        self.reps = reps
        self.percent = percent
    }

    /// Parse a string formatted as "5/80".
    init?(_ str: String) {
        let parts = str.split(separator: "/")
        guard parts.count == 2 else {return nil}
        guard let reps = Int(parts[0]) else {return nil}
        guard let percent = Int(parts[1]) else {return nil}
        
        self.reps = reps
        self.percent = percent
    }
    
    func asString() -> String {
        return "\(reps)/\(percent)"
    }
}

/// Used for worksets with amrap style.
struct PercentReps: Codable {
    var reps: Int
    var percent: Int
    
    init(reps: Int, percent: Int) {
        self.reps = reps
        self.percent = percent
    }

    /// Parse a string formatted as "5" or "5/80".
    init?(_ str: String) {
        let parts = str.split(separator: "/")
        if parts.count == 1 {
            guard let reps = Int(str) else {return nil}
            self.reps = reps
            self.percent = 100
        } else {
            guard parts.count == 2 else {return nil}
            guard let reps = Int(parts[0]) else {return nil}
            guard let percent = Int(parts[1]) else {return nil}
            self.reps = reps
            self.percent = percent
        }
    }
    
    func asString() -> String {
        if percent == 100 {
            return "\(reps)"
        } else {
            return "\(reps)/\(percent)"
        }
    }
}

/// Used for work sets with variable style.
struct VariableReps: Codable {
    var minReps: Int
    var maxReps: Int
    var percent: Int

    init(minReps: Int, maxReps: Int, percent: Int) {
        self.minReps = minReps
        self.maxReps = maxReps
        self.percent = percent
    }

    /// Parse a string formatted as "5" or  "4-8" with an optional percent suffix like "/80".
    init?(_ str: String) {
        var text = str
        var percent = 100
        if str.contains("/") {
            let parts = str.split(separator: "/")
            guard parts.count == 2 else {return nil}
            guard let p = Int(parts[1]) else {return nil}
            text = String(parts[0])
            percent = p
        }
        
        if text.contains("-") {
            let parts = text.split(separator: "-")
            guard parts.count == 2 else {return nil}
            guard let min = Int(parts[0]) else {return nil}
            guard let max = Int(parts[1]) else {return nil}
            guard min <= max else {return nil}
            self.minReps = min
            self.maxReps = max
        } else {
            guard let reps = Int(text) else {return nil}
            self.minReps = reps
            self.maxReps = reps
        }
        self.percent = percent
    }
    
    func asString() -> String {
        if minReps == maxReps {
            if percent == 100 {
                return "\(minReps)"
            } else {
                return "\(minReps)/\(percent)"
            }
        } else {
            if percent == 100 {
                return "\(minReps)-\(maxReps)"
            } else {
                return "\(minReps)-\(maxReps)/\(percent)"
            }
        }
    }
}
