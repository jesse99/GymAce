import Foundation
import SwiftData

/// Used to order exercises within a workout and to maintain the transient state associated with an exercise.
@Model
final class ExerciseEntry {
    /// The actual exercise.
    var exercise: Exercise

    /// Model array ordering isn't stable so this is used to sort the exercises into
    /// the order the user wants to use.
    var order: Int
    
    /// The set the user is currently performing in an exercise screen (this doesn't
    /// belong to the view because we want the user to be able to go to another
    /// exercise to super set or goto settings without losing their place). Note that
    /// if this is >= the number of sets the user is considered to have finished the
    /// exercise.
    var setIndex: Int
        
    /// Set if the user is currently performing the exercise. Added to Exercise.history if the user finishes the exercise.
    var current: Completed? = nil

    /// Returns true if the user is on a workset with an expected rep that may be changed to an actual rep.
    var hasExpected: Bool {
        if let reps = exercise.reps, reps.isVariable, !finished() {
            var index = fixedIndex()
            index -= reps.warmups.count
            if index >= 0 && index < reps.worksets.count {
                let min = reps.worksets[index].min
                let max = reps.worksets[index].max
                return min < max
            }
        }
        return false
    }

    /// Used to get the expected rep and optionally set the actual rep.
    var expectedReps: Int {
        get {
            if let reps = exercise.reps {
                var index = fixedIndex()
                index -= reps.warmups.count
                if index >= 0 && index < current!.sets.count {
                    switch current!.sets[index] {
                    case .reps(let n): return n
                    default: return 0
                    }
                }
            }
            return 0
        }
        set {
            if let reps = exercise.reps {
                var index = fixedIndex()
                index -= reps.warmups.count
                current!.sets[index] = .reps(newValue)
            }
        }
    }
    
    var maxEpectedReps: Int {
        if let reps = exercise.reps {
            var index = fixedIndex()
            index -= reps.warmups.count
            return reps.worksets[index].max
        }
        return 0
    }
    
    var rest: Int? {
        if let reps = exercise.reps {
            var index = fixedIndex()
            index -= reps.warmups.count
            if index >= 0 && index < reps.worksets.count {
                return reps.rest    // TODO should return nil for the last set of the last exercise in a workout
            }
        }
        return nil
    }

    // TODO add this
//    pub enabled: bool,

    init (exercise: Exercise, order: Int) {
        self.exercise = exercise
        self.order = order
        self.setIndex = 0
    }
    
    /// Called when the user starts an exercise. Resets setIndex and current if needed.
    func started() {
        if let c = self.current {
            if c.isStale {
                reset()
            }
        } else {
            reset()
        }
    }

    /// Start the exercise all over (or for the first time).
    func reset() {
        func findExpected(_ reps: VariableReps, _ index: Int) -> Int {
            // Usually we'll just return reps.min except for a few cases:
            if let last = exercise.latestCompleted() {
                if let new = exercise.weight, let old = last.weight {
                    if new < old {
                        // 1) the user has dropped the weight
                        // Possible that they can't now do max, but they should be close to that...
                        return reps.max
                    } else if new == old {
                        // 2) the user is doing the same weight so the expected is whatever
                        // they last did clamped to what the current min/max is.
                        if index < last.sets.count {
                            switch last.sets[index] {
                            case .reps(let n): return reps.clamp(n)
                            default: return reps.min
                            }
                        }
                    }
                }
            }
            return reps.min
        }
        
        setIndex = 0
        current = Completed(weight: exercise.weight)
        
        // Pre-populate sets with whatever the user is expected to do. For reps, at
        // least, we'll normally give the user a chance to over-write this with how
        // much they actually did.
        if let durations = exercise.durations {
            for d in durations.secs {
                current!.sets.append(.duration(d))
            }
        }
        if let reps = exercise.reps {
            for (index, reps) in reps.worksets.enumerated() {
                let n = findExpected(reps, index)
                current!.sets.append(.reps(n))
            }
        }
    }
    
    /// Called after each set is completed.
    func completedSet() {
        setIndex += 1
    }
    
    /// Called when the user completes an exercise. Adds current to Exercise.history and then resets
    /// current.
    func completedAll() {
        if var c = current {
            c.completed = Date()
            exercise.history.append(c)
        }
        setIndex = 0
        current = nil
        if let l = exercise.history.last {
            if let w = l.weight {
                print("weight: \(w)")
            } else {
                print("weight: nil")
            }
            print("started: \(l.started)")
            if let c = l.completed {
                print("completed: \(c)")
            } else {
                print("completed: nil")
            }
            for s in l.sets {
                switch s {
                    case .duration(let n): print("\(n)s")
                    case .reps(let n): print("\(n) reps")
                }
            }
        }
    }
    
    func finished() -> Bool {
        if let durations = exercise.durations {
            return setIndex >= durations.secs.count
        }
        if let reps = exercise.reps {
            return setIndex >= reps.warmups.count + reps.worksets.count + reps.backoff.count
        }
        return true
    }
    
    // Shown first in the exercise view, e.g. "Workset 1 of 3" or "Set 1 of 3".
    func headline() -> String {
        var index = fixedIndex()
        if let durations = exercise.durations {
            return "Set \(index + 1) of \(durations.secs.count)"
        }
        if let reps = exercise.reps {
            if index < reps.warmups.count {
                return "Warmup \(index + 1) of \(reps.warmups.count)"
            }
            
            index -= reps.warmups.count
            if index < reps.worksets.count {
                return "Workset \(index + 1) of \(reps.worksets.count)"
            }
            
            index -= reps.worksets.count
            if index < reps.backoff.count {
                return "Backoff \(index + 1) of \(reps.backoff.count)"
            }
        }
        return "Set \(index + 1)?"
    }
    
    // Shown second in the exercise view, e.g. "5 reps @ 140 lbs" or "30s".
    func subhead() -> String {
        var suffix = ""
        if let actual = actualWeight() {
            suffix = " @ \(actual.text())"
        }
        
        let index = fixedIndex()
        if let durations = exercise.durations {
            return secsToStr(durations.secs[index]) + suffix
        }
        if let reps = exercise.reps {
            var index = index
            if index < reps.warmups.count {
                return "\(reps.warmups[index].reps) reps" + suffix
            }
            
            index -= reps.warmups.count
            if index < reps.worksets.count {
                if reps.worksets[index].min == reps.worksets[index].max {
                    return "\(reps.worksets[index].min) reps" + suffix
                } else {
                    // TODO do a better job with expected reps
                    return "\(reps.worksets[index].min)-\(reps.worksets[index].max) reps" + suffix
                }
            }
            
            index -= reps.worksets.count
            if index < reps.backoff.count {
                return "\(reps.backoff[index].reps) reps" + suffix
            }
        }
        return "?"
    }
    
    // Shown third in the exercise view, e.g. "45 + 2.5".
    func footer() -> String? {
        if let actual = actualWeight() {
            return actual.details()
        }
        return nil
    }
    
    // Shown fourth in the exercise view, e.g. "90% of 225 lbs".
    func subfooter() -> String? {
        if let weight = exercise.weight, let ws = exercise.weightSet, let reps = exercise.reps {
            var index = fixedIndex()
            if index < reps.warmups.count {
                return "\(reps.warmups[index].percent)% of \(formatWeight(weight, ws.units))"
            }
            
            index -= reps.warmups.count
            if index < reps.worksets.count {
                return nil
            }
            
            index -= reps.worksets.count
            if index < reps.backoff.count {
                return "\(reps.backoff[index].percent)% of \(formatWeight(weight, ws.units))"
            }
        }
        return nil
    }
    
    private func actualWeight() -> ActualWeight? {
        if let weight = exercise.weight {
            if let ws = exercise.weightSet {
                if exercise.durations != nil {
                    return ws.lower(target: weight)
                }
                if let reps = exercise.reps {
                    var index = fixedIndex()
                    if index < reps.warmups.count {
                        let p = Float(reps.warmups[index].percent) / 100.0
                        return ws.closest(target: p*weight)
                    }
                    
                    index -= reps.warmups.count
                    if index < reps.worksets.count {
                        return ws.lower(target: weight)
                    }

                    index -= reps.worksets.count
                    if index < reps.backoff.count {
                        let p = Float(reps.backoff[index].percent) / 100.0
                        return ws.closest(target: p*weight)
                    }
                }
            }
            return ActualWeight(discrete: weight, .None)
        }
        return nil
    }
    
    private func fixedIndex() -> Int {
        if let durations = exercise.durations {
            return setIndex >= durations.secs.count ? durations.secs.count - 1 : setIndex
        }
        if let reps = exercise.reps {
            let count = reps.warmups.count + reps.worksets.count + reps.backoff.count
            return setIndex >= count ? count - 1 : setIndex
        }
        return setIndex
    }
}
