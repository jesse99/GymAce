import Foundation

enum ValueType: Codable {
    case reps
    case secs
}

/// Saved in Exercise.history to record what the user actually did after performing an exercise.
class Completed: Codable, Comparable, Equatable {
    var values: [Int]
    var type: ValueType
    var weights: [Float]?   // these are the same unless the work sets have percentages
    var weight: Float?      // historical
    var units: Units
    var completed: Date
    var distance: Double?   // meters
    var note: String? = nil
    
//    enum CodingKeys: String, CodingKey {
//        case values, type, weight, units, completed
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        if container.contains(.sets) {
//            sets = try container.decode(Array<CompletedSet>.self, forKey: .sets)
//            values = []
//            type = .reps    // in case there are no sets
//            for s in sets {
//                switch s {
//                case .reps(let r):
//                    values.append(r)
//                    type = .reps
//                case .percent(let p):
//                    values.append(p)
//                    type = .reps
//                case .duration(let d):
//                    values.append(d)
//                    type = .secs
//                }
//            }
//
//        } else {
//            sets = []
//            values = try container.decode(Array<Int>.self, forKey: .values)
//            type = try container.decode(ValueType.self, forKey: .type)
//        }
//
//        weight = try container.decodeIfPresent(Float.self, forKey: .weight)
//        units = try container.decode(Units.self, forKey: .units)
//        completed = try container.decode(Date.self, forKey: .completed)
//    }
    
    init(reps: [Int], weights: [Float]?, units: Units, completed: Date = Date()) {
        self.values = reps
        self.type = .reps
        self.weights = weights
        self.weight = nil
        self.units = units
        self.completed = completed
    }
    
    init(secs: [Int], weights: [Float]?, units: Units, completed: Date = Date()) {
        self.values = secs
        self.type = .secs
        self.weights = weights
        self.weight = nil
        self.units = units
        self.completed = completed
    }
    
    init(values: [Int], type: ValueType, weights: [Float]?, units: Units, completed: Date = Date(), distance: Double? = nil) {
        self.values = values
        self.type = type
        self.weights = weights
        self.weight = nil
        self.units = units
        self.completed = completed
        self.distance = distance
    }
    
    /// Used to show the user what happened for that workout.
    func details() -> String {
        return completedDetails(values, type, weights, units, distance)
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
        
        if let ld = self.distance, let rd = rhs.distance {
            if ld > rd {
                return 1     
            } else if ld < rd {
                return -1
            } else {
                return 0
            }
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
    
    static func ==(lhs: Completed, rhs: Completed) -> Bool {
        return lhs.completed == rhs.completed
    }

    static func <(lhs: Completed, rhs: Completed) -> Bool {
        return lhs.completed < rhs.completed
    }
    
    private func completedReps() -> Int {
        return values.reduce(0, +)
    }
}

func weightSuffix(_ weights: [Float]?, _ units: Units) -> String {
    if let min = weights?.min(), let max = weights?.max(), max > 0.0 {
        if min.sameWeight(max) {
            let smin = formatWeight(min, units)
            return " @ \(smin)"
        } else {
            let smin = formatWeight(min, .None)
            let smax = formatWeight(max, units)
            return " @ \(smin)-\(smax)"
        }
    }
    return ""
}

func completedDetails(_ values: [Int], _ type: ValueType, _ weights: [Float]?, _ units: Units, _ distance: Double?) -> String {
    if values.isEmpty {
        return ""
    }
    var trailer = weightSuffix(weights, units)
    if let distance = distance {
        let s = String(format: "%.2f", distance*0.000621371)   // TODO use meters if metric
        trailer += " \(s) miles"
    }

    switch type {
    case .reps:
        let labels = values.map {"\($0) reps"}
        return joinLabels(labels) + trailer
    case .secs:
        let labels = values.map {secsToLongStr($0)}
        return joinLabels(labels) + trailer
    }
}
