import Foundation
import SwiftData

enum CompletedSet: Codable {
    /// seconds
    case duration(Int)

    /// rep count
    case reps(Int)

//    /// rep count and percent
//    case percent(Int, Int)
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

@Model
final class DurationsData {
    var secs: [Int]
    var targetSecs: Int?
    
    init(secs: [Int], targetSecs: Int? = nil) {
        self.secs = secs
        self.targetSecs = targetSecs
    }
}

// These are Codable instead of @Model so that arrays of them are stable.
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

@Model
final class RepsData {
    var warmups: [FixedReps]
    var worksets: [VariableReps]
    var backoff: [FixedReps]
    
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

// TODO
// will there be schema migration issues if new cases are added?
// add a percentage based exercise, should be based on last completed for another exercise
//
// Ideally this would be an enum but enums can't be models, just codables. Codeable would
// work for relatively sumple enums but we really want to bind to this state so this
// awkward model seems better.
//
/// How to perform an exercise. These are added to workouts using ExerciseEntry.
@Model
final class Exercise {
    /// User name, used to identify an exercise for workouts to use.
    var name: String
//    @Attribute(.unique) var name: String  // TODO was getting errors trying to save with this enabled

    /// Official name, used to lookup notes for an exercise
    var formalName: String
    
    /// Opitional set of weights to use with the exercise.
    var weightSet: WeightSet?

    /// Base weight to use for each workset. If a weightSet is present then this weight will be mapped
    /// onto those weights (possibly modified by a per-set percentage).
    var weight: Float?
    
    /// Record of when and how well the user last did the exercise. Note that these are not sorted.
    var history: [Completed] = []
    
    // TODO add these
//    pub rest: Option<i32>,   // used for work sets
//    pub last_rest: Option<i32>, // overrides rest.last()

    /// An exercise that is performed for a set amount of time, e.g. stretching.
    var durations: DurationsData?
    
    /// An exercise that is either done for a fixed amount of reps, e.g. 3x5 bench press
    /// or a rep range, e.g. 3x8-12 cable crunches.
    var reps: RepsData?
    
    @Transient private var sortedHistory = false

    init (name: String, formalName: String, durations: DurationsData? = nil, reps: RepsData? = nil, weights: WeightSet? = nil, weight: Float? = nil) {
        self.name = name
        self.formalName = formalName
        self.weightSet = weights
        self.weight = weight
        self.durations = durations
        self.reps = reps
    }
    
    /// Shown in WorkoutView next to the exercise name: brief summary of what the user is expected to do.
    /// For example, "30sx3" or "8-12x3 @ 135 lbs".
    func details() -> String {
        var suffix = ""
        if let weight = self.weight {
            if let ws = self.weightSet {
                let actual = ws.lower(target: weight)
                suffix = " @ \(actual.text())"
            } else {
                suffix = " @ \(formatWeight(weight, .None))"
            }
        }
        
        if let durations = self.durations {
            let a = durations.secs.map {"\($0)s"}
            return joinLabels(a) + suffix
        }
        if let reps = self.reps {
            let a = reps.worksets.map {
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
        }
        return ""
    }
    
    func latestCompleted() -> Completed? {
        if !sortedHistory {
            history.sort()
            sortedHistory = true
        }
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
