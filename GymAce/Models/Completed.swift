import Foundation

enum ValueType: Codable {
    case reps
    case secs
}

/// Saved in Exercise.history to record what the user actually did after performing an exercise.
struct Completed: Codable, Comparable, Equatable {
    var values: [Int]
    var type: ValueType
    var weight: Float?
    var units: Units
    var completed: Date
    
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
    
    init(reps: [Int], weight: Float?, units: Units, completed: Date = Date()) {
        self.values = reps
        self.type = .reps
        self.weight = weight
        self.units = units
        self.completed = completed
    }
    
    init(secs: [Int], weight: Float?, units: Units, completed: Date = Date()) {
        self.values = secs
        self.type = .secs
        self.weight = weight
        self.units = units
        self.completed = completed
    }
    
    init(values: [Int], type: ValueType, weight: Float?, units: Units, completed: Date = Date()) {
        self.values = values
        self.type = type
        self.weight = weight
        self.units = units
        self.completed = completed
    }
    
    /// Used to show the user what happened for that workout.
    func details() -> String {
        return completedDetails(values, type, weight, units)
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

func completedDetails(_ values: [Int], _ type: ValueType, _ weight: Float?, _ units: Units) -> String {
    if values.isEmpty {
        return ""
    }
    var trailer = ""
    if let w = weight {
        trailer = " @ " + formatWeight(w, units)
    }

    switch type {
    case .reps:
        let labels = values.map {"\($0)"}
        return joinLabels(labels) + " reps" + trailer
    case .secs:
        let labels = values.map {secsToStr($0)}
        return joinLabels(labels) + trailer
    }
}
