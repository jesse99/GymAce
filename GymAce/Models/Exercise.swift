import Foundation

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
    
    /// Record of when and what the user did for a workout. Last is the most recent.
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

    init (name: String, formalName: String, weights: String? = nil, weight: Float? = nil) {
        self.name = name
        self.formalName = formalName
        self.weightSet = weights
        self.data = .timed
    }
    
    func fixup() {
//        if name == "Chin Ups" {
//            if var c = history.last {
//                c.weight = 0.0
//            }
//        }
    }
        
    /// Find the weight the user should use for this exercise. Normally this is just self.weight but
    /// for percent exercises it'll be different.
    func findWeight(_ program: Program) -> Float? {
        switch self.data {
        case .reps(_), .durations(_), .timed:
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
            case .reps(let d):
                var a: [String] = []
                for i in 0..<d.workset.count {
                    let n = findExpected(self, d.workset[i], i)
                    switch d.workset[i] {
                    case .amrap(_, _):
                        a.append("\(n)+")
                    case .fixed(_, _):
                        if n == 1 {
                            a.append("1 rep")
                        } else {
                            a.append("\(n) reps")
                        }
                    case .variable(_, let max):
                        if n == max {
                            a.append("\(max) reps")
                        } else {
                            a.append("\(n)-\(max) reps")
                        }
                    }
                }
                return joinLabels(a) + suffix
            case .durations(let d):
                let a = d.secs.map {secsToShortStr($0)}
                return joinLabels(a) + suffix
            case .percent(let d):
                var a: [String] = []
                for i in 0..<d.workset.count {
                    let n = findExpected(self, d.workset[i], i)
                    switch d.workset[i] {
                    case .amrap(_, _):
                        a.append("\(n)+")
                    case .fixed(_, _):
                        if n == 1 {
                            a.append("1 rep")
                        } else {
                            a.append("\(n) reps")
                        }
                    case .variable(_, let max):
                        if n == max {
                            a.append("\(max) reps")
                        } else {
                            a.append("\(n)-\(max) reps")
                        }
                    }
                }
                return joinLabels(a) + suffix
            case .timed:
            if let c = history.last {
                return c.details()
            } else {
                return ""
            }
        }
    }
    
    func latestCompleted() -> Completed? {
        return history.last
    }
}

/// Takes arrays like ["10s", "10s", "30s"] and converts them into "10sx2, 30s"
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
            if let c = $0.1.last, c.isNumber {
                "\($0.1)x\($0.0)"
            } else {
                "\($0.1) x\($0.0)"
            }
        }
    }.joined(separator: ", ")
}

func secsToLongStr(_ secs: Int) -> String {
    if secs > 60*60 {
        let n = Float(secs)/(60.0*60.0)
        return String(format: "%.2f hours", n)
    } else if secs > 60 {
        let n = Float(secs)/60.0
        return String(format: "%.1f mins", n)
    } else if secs == 1 {
        return "1 sec"
    } else {
        return "\(secs) secs"
    }
}

func secsToShortStr(_ secs: Int) -> String {
    if secs > 60*60 {
        let n = Float(secs)/(60.0*60.0)
        return String(format: "%.1fh", n)
    } else if secs > 60 {
        let n = Float(secs)/60.0
        return String(format: "%.1fm", n)
    } else {
        return "\(secs)s"
    }
}

/// Parses strings formatted as 30, 30s, 3.1m, or 10h and returns seconds.
func parseShortSecs(_ str: String) -> Int? {
    var result: Int? = nil
    if str.last == "h" {
        let s = str.dropLast(1)
        if let n = Float(s) {
            result = Int(60.0*60.0*n)
        }
    } else if str.last == "m" {
        let s = str.dropLast(1)
        if let n = Float(s) {
            result = Int(60.0*n)
        }
    } else if str.last == "s" {
        let s = str.dropLast(1)
        if let n = Float(s) {
            result = Int(n)
        }
    } else {
        if let n = Float(str) {
            result = Int(n)
        }
    }
    return result
}
