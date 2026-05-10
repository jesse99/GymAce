import Foundation

enum CompletedSet: Codable {
    /// seconds
    case duration(Int)

    /// rep count
    case reps(Int)

    /// rep count
    case percent(Int)
}

struct Completed: Codable, Comparable, Equatable {
    var sets: [CompletedSet]
    var weight: Float?
    var started: Date
    var completed: Date?
    
    /// Returns true if the exercise was started long enough ago that it should be considered an exercise
    /// that the user has abandoned.
    var isStale: Bool {
        let delta = started.distance(to: Date.now)
        return delta/3600.0 > 4.0   // aka more than 4 hours
    }
    
    init(weight: Float?) {
        self.sets = []
        self.weight = weight
        self.started = Date()
        self.completed = nil
    }
    
    static func ==(lhs: Completed, rhs: Completed) -> Bool {
        if let l = lhs.completed, let r = rhs.completed {
            return l == r
        }
        return rhs.completed == nil && rhs.completed == nil
    }

    static func <(lhs: Completed, rhs: Completed) -> Bool {
        if let l = lhs.completed, let r = rhs.completed {
            return l < r
        }
        if rhs.completed == nil {
            return true
        }
        return false
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

struct FixedReps: Codable {
    var reps: Int
    var percent: Int
}

struct VariableReps: Codable {
    var min: Int
    var max: Int
    
    init(_ reps: Int) {
        self.min = reps
        self.max = reps
    }

    init(_ min: Int, to: Int) {
        self.min = min
        self.max = to
    }
    
    func clamp(_ n: Int) -> Int {
        if n < min {
            return min
        } else if n > max {
            return max
        }
        return n
    }
}

struct RepsData: Codable {
    var warmups: [FixedReps]
    var worksets: [VariableReps]
    var backoff: [FixedReps]
    var version: Int = 1
    
    /// Seconds to rest for worksets.
    var rest: Int?

    var isVariable: Bool {
        worksets.contains(where: { $0.min < $0.max })
    }
        
    init(warmups: [FixedReps], worksets: [VariableReps], backoff: [FixedReps], rest: Int? = nil) {
        self.warmups = warmups
        self.worksets = worksets
        self.backoff = backoff
        self.rest = rest
    }
}

struct PercentData: Codable {
    /// The name of another exercise.
    var other: String
    
    /// The weight for this exercise will be the last completed weight for the above names
    /// exercise multipled by this percent.
    var percent: Int
    
    var warmups: [FixedReps]
    var worksets: [Int]

    /// Seconds to rest for worksets.
    var rest: Int?
    var version: Int = 1
}

enum ExerciseData: Codable {
    case durations(DurationsData)
    case reps(RepsData)
    case percent(PercentData)
}

/// How to perform an exercise. These are added to workouts using ExerciseEntry.
@Observable
final class Exercise: Codable {
    /// The name shown in the workout view.
    var name: String

    /// Official name, used to lookup notes for an exercise
    var formalName: String
    
    /// Optional set of weights to use with the exercise.
    var weightSet: String?

    /// Base weight to use for each workset. If a weightSet is present then this weight will be mapped
    /// onto those weights (possibly modified by a per-set percentage).
    var weight: Float?
    
    /// Record of when and how well the user last did the exercise.
    var history: [Completed] = []
    
    /// Exercise specific data.
    var data: ExerciseData
    
    var enabled: Bool = true    // TODO support this

    var version: Int = 1

    init (name: String, formalName: String, durations: DurationsData, weights: String? = nil, weight: Float? = nil) {
        self.name = name
        self.formalName = formalName
        self.weightSet = weights
        self.weight = weight
        self.data = .durations(durations)
    }
    
    init (name: String, formalName: String, reps: RepsData, weights: String? = nil, weight: Float? = nil) {
        self.name = name
        self.formalName = formalName
        self.weightSet = weights
        self.weight = weight
        self.data = .reps(reps)
    }
    
    init (name: String, formalName: String, percent: PercentData, weights: String? = nil, weight: Float? = nil) {
        self.name = name
        self.formalName = formalName
        self.weightSet = weights
        self.data = .percent(percent)
    }
    
    /// Find the weight the user should use for this exercise. Normally this is just self.weight but
    /// for percent exercises it'll be different.
    func findWeight(_ program: Program) -> Float? {
        switch self.data {
        case .reps(_), .durations(_):
            if let weight = self.weight {
                return weight
            }
        case .percent(let d):
            if let other = program.findExercise(d.other) {
                if let completed = other.latestCompleted() {
                    if let weight = completed.weight {
                        return Float(d.percent) * weight / 100.0
                    }
                }
                
                // If no completed then fall back on expected weight.
                if let weight = other.findWeight(program) {
                    return Float(d.percent) * weight / 100.0
                }
            }
        }
        return nil
    }
    
    /// Shown in WorkoutView next to the exercise name: brief summary of what the user is expected to do.
    /// For example, "30sx3" or "8-12x3 @ 135 lbs".
    func details(_ model: Model, _ program: Program) -> String {
        var suffix = ""
        if let weight = findWeight(program) {
            if let name = weightSet, let ws = model.weightSets[name] {
                let actual = ws.lower(target: weight)
                suffix = " @ \(actual.text())"
            } else {
                suffix = " @ \(formatWeight(weight, .None))"
            }
        }
        switch data {
            case .reps(let r):
                let a = r.worksets.map {
                    if $0.min == $0.max {
                        if $0.max == 1 {
                            "1 rep"
                        } else {
                            "\($0.min) reps"
                        }
                    } else {
                        "\($0.min)-\($0.max) reps"
                    }
                }
                return joinLabels(a) + suffix
            case .durations(let d):
                let a = d.secs.map {"\($0)s"}
                return joinLabels(a) + suffix
            case .percent(let d):
                let a = d.worksets.map {
                    if $0 == 1 {
                        "1 rep"
                    } else {
                        "\($0) reps"
                    }
                }
                return joinLabels(a) + suffix
        }
    }
    
    func latestCompleted() -> Completed? {
        return history.last
    }
}

/// Takes arrays like ["10s", "10s", "30s"] and converts them into "2x10s, 30s"
func joinLabels(_ labels: [String]) -> String {
    var parts: [(Int, String)] = []
    
    for label in labels {
        if let last = parts.last, last.1 == label {
            parts[parts.count-1].0 += 1
        } else {
            parts.append((1, label))
        }
    }
    
    return parts.map {
        if $0.0 == 1 {
            $0.1
        } else {
            "\($0.0)x\($0.1)"
        }
    }.joined(separator: ", ")
}

func secsToStr(_ secs: Int) -> String {
    if secs > 60*60 {
        let n = Float(secs)/(60.0*60.0)
        return String(format: "%.1f hours", n)
    } else if secs > 60 {
        let n = Float(secs)/60.0
        return String(format: "%.1f mins", n)
    } else if secs == 1 {
        return "1 sec"
    } else {
        return "\(secs) secs"
    }
}
