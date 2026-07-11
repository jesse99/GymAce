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
    
    func numSets() -> Int {
        switch self {
        case .durations(let d): return d.secs.count
        case .percent(let d): return d.warmups.count + d.workset.count
        case .reps(let d): return d.warmups.count + d.workset.count + d.backoff.count
        case .timed: return 1
        }
    }
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
    var workset: [VariableReps]
    
    /// Seconds to rest for worksets.
    var rest: Int?
    var version: Int = 1
    
    var isVariable: Bool {
        for s in workset {
            switch s {
            case .amrap(_, _): return true
            case .fixed: break
            case .variable(_, _): return true
            }
        }
        return false
    }
}

// TODO
// add a new VariableReps enum that includes percents for fixed and amwap
//    maybe tuple names too
//    custom decoder would try to decode it normally and then fallback to decoding it as VariableRep and then mapping
// worksets would be VariableReps enum
// try on phone
struct RepsData: Codable {
    var warmups: [FixedReps]
    var workset: [VariableReps]
    var backoff: [FixedReps]        // TODO might be nice to make this variable tho it would need min, max, and percent. expected might be weird too
    var version: Int = 1
    
    /// Seconds to rest for worksets.
    var rest: Int?

    var isVariable: Bool {
        for s in workset {
            switch s {
            case .amrap(_, _): return true
            case .fixed: break
            case .variable(_, _): return true
            }
        }
        return false
    }
        
    init(warmups: [FixedReps], worksets: [VariableReps], backoff: [FixedReps], rest: Int? = nil) {
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

enum VariableReps: Codable {
    case amrap(Int, Int = 100)  // minReps, percent
    case fixed(Int, Int = 100)  // reps, percent
    case variable(Int, Int)     // minReps, maxReps
        
    /// Parse a string formatted as "5", "8-12", or "3+" followed by an optional "/90"..
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
            self = .variable(min, max)
        } else if text.last == "+" {
            let s = text.dropLast(1)
            guard let reps = Int(s) else {return nil}
            self = .amrap(reps, percent)
        } else {
            guard let reps = Int(text) else {return nil}
            self = .fixed(reps, percent)
        }
    }
    
    func asString() -> String {
        switch self {
        case .amrap(let r, let p): if p != 100 {return "\(r)+/\(p)"} else {return "\(r)+"}
        case .fixed(let r, let p): if p != 100 {return "\(r)/\(p)"} else {return "\(r)"}
        case .variable(let min, let max): return "\(min)-\(max)"
        }
    }
}
