/// Type specific data associated with an Exercise.
enum ExerciseData: Codable {
    /// An exercise that is performed for a fixed number of seconds, e.g. a plank.
    case durations(DurationsData)
    
    /// An exercise that uses weights that are a percentage of a base exercise, e.g. a light squat.
    case percent(PercentData)
    
    /// An exercise that is done for either a fixed amount of reos, a variable amount of reps,
    /// or As Many Reps As Possible, e.g. a heavy squat.
    case reps(RepsData)
    
    /// An exercise that is performed for an indefinite amount of time, e.g. jogging.
    case timed
}

struct DurationsData: Codable {
    var secs: [Int]
    var targetSecs: Int?    // TODO support this? support progression somehow?
    
    init(secs: [Int], targetSecs: Int? = nil) {
        self.secs = secs
        self.targetSecs = targetSecs
    }
}

struct PercentData: Codable {
    /// The name of another exercise.
    var other: String
    
    /// The weight for this exercise will be the last completed weight for the above named
    /// exercise multipled by this percent.
    var percent: Int
    
    var warmups: [FixedReps]
    var workset: [VariableRep]
    
    /// Seconds to rest for worksets.
    var rest: Int?
    var version: Int = 1
    
    var isVariable: Bool {
        for s in workset {
            switch s {
            case .amrap(_): return true
            case .fixed: break
            case .variable(_, _): return true
            }
        }
        return false
    }
}

struct RepsData: Codable {
    var warmups: [FixedReps]
    var workset: [VariableRep]
    var backoff: [FixedReps]        // TODO might be nice to make this variable tho it would need min, max, and percent. expected might be weird too
    var version: Int = 1
    
    /// Seconds to rest for worksets.
    var rest: Int?

    var isVariable: Bool {
        for s in workset {
            switch s {
            case .amrap(_): return true
            case .fixed: break
            case .variable(_, _): return true
            }
        }
        return false
    }
        
    init(warmups: [FixedReps], worksets: [VariableRep], backoff: [FixedReps], rest: Int? = nil) {
        self.warmups = warmups
        self.workset = worksets
        self.backoff = backoff
        self.rest = rest
    }
}

struct FixedReps: Codable {
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

enum VariableRep: Codable {
    case amrap(Int)
    case fixed(Int)
    case variable(Int, Int)
    
    /// Parse a string formatted as "5", "8-12", or "3+".
    init?(_ str: String) {
        if str.contains("-") {
            let parts = str.split(separator: "-")
            guard parts.count == 2 else {return nil}
            guard let min = Int(parts[0]) else {return nil}
            guard let max = Int(parts[1]) else {return nil}
            self = .variable(min, max)
        } else if str.last == "+" {
            let s = str.dropLast(1)
            guard let reps = Int(s) else {return nil}
            self = .amrap(reps)
        } else {
            guard let reps = Int(str) else {return nil}
            self = .fixed(reps)
        }
    }
    
    func asString() -> String {
        switch self {
        case .amrap(let r): return "\(r)+"
        case .fixed(let r): return "\(r)"
        case .variable(let min, let max): return "\(min)-\(max)"
        }
    }
}
