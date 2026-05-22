import Foundation

enum CompletedSet: Codable {
    /// seconds
    case duration(Int)

    /// rep count
    case reps(Int)

    /// rep count
    case percent(Int)
}

func completedDetails(_ sets: [CompletedSet], _ weight: Float?, _ units: Units) -> String {
    if sets.isEmpty {
        return ""
    }
    var trailer = ""
    if let w = weight {
        trailer = " @ " + formatWeight(w, units)
    }

    var labels: [String] = []
    var suffix = ""
    for s in sets {
        switch s {
        case .reps(let r):
            labels.append("\(r)")
            suffix = " reps"
        case .percent(let r):
            labels.append("\(r)")
            suffix = " reps"
        case .duration(let s):
            labels.append(secsToStr(s))
        }
    }
    return joinLabels(labels) + suffix + trailer
}

struct Completed: Codable, Comparable, Equatable {
    var sets: [CompletedSet]
    var weight: Float?
    var units: Units
    var completed: Date
    
    init(sets: [CompletedSet], weight: Float?, units: Units, completed: Date = Date()) {
        self.sets = sets
        self.weight = weight
        self.units = units
        self.completed = completed
    }
    
    /// Used to show the user what happened for that workout.
    func details() -> String {
        return completedDetails(sets, weight, units)
    }
    
    // Returns +1 if self is better than rhs.
    // Returns  0 if self is equal to rhs.
    // Returns -1 if self is worse than rhs.
    func better(_ rhs: Completed) -> Int {
        if let lw = self.weight {
            if let rw = rhs.weight {
                let li = Int(1000.0*lw)
                let ri = Int(1000.0*rw)
                if li > ri {
                    return 1    // left has more weight
                } else if li < ri {
                    return -1   // left has less weight
                }
            } else {
                return 1    // only left has weight
            }
        } else if rhs.weight != nil {
            return -1       // only right has weight
        }
        
        let lc = self.completedReps()
        let rc = rhs.completedReps()
        if lc > rc {
            return 1     // same weights but left did more reps
        } else if lc == rc {
            return 0     // same weights and reps
        } else {
            return -1    // same weights but left did less reps
        }
    }
    
    private func completedReps() -> Int {
        var reps: Int = 0
        for s in self.sets {
            switch s {
            case .reps(let v):
                reps += v
            case .percent(let v):
                reps += v
            case .duration(let v):
                reps += v
            }
        }
        return reps
    }
    
    static func ==(lhs: Completed, rhs: Completed) -> Bool {
        return lhs.completed == rhs.completed
    }

    static func <(lhs: Completed, rhs: Completed) -> Bool {
        return lhs.completed < rhs.completed
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
    
    func fixup() {
//        if self.weightSet == "Dual" {
//            self.weightSet = "Dual Plates"
//        }
//        if name == "Light Bench" {
//            if case .percent(var d) = data, d.rest == nil {
//                d.rest = Int(3.0*60)
//                self.data = .percent(d)
//            }
//        }
//        if name == "Light Squat" {
//            if case .percent(var d) = data, d.rest == nil {
//                d.rest = Int(3.5*60)
//                self.data = .percent(d)
//            }
//        }
//        if name == "Trap Deadlift" {
//            self.weightSet = "Trapbar"
//        }
//        if name == "OHP" {
//            let owarmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//            let reps3 = [VariableReps(3, to: 5), VariableReps(3, to: 5), VariableReps(3, to: 5)]
//            let d = RepsData(warmups: owarmup, worksets: reps3, backoff: [], rest: Int(3.0*60))
//            self.data = .reps(d)
//        }
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
                var a: [(Int, Int)] = []
                for i in 0..<r.worksets.count {
                    let min = findExpected(self, r.worksets[i], i)
                    let max = r.worksets[i].max
                    a.append((min, max))
                }
                let b = a.map {
                    if $0.0 == $0.1 {
                        if $0.1 == 1 {
                            "1 rep"
                        } else {
                            "\($0.0) reps"
                        }
                    } else {
                        "\($0.0)-\($0.1) reps"
                    }
                }
                return joinLabels(b) + suffix
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
