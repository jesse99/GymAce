import Foundation
import SwiftData

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
}

@Model
final class RepsData {
    var warmups: [FixedReps]
    var worksets: [VariableReps]
    var backoff: [FixedReps]     // TODO support this
    
    // I think here what we want is:
    // if the current weight matches last completed then use last completed reps
    //    but clamp to current min/max
    // if current weight is larger than last completed then use min reps
    // otherwise use max reps
//    var expected: [Int]
    
    init(warmups: [FixedReps], worksets: [VariableReps], backoff: [FixedReps]) {
        self.warmups = warmups
        self.worksets = worksets
        self.backoff = backoff
    }
}

// TODO
// will there be schema migration issues if new cases are added?
// add a percentage based exercise, should be based on last completed for another exercise
//
// Ideally this would be an enum but enums can't be models, just codables. Codeable would
// work for relatively sumple enums but we really want to bind to this state so this
// awkward model seems better.
@Model
final class Exercise {
    /// User name, just for presentation
    var name: String

    /// Official name, used to lookup notes for an exercise
    var formalName: String

    /// Model array ordering isn't stable so this is used to sort the exercises into
    /// the order the user wants to use.
    var order: Int
    
    /// The set the user is currently performing in an exercise screen (this doesn't
    /// belong to the view because we want the user to be able to go to another
    /// exercise to super set or goto settings without losing their place). Note that
    /// if this is >= the number of sets the user is considered to have finished the
    /// exercise.
    var setIndex: Int
    
    // TODO add these
//    pub started: Option<DateTime<Local>>,
//    pub finished: bool,
//    pub enabled: bool,
//    pub current_index: SetIndex,
//    pub weightset: Option<String>,
//    pub weight: Option<f32>, // base weight to use for each workset, often modified by per-set percent
//    pub rest: Option<i32>,   // used for work sets
//    pub last_rest: Option<i32>, // overrides rest.last()

    /// An exercise that is performed for a set amount of time, e.g. stretching.
    var durations: DurationsData?
    
    /// An exercise that is either done for a fixed amount of reps, e.g. 3x5 bench press
    /// or a rep range, e.g. 3x8-12 cable crunches.
    var reps: RepsData?
    
    init (name: String, formalName: String, order: Int, durations: DurationsData? = nil, reps: RepsData? = nil) {
        self.name = name
        self.formalName = formalName
        self.order = order
        self.durations = durations
        self.reps = reps
        self.setIndex = 0
    }
    
    func finished() -> Bool {
        if let durations = self.durations {
            return setIndex >= durations.secs.count
        }
        if let reps = self.reps {
            return setIndex >= reps.warmups.count + reps.worksets.count + reps.backoff.count
        }
        return true
    }
    
    // Shown first in the exercise view, e.g. "Workset 1 of 3" or "Set 1 of 3".
    func headline() -> String {
        var index = fixedIndex()
        if let durations = self.durations {
            return "Set \(index + 1) of \(durations.secs.count)"
        }
        if let reps = self.reps {
            if index < reps.warmups.count {
                return "Warmup \(index + 1) of \(reps.warmups.count)"
            }
            index -= reps.warmups.count
            
            if index < reps.worksets.count {
                return "Workset \(index + 1) of \(reps.worksets.count)"
            }
            index -= reps.worksets.count

            if index < reps.backoff.count {
                return "Backoff \(index + 1) of \(reps.backoff.count)"
            }
        }
        return "Set \(index + 1)?"
    }
    
    // Shown second in the exercise view, e.g. "5 reps at 140 lbs" or "30s".
    func subhead() -> String {
        // TODO all of these should include weights
        let index = fixedIndex()
        if let durations = self.durations {
            return secsToStr(durations.secs[index])
        }
        if let reps = self.reps {
            var index = index
            if index < reps.warmups.count {
                return "\(reps.warmups[index].reps) reps"
            }
            index -= reps.warmups.count
            
            if index < reps.worksets.count {
                if reps.worksets[index].min == reps.worksets[index].max {
                    return "\(reps.worksets[index].min) reps"
                } else {
                    // TODO do a better job with expected reps
                    return "\(reps.worksets[index].min)-\(reps.worksets[index].max) reps"
                }
            }
            index -= reps.worksets.count

            if index < reps.backoff.count {
                return "\(reps.backoff[index].reps) reps"
            }
        }
        return "?"
    }
    
    // Shown third in the exercise view, e.g. "45 + 2.5".
    func footer() -> String? {
        // TODO need to use the current weightset
        return "45 + 2.5"
    }
    
    // Shown fourth in the exercise view, e.g. "90% of 225 lbs".
    func subfooter() -> String? {
        // TODO need to use the current percent and weightset
        return "90% of 225 lbs"
    }
    
    /// Shown in WorkoutView next to the exercise name: brief summary of what the user is expected to do,
    func details() -> String {
        if let durations = self.durations {
            let a = durations.secs.map {"\($0)s"}
            return joinLabels(a)
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
            return joinLabels(a)
        }
        return ""
    }
    
    private func fixedIndex() -> Int {
        if let durations = self.durations {
            return setIndex >= durations.secs.count ? durations.secs.count - 1 : setIndex
        }
        if let reps = self.reps {
            let count = reps.warmups.count + reps.worksets.count + reps.backoff.count
            return setIndex >= count ? count - 1 : setIndex
        }
        return setIndex
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
    "\(secs)s"          // TODO handle longer times better
}
