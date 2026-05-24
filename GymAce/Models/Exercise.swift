import Foundation

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

enum VariableRep: Codable {
    case amrap(Int)
    case fixed(Int)
    case variable(Int, Int)
}

struct RepsData: Codable {
    var warmups: [FixedReps]
    var workset: [VariableRep]
    var backoff: [FixedReps]
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
        
    enum CodingKeys: String, CodingKey {
        case warmups, workset, backoff, version, rest
    }

    init(warmups: [FixedReps], worksets: [VariableRep], backoff: [FixedReps], rest: Int? = nil) {
        self.warmups = warmups
        self.workset = worksets
        self.backoff = backoff
        self.rest = rest
    }
}

struct PercentData: Codable {
    /// The name of another exercise.
    var other: String
    
    /// The weight for this exercise will be the last completed weight for the above named
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
    
    /// Record of when and what the user did for a workout.
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
                var a: [VariableRep] = []
                for i in 0..<r.workset.count {
                    let r = findExpected(self, r.workset[i], i)
                    a.append(r)
                }
                let b = a.map {
                    switch $0 {
                    case .amrap(let r): 
                        "\(r)+"
                    case .fixed(let r):
                        if r == 1 {
                            "1 rep"
                        } else {
                            "\(r) reps"
                        }
                    case .variable(let min, let max):
                        "\(min)-\(max) reps"
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
