import Foundation

/// How to perform an exercise. These are added to workouts using ExerciseEntry.
@Observable
final class Exercise: Codable {
    /// The name shown in the workout view.
    var name: String

    /// Official name, used to lookup notes for an exercise.
    var formalName: String

    /// How to perform the exercise.
    var styleName: String
    
    /// Optional set of weights to use with the exercise.
    var weightSet: String?

    /// The weight to use for an exercise before percentage modifiers are applied. This may be
    /// nil for exercises like stretches or styles like percent or gzcl where the baseWeight of an
    /// "other" exercise is used.
    var baseWeight: Float?
    
    /// Record of when and what the user did for a workout. Last is the most recent.
    var history: [Completed] = []
        
    var version: Int = 1

    init (name: String, formalName: String, styleName: String, weights: String? = nil, weight: Float? = nil) {
        self.name = name
        self.formalName = formalName
        self.styleName = styleName
        self.weightSet = weights
        self.baseWeight = weight
    }
        
    func fixup() {
//        if name == "Chin Ups" {
//            if var c = history.last {
//                c.weight = 0.0
//            }
//        }
    }
        
    func valid(_ model: Model, _ program: Program) -> Bool {
        var valid = true
        if !model.notes.has(formalName) {
            print("Program \(program.name) formal name \(formalName) is missing for exercise \(name)")
            valid = false
        }
        if let ws = weightSet {
            if model.weightSets[ws] == nil {
                if let p = model.active(), p.name == program.name { // we only add weight sets for the active program
                    print("Program \(program.name) weight set \(ws) is missing for exercise \(name)")
                    valid = false
                }
            }
        }
        if !validateStyle(program) {
            valid = false
        }
        return valid
    }

    func latestCompleted() -> Completed? {
        return history.last
    }
}

/// Takes arrays like ["10s", "10s", "30s"] and converts them into "10s x2, 30s"
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
//            if let c = $0.1.last, c.isNumber {
//                "\($0.1)x\($0.0)"
//            } else {
                "\($0.1) x\($0.0)"
//            }
        }
    }.joined(separator: ", ")
}

/// Takes arrays like [10, 10, 5] and converts them into "2x10, 5"
func joinReps(_ labels: [String]) -> String {
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
