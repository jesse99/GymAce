import Foundation

// TODO Might want to support bumper plates though that would get quite annoying because
// we'd want to use them whenever possible. For example, if we had [15 bumper x8, 20 x6]
// and want 60 lbs we'd normally select 20 x3 (for single plates) but with bumpers we'd
// want 15 bumper x4. Though this is probably more doable now that we're enumerating
// plates.

enum Units: Codable {
    /// Weights are in pounds.
    case Imperial
    
    /// Weights are in kilograms.
    case Metric
    
    /// Used when we don't care about the units, e.g. when printing plates to use.
    case None
}

/// Converts a weight into a user friendly string representation.
func formatWeight(_ weight: Float, _ units: Units) -> String {
    var s = "\(weight, default: "%.3")"
    while s.hasSuffix("0") {
        s.removeLast(1)
    }
    if s.hasSuffix(".") {
        s.removeLast(1)
    }
    
    switch units {
    case .Imperial: return "\(s) lbs"
    case .Metric: return "\(s) kg"
    case .None: return s
    }
}

/// A weight mapped to the weights available in a WeightSet. For example, 135 lbs might be mapped to a 45 lb
/// plate (plus 45 pounds for a barbell).
struct ActualWeight {
    private let weight: InternalWeight
    
    /// The weight. For discrete this will be a single weight, e.g. for dumbbells we only count one
    /// dumbbell. For dual plates we include both sides and the bar weight (if present).
    func value() -> Float {
        switch weight {
        case .Discrete(let v, _): v
        case .Error(_, let v): v
        case .Plates(let p): p.totalWeight()
        }
    }

    /// The weight as a string, e.g. "165 lbs".
    func text() -> String {
        switch weight {
        case .Discrete(let v, let u): formatWeight(v, u)
        case .Error(_, _): ""
        case .Plates(let p): formatWeight(p.totalWeight(), p.units)
        }
    }

    /// More information about the weight e.g. "45 + 10 + 5" (if plates are being used)
    /// or "40 + 2.5 magnet" (for dumbbells with optional magnets). Note that for
    /// DualPlates this returns the plates for only one side.
    func details() -> String? {
        switch weight {
        case .Discrete(_, _): nil
        case .Error(let m, _): m
        case .Plates(let p): p.details()
        }
    }

    init(discrete: Float, _ units: Units) {
        self.weight = .Discrete(discrete, units)
    }
    
    fileprivate init(error: String, _ target: Float) {
        self.weight = .Error(error, target)
    }

    fileprivate init(plates: InternalPlates) {
        self.weight = .Plates(plates)
    }
}

/// How many plates the user has for a particular weight.
struct Plate: CustomDebugStringConvertible, Codable, Comparable, Equatable {
    var weight: Float
    var count: Int
    
    init(_ weight: Float, _ count: Int) {
        self.weight = weight
        self.count = count
    }
    
    func totalWeight() -> Float {
        return weight * Float(count)
    }
    
    var debugDescription: String {
        return "\(weight, default: "%.1f") x\(count)"
    }

    func description(_ units: Units) -> String {
        let w = formatWeight(weight, units)
        if count == 1 {
            return w
        } else {
            return "\(w) x\(count)"
        }
    }
    
    // This is used with binarySearch to find a match for a target weight.
    static func <(lhs: Plate, rhs: Plate) -> Bool {
        return lhs.comparableWeight() < rhs.comparableWeight()
    }
    
    private func comparableWeight() -> Int {
        return Int(1000 * totalWeight())
    }
    
    // Model classes are automatically given an equality operator
    // based on identify (and that is not replaced by the Comparable
    // version) so we need to provide our own for binarySearch.
    static func ==(lhs: Plate, rhs: Plate) -> Bool {
        return lhs.comparableWeight() == rhs.comparableWeight()
    }
}

/// Dual is used for equipment like barbells where plates are added to both sides. When
/// displaying plate counts to the user only the plates for one side are listed. Single is
/// used for things like T-bar rows.
final class PlateWeights: Codable {
    var plates: [Plate] // sorted by largest to smallest using just weight (so enumeratePlates prefers larger weights)
    var bar: Float?
    var units: Units
    let dual: Bool
    
    // All non-duplicate combinations of plates for every weight sorted by smallest
    // weight to largest. Note that these are always plates added to one side of the bar.
    var combos: [InternalPlates] = []
    
    init(dual: Bool, plates: [Plate], bar: Float? = nil, units: Units) {
        self.dual = dual
        self.plates = plates.sorted(by: {$1.weight < $0.weight})
        self.bar = bar
        self.units = units
    }
    
    func description() -> String {
        let b = if plates.isEmpty {
            "no plates"
        } else {
            plates.reversed().map {$0.description(units)}.joined(separator: ", ")
        }
        let prefix = dual ? "Dual " : "Single"
        if let r = bar {
            return "\(prefix) plates with \(b) and a \(formatWeight(r, units)) bar."
        } else {
            return "\(prefix) plates with \(b)."
        }
    }
    
    /// Smallest total weight to largest. Typically this should be used instead of the plates field.
    func findCombos() -> [InternalPlates] {
#if DEBUG
        for i in plates.indices {
            if i > 0 {
                assert(plates[i-1].weight > plates[i].weight)
            }
        }
#endif
        if combos.isEmpty {
            combos = enumeratePlates(plates, bar: bar, units: units)
        }
        return combos
    }
}

/// Used for stuff like dumbbells and cable machines.
class DiscreteWeights: Codable {
    var weights: [Float]
    var units: Units
    var extra1: Float? = nil
    var extra2: Float? = nil
    var combos: [Float]? = nil
    
    init(weights: [Float], units: Units) {
        self.weights = weights
        self.units = units
    }
    
    func description() -> String {
        let b = if weights.isEmpty {
            "no weights"
        } else {
            weights.map {formatWeight($0, units)}.joined(separator: ", ")
        }
        return "Discrete weights with \(b)."
    }
        
    /// Smallest to largest. Typically this should be used instead of the weights field.
    func findCombos() -> [Float] {
        if combos == nil {
            var comb: [Float] = []
            for weight in weights {
                addWeight(&comb, weight)
                if let e = extra1 {
                    addWeight(&comb, weight + e)
                }
                if let e = extra2 {
                    addWeight(&comb, weight + e)
                }
                if let e1 = extra1, let e2 = extra2 {
                    addWeight(&comb, weight + e1 + e2)
                }
            }
            combos = comb.sorted {$0 < $1}
        }
        return combos!
    }
    
    private func addWeight(_ comb: inout [Float], _ weight: Float) {
        if !comb.contains(where: {$0.sameWeight(weight)}) {
            comb.append(weight)
        }
    }
}

/// Collections of weights that are shared across programs, e.g. there could be sets
/// for dumbbells, a cable machine, plates for OHP, and plates for deadlifts.
enum WeightSet: Codable {
    /// Used for stuff like dumbbells and cable machines.
    case discrete(DiscreteWeights)
    
    /// Used for stuff like barbell exercises and leg presses. Includes an optional bar weight.
    case plates(PlateWeights)
}

extension WeightSet {    
    var units: Units {
        switch self {
            case .discrete(let d): return d.units
            case .plates(let d): return d.units
        }
    }
    
    /// Used to show the user what the weight set contains.
    func description() -> String {
        switch self {
            case .discrete(let d):
            return d.description()
            case .plates(let d):
            return d.description()
        }
    }
    
    /// Return the next weight larger than target.
    func advance(target: Float) -> ActualWeight {
        switch self {
            case .discrete(let d):
                let (_, upper) = findDiscrete(target, d.findCombos());
                return ActualWeight(discrete: upper, d.units)
            case .plates(let d):
                if d.dual {
                    return ActualWeight(plates: upperDual(target, d.findCombos(), d.bar, d.units))
                } else {
                    fatalError("not supported")
                }
        }
    }
    
    /// Used for warmups and backoff sets. May return a weight larger than target.
    func closest(target: Float) -> ActualWeight {
        switch self {
            case .discrete(let d):
                return ActualWeight(discrete: closestDiscrete(target, d.findCombos()), d.units)
            case .plates(let d):
                if d.dual {
                    return ActualWeight(plates: closestDual(target, d.findCombos(), d.bar, d.units))
                } else {
                    fatalError("not supported")
                }
        }
    }
    
    /// Used for worksets. Will not return a weight larger than target.
    func lower(target: Float) -> ActualWeight {
        switch self {
            case .discrete(let d):
                let (lower, _) = findDiscrete(target, d.findCombos());
                return ActualWeight(discrete: lower, d.units)
            case .plates(let d):
                if d.dual {
                    return ActualWeight(plates: lowerDual(target, d.findCombos(), d.bar, d.units))
                } else {
                    fatalError("not supported")
                }
        }
    }
    
    /// Returns the netxt weight larger than target.
    func upper(target: Float) -> ActualWeight { // TODO why do we also have advance?
        switch self {
            case .discrete(let d):
                let (_, upper) = findDiscrete(target, d.findCombos());
                return ActualWeight(discrete: upper, d.units)
            case .plates(let d):
                if d.dual {
                    return ActualWeight(plates: upperDual(target, d.findCombos(), d.bar, d.units))
                } else {
                    fatalError("not supported")
                }
        }
    }
            
    private func closestDiscrete(_ target: Float, _ weights: [Float]) -> Float {
        let (lower, upper) = findDiscrete(target, weights);
        if target - lower <= upper - target {
            return lower
        } else {
            return upper
        }
    }
    
    private func closestDual(_ target: Float, _ enums: [InternalPlates], _ bar: Float?, _ units: Units) -> InternalPlates {
        func findBest(_ target: Float, _ lhs: InternalPlates, _ rhs: InternalPlates) -> InternalPlates {
            let l = lhs.totalWeight()
            let r = rhs.totalWeight()
            if abs(target - l) < abs(target - r) {
                return lhs
            } else {
                return rhs
            }
        }

        // Little tricky here: InternalPlates tracks the number of plates on one side
        // so we need to divide by 2, but that won't quite work unless we also set
        // bar to nil.
        let t = InternalPlates(plates: [Plate(target/2.0, 1)], bar: nil, units: units)
        
        switch enums.binarySearch(t) {
        case .found(let i): return enums[i]
        case .missing(let i):
            if i > 0 {
                if i < enums.count {
                    return findBest(target, enums[i - 1], enums[i])
                } else {
                    return enums.last!
                }
            } else if !enums.isEmpty {
                let empty = InternalPlates(plates: [], bar: bar, units: units)
                return findBest(target, empty, enums[i])
            } else {
                return InternalPlates(plates: [], bar: bar, units: units)
            }
        }
    }

    // TODO may want to make these internal for unit tests
    private func lowerDual(_ target: Float, _ enums: [InternalPlates], _ bar: Float?, _ units: Units) -> InternalPlates {
        let t = InternalPlates(plates: [Plate(target/2.0, 1)], bar: nil, units: units)
        switch enums.binarySearch(t) {
        case .found(let i): return enums[i]
        case .missing(let i):
            if i > 0 {
                return enums[i - 1]
            } else {
                return InternalPlates(plates: [], bar: bar, units: units)
            }
        }
    }

    private func upperDual(_ target: Float, _ enums: [InternalPlates], _ bar: Float?, _ units: Units) -> InternalPlates {
        let t = InternalPlates(plates: [Plate(target/2.0, 1)], bar: nil, units: units)
        switch enums.binarySearch(t) {
        case .found(let i):
            if i + 1 < enums.count {
                return enums[i + 1]
            } else {
                return enums[i]
            }
        case .missing(let i):
            if target < (bar ?? 0.0) || enums.isEmpty {
                return InternalPlates(plates: [], bar: bar, units: units)
            } else {
                if i < enums.count {
                    return enums[i]
                } else {
                    return enums[i - 1]
                }
            }
        }
    }
    
    private func findDiscrete(_ target: Float, _ weights: [Float]) -> (Float, Float) {
        var lower = weights.first ?? 0.0
        var upper = Float.greatestFiniteMagnitude
        
        for candidate in weights {
            if candidate > lower && candidate <= target {
                lower = candidate
            }
            if candidate < upper && candidate > target {
                upper = candidate
            }
        }
        
        // We need to allow for zero weight for stuff like dumbbells, e.g. a user
        // may start with bodyweight squats and then progress to a goblet squat
        // with a dumbbell. Of course, this makes less sense with something like
        // a cable machine but even there zero weight might sometimes make sense.
        if target < lower {
            lower = 0.0
        }
        
        return (lower, upper)
    }
}
