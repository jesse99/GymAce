// These items should only be used by WeightSet.
import Foundation

enum InternalWeight {
    case Discrete(Float, Units)
    case Error(String, Float)
    case Plates(InternalPlates)
}

// This is very much like DualPlates but can also be used by SinglePlates once we add that.
struct InternalPlates: Comparable {
    /// Sorted from largest to smallest.
    let plates: [Plate]
    
    let bar: Float?
    
    /// If true plates are added two at a time.
    let dual: Bool
    
    let units: Units
    
    init(plates: [Plate], bar: Float?, units: Units) {
        self.plates = plates
        self.bar = bar
        self.dual = true
        self.units = units
    }
    
    func totalWeight() -> Float {
        var weight = plates.reduce(0) { $0 + $1.weight * Float($1.count) }
        if dual {
            weight *= 2
        }
        if let b = bar {
            weight += b
        }
        return weight
    }
    
    /// Returns something like "45x2 + 10 + 5".
    func details() -> String {
        let a = plates.map {
            if $0.count > 1 {
                "\(formatWeight($0.weight, .None))x\($0.count)"
            } else {
                "\(formatWeight($0.weight, .None))"
            }
        }
        return a.joined(separator: " + ")
    }
    
    static func <(lhs: InternalPlates, rhs: InternalPlates) -> Bool {
        return lhs.comparableWeight() < rhs.comparableWeight()
    }
        
    private func comparableWeight() -> Int {
        return Int(1000 * totalWeight())
    }
}

// TODO need to sort plates before calling enumeratePlates, largest to smallest

// Returns all combinations of plates sorted from smallest total weight to largest.
// For duplicate total weights the combination with the least plates is returned,
// so [45] is returned but not [10, 35]. Plates should be sorted by plate weight
// from largest to smallest.
func enumeratePlates(_ plates: [Plate], bar: Float?, units: Units) -> [InternalPlates] {  // internal access so that unit tests can test it
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
            // Prefer fewer plates, e.g. [45] over [25 + 10x2].
            let old_count = old.reduce(0) { $0 + $1.count}
            if candidate_count < old_count {
                candidates[candidate_weight] = candidate
            }
            
            // Prefer larger plates, e.g. [45x2 + 5] over [45 + 25x2].
            if candidate_count == old_count {
                if let candidate_max = candidate.map({$0.weight * Float($0.count)}).max(),
                   let old_max = old.map({$0.weight * Float($0.count)}).max(), candidate_max > old_max {
                    candidates[candidate_weight] = candidate
                }
            }
        } else {
            candidates[candidate_weight] = candidate
        }
    }

    var result: [InternalPlates] = candidates.values.map {InternalPlates(plates: $0, bar: bar, units: units)}
    result.sort()       // smallest weight to largest
    return result
}
