import Foundation
import SwiftData

// TODO Might want to support bumper plates though that would get quite annoying because
// we'd want to use them whenever possible. For example, if we had [15 bumper x8, 20 x6]
// and want 60 lbs we'd normally select 20 x3 (for single plates) but with bumpers we'd
// want 15 bumper x4. Though this is probably more doable now that we're enumerating
// plates.

/// How many plates the user has for a particular weight.
@Model
final class Plate: CustomDebugStringConvertible, Equatable {
    var weight: Float
    var count: Int
    
    init(_ weight: Float, _ count: Int) {
        self.weight = weight
        self.count = count
    }
        
    var debugDescription: String {
        return "\(weight, default: "%.1f") x\(count)"
    }

    static func ==(lhs: Plate, rhs: Plate) -> Bool {
        return Int(1000*lhs.weight) == Int( 1000*rhs.weight) && lhs.count == rhs.count
    }
}

/// Used for equipment like barbells where plates are added to both sides. When
/// displaying plate counts to the user only the plates for one side are listed.
@Model
final class DualPlates: CustomReflectable {
    var plates: [Plate]
    var bar: Float?
    
    init(plates: [Plate], bar: Float? = nil) {
        self.plates = plates
        self.bar = bar
    }
    
    var customMirror: Mirror {
        let s = plates.map {"\($0.weight, default: "%.1f"))x\($0.count)"}.joined(separator: ", ")
        if let bar = self.bar {
            return Mirror(self, children: ["plates": s, "bar": bar])
        } else {
            return Mirror(self, children: ["plates": s])
        }
    }
}

/// Collections of weights that are shared across programs, e.g. there could be sets
/// for dummbells, a cable machine, plates for OHP, and plates for deadlifts.
@Model
final class WeightSet {
    var name: String
    
    /// Used for stuff like dumbbells and cable machines.
    private(set) var discrete: [Float]?
    
    /// Used for stuff like barbell exercises and leg presses. Plates are added in pairs.
    /// Includes an optional bar weight. Second tuple value is the bar weight.
    private(set) var dual: DualPlates?
    
    // TODO should also have single plates
    
    // All non-duplicate combinations of DualPlates for every weight sorted by smallest
    // weight to largest. Note that these are the plates added to one side of the bar.
    @Transient private var combos: [[Plate]] = []   // SwiftData can't handle this so we'll rebuild it on load
    
    init(name: String, discrete: [Float]? = nil, dual: DualPlates? = nil) {
        self.name = name
        self.discrete = discrete
        self.dual = dual
    }
    
    // TODO if dual is changed will need to reset combos
}

// TODO need to sort plates before calling enumeratePlates, smallest to largest

// Returns all combinations of plates sorted from smallest total weight to largest.
// For duplicate total weights the combination with the least plates is returned,
// so [45] is returned but not [10, 35]. Plates should be sorted from largest to smallest.
func enumeratePlates(_ plates: [Plate]) -> [[Plate]] {  // internal access so that unit tests can test it
    // Takes an n representing the number of plates where n is encoded like 2045 where
    // the 2 means 2 of the smallest plate, 0 of the next largest, 4 of the next, and
    // 5 of the largest plate.
    struct EncodedCounts: Sequence {
        let n: UInt64

        // Returns (count, index) tuples where count is the number of plates at index
        // where the first tuple is index 0 and represents the largest plate. So for
        // 2045 this will return (5, 0) and (4, 1) and (2, 3).
        func makeIterator() -> EncodedIterator {
            return EncodedIterator(n)
        }
    }

    struct EncodedIterator: IteratorProtocol {
        var n: UInt64
        var i: UInt64
        
        init(_ n: UInt64) {
            self.n = n
            self.i = 0
        }
        
        mutating func next() -> (Int, UInt64)? {
            if self.n > 0 {
                let count = self.n % 10
                let index = self.i
                
                self.n /= 10
                self.i += 1
                
                return (Int(count), index)
            } else {
                return nil
            }
        }
    }
    
    enum Status {
        case Valid
        case Invalid
        case Overflow
    }

    // Returns .Valid if n is compatible with the specified plates.
    func isValid(_ n: UInt64, _ plates: [Plate]) -> Status {
        // TODO: need to restrict max plate count to 9 (could relax this with UInt128)
        for (count, index) in EncodedCounts(n: n) {
            if index >= plates.count {
                return .Overflow
            } else if 2 * count > plates[Int(index)].count {
                // TODO 2* should only be done for dual plates
                return .Invalid
            }
        }
        return .Valid
    }

    // Attempt to increment n until we run out of plates.
    func increment(_ n: UInt64, _ plates: [Plate]) -> UInt64? {
        var n = n
        while true {
            n += 1
            switch isValid(n, plates) {
            case .Valid: return n
            case .Overflow: return nil
            case .Invalid: continue
            }
        }
    }

    // Get the set of plates for an encoded weight. Note that we may not use
    // these plates, e.g. there might be a set of plates for the total weight
    // that uses less plates.
    func getCandidate(_ n: UInt64, _ plates: [Plate]) -> [Plate] {
        var possible: [Plate] = []
        possible.reserveCapacity(plates.count)
        for (count, index) in EncodedCounts(n: n) {
            assert(count <= plates[Int(index)].count)
            if count > 0 {
                let plate = Plate(plates[Int(index)].weight, count)
                possible.append(plate)
            }
        }
        return possible
    }

    // I expect that there are smarter ways to do this, but:
    // 1) This is very fast even with lots of plate sizes and counts.
    // 2) This will work even for those unfortunates with really weird collections of plates.
    var n: UInt64 = 0
    var candidates: [Int: [Plate]] = [:]        // the Int is actually a weight (iffy to use Float as a dictionary key)
    while let new = increment(n, plates) {
        n = new
        let candidate = getCandidate(n, plates)

        let weight = candidate.reduce(0.0) { (total, plate) in
            total + Float(plate.count)*plate.weight
        }
        let candidate_weight = 1000 * Int(weight)
        let candidate_count = candidate.reduce(0) { $0 + $1.count}
        if let old = candidates[candidate_weight] {
            // Prefer solutions with the least number of plates.
            let old_count = old.reduce(0) { $0 + $1.count}
            if candidate_count < old_count {
                candidates[candidate_weight] = candidate
            }
        } else {
            candidates[candidate_weight] = candidate
        }
    }
    var result: [[Plate]] = Array(candidates.values)
    result.sort {
        // sort so smallest total weights are first
        let a = $0.reduce(0) {$0 + Float($1.count)*$1.weight}
        let b = $1.reduce(0) {$0 + Float($1.count)*$1.weight}
        let a2 = Int(1000.0 * a)
        let b2 = Int(1000.0 * b)
        return a2 < b2
    }
    return result
}
