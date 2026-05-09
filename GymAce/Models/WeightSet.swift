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

/// Used for equipment like barbells where plates are added to both sides. When
/// displaying plate counts to the user only the plates for one side are listed.
final class DualPlates: Codable {
    var plates: [Plate] // sorted by largest to smallest using just weight (so enumeratePlates prefers larger weights)
    var bar: Float?
    var units: Units
    
    // All non-duplicate combinations of plates for every weight sorted by smallest
    // weight to largest. Note that these are the plates added to one side of the bar.
    private var combos: [InternalPlates] = []
    
    init(plates: [Plate], bar: Float? = nil, units: Units) {
        self.plates = plates.sorted(by: {$1.weight < $0.weight})
        self.bar = bar
        self.units = units
    }
    
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

/// Used for equipment like T bar rows where plates are added to one sides.
final class SinglePlates: Codable {
    var plates: [Plate] // sorted by largest to smallest using just weight (so enumeratePlates prefers larger weights)
    var bar: Float?
    var units: Units
    
    // All non-duplicate combinations of plates for every weight sorted by smallest
    // weight to largest. Note that these are the plates added to one side of the bar.
    private var combos: [InternalPlates] = []
    
    init(plates: [Plate], bar: Float? = nil, units: Units) {
        self.plates = plates.sorted(by: {$1.weight < $0.weight})
        self.bar = bar
        self.units = units
    }
    
    
    func findCombos() -> [InternalPlates] {
#if DEBUG
        for i in plates.indices {
            if i > 0 {
                assert(plates[i-1].weight > plates[i].weight)
            }
        }
#endif
        if combos.isEmpty {
//            combos = enumeratePlates(plates, bar: bar, units: units)  // TODO need a flag for single or dual
        }
        return combos
    }
}

/// Used for stuff like dumbbells and cable machines.
struct DiscreteWeights: Codable {
    var weights: [Float]
    var units: Units
    var magnets: [Float] = []    // TODO support this?
    
    init(weights: [Float], units: Units) {
        self.weights = weights
        self.units = units
    }
}

/// Collections of weights that are shared across programs, e.g. there could be sets
/// for dumbbells, a cable machine, plates for OHP, and plates for deadlifts.
enum WeightSet: Codable {
    /// Used for stuff like dumbbells and cable machines.
    case discrete(DiscreteWeights)
    
    /// Used for stuff like barbell exercises and leg presses. Plates are added in pairs.
    /// Includes an optional bar weight.
    case dual(DualPlates)

    /// Used for stuff like T bar rows and landmines. Includes an optional bar weight.
    case single(SinglePlates)
}

extension WeightSet {    
    var units: Units {
        switch self {
            case .discrete(let d): return d.units
            case .dual(let d): return d.units
            case .single(let d): return d.units
        }
    }
    
    /// Return the next weight larger than target..
    func advance(target: Float) -> ActualWeight {
        switch self {
            case .discrete(let d):
                let (_, upper) = findDiscrete(target, d.weights);
                return ActualWeight(discrete: upper, d.units)
            case .dual(let d):
                return ActualWeight(plates: upperDual(target, d.findCombos(), d.bar, d.units))
            case .single(let d):
                fatalError("not supported")
        }
    }
    
    /// Used for warmups and backoff sets. May return a weight larger than target.
    func closest(target: Float) -> ActualWeight {
        switch self {
            case .discrete(let d):
                return ActualWeight(discrete: closestDiscrete(target, d.weights), d.units)
            case .dual(let d):
                return ActualWeight(plates: closestDual(target, d.findCombos(), d.bar, d.units))
            case .single(let d):
                fatalError("not supported")
        }
    }
    
    /// Used for worksets. Will not return a weight larger than target.
    func lower(target: Float) -> ActualWeight {
        switch self {
            case .discrete(let d):
                let (lower, _) = findDiscrete(target, d.weights);
                return ActualWeight(discrete: lower, d.units)
            case .dual(let d):
                return ActualWeight(plates: lowerDual(target, d.findCombos(), d.bar, d.units))
            case .single(let d):
                fatalError("not supported")
        }
    }
    
    /// Returns the netxt weight larger than target.
    func upper(target: Float) -> ActualWeight {
        switch self {
            case .discrete(let d):
                let (_, upper) = findDiscrete(target, d.weights);
                return ActualWeight(discrete: upper, d.units)
            case .dual(let d):
                return ActualWeight(plates: upperDual(target, d.findCombos(), d.bar, d.units))
            case .single(let d):
                fatalError("not supported")
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
                return findBest(target, enums[i - 1], enums[i])
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
        
        return (lower, upper)
    }
}
