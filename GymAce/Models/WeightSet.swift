import Foundation
import SwiftData

// TODO Might want to support bumper plates though that would get quite annoying because
// we'd want to use them whenever possible. For example, if we had [15 bumper x8, 20 x6]
// and want 60 lbs we'd normally select 20 x3 (for single plates) but with bumpers we'd
// want 15 bumper x4. Though this is probably more doable now that we're enumerating
// plates.

enum Units: nonisolated Codable {
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

    fileprivate init(discrete: Float, _ units: Units) {
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
@Model
final class Plate: CustomDebugStringConvertible, Comparable, Equatable {
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
@Model
final class DualPlates {
    var plates: [Plate]
    var bar: Float?
    var units: Units
    
    init(plates: [Plate], bar: Float? = nil, units: Units) {
        self.plates = plates
        self.bar = bar
        self.units = units
    }
    
    // Sort plates from largest to smallest using just weight, not
    // weight*count. This is used to bias enumeratePlates to preferring
    // the largest plates. (And SwiftData will populate plates after
    // init runs using a random order).
    func resort() {
        plates.sort {$0.weight > $1.weight}
    }
}

/// Used for stuff like dumbbells and cable machines.
@Model
final class DiscreteWeights {
    var weights: [Float]    // TODO might want to add a new field for magnets
    var units: Units
    
    init(weights: [Float], units: Units) {
        self.weights = weights
        self.units = units
    }
}

/// Collections of weights that are shared across programs, e.g. there could be sets
/// for dummbells, a cable machine, plates for OHP, and plates for deadlifts.
@Model
final class WeightSet {
    var name: String
    
    /// Used for stuff like dumbbells and cable machines.
    private(set) var discrete: DiscreteWeights?
    
    /// Used for stuff like barbell exercises and leg presses. Plates are added in pairs.
    /// Includes an optional bar weight.
    private(set) var dual: DualPlates?
    
    // TODO should also have single plates
    
    // All non-duplicate combinations of DualPlates for every weight sorted by smallest
    // weight to largest. Note that these are the plates added to one side of the bar.
    @Transient private var combos: [InternalPlates] = []   // SwiftData can't persist this so we'll rebuild it on load
    
    init(name: String, discrete: DiscreteWeights? = nil, dual: DualPlates? = nil) {
        assert(discrete != nil || dual != nil)  // TODO do we want this assert?
        self.name = name
        self.discrete = discrete
        self.dual = dual
    }
    
    func setWeights(discrete: DiscreteWeights) {
        self.discrete = discrete
        combos.removeAll()          // don't really need to do this, but it will free up a bit of memory
    }
    
    func setWeights(dual: DualPlates) {
        self.dual = dual
        combos.removeAll()  
    }
    
    /// Return the next weight larger than target..
    func advance(target: Float) -> ActualWeight {
        if let discrete = self.discrete {
            let (_, upper) = findDiscrete(target, discrete.weights);
            return ActualWeight(discrete: upper, discrete.units)
        }
        if let dual = self.dual {
            if combos.isEmpty {
                dual.resort()
                combos = enumeratePlates(dual.plates, bar: dual.bar, units: dual.units)
            }
            return ActualWeight(plates: upperDual(target, combos, dual.bar, dual.units))
        }
        return ActualWeight(error: "There's no weight set to use.", target)
    }
    
    /// Used for warmups and backoff sets. May return a weight larger than target.
    func closest(target: Float) -> ActualWeight {
        if let discrete = self.discrete {
            return ActualWeight(discrete: closestDiscrete(target, discrete.weights), discrete.units)
        }
        if let dual = self.dual {
            if combos.isEmpty {
                dual.resort()
                combos = enumeratePlates(dual.plates, bar: dual.bar, units: dual.units)
            }
            return ActualWeight(plates: closestDual(target, combos, dual.bar, dual.units))
        }
        return ActualWeight(error: "There's no weight set to use.", target)
    }
    
    /// Used for worksets. Will not return a weight larger than target.
    func lower(target: Float) -> ActualWeight {
        if let discrete = self.discrete {
            let (lower, _) = findDiscrete(target, discrete.weights);
            return ActualWeight(discrete: lower, discrete.units)
        }
        if let dual = self.dual {
            if combos.isEmpty {
                dual.resort()
                combos = enumeratePlates(dual.plates, bar: dual.bar, units: dual.units)
            }
            return ActualWeight(plates: lowerDual(target, combos, dual.bar, dual.units))
        }
        return ActualWeight(error: "There's no weight set to use.", target)
    }
    
    /// Returns the netxt weight larger than target.
    func upper(target: Float) -> ActualWeight {
        if let discrete = self.discrete {
            let (_, upper) = findDiscrete(target, discrete.weights);
            return ActualWeight(discrete: upper, discrete.units)
        }
        if let dual = self.dual {
            if combos.isEmpty {
                dual.resort()
                combos = enumeratePlates(dual.plates, bar: dual.bar, units: dual.units)
            }
            return ActualWeight(plates: upperDual(target, combos, dual.bar, dual.units))
        }
        return ActualWeight(error: "There's no weight set to use.", target)
    }
    
    // TODO need advance
        
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
