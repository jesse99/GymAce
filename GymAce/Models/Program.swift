import Foundation
import SwiftUI

/// A list of workouts that the user performs. Workouts are scheduled (e.g. Lower on Monday and Upper on Wednesday)
/// and contain a list of exercises (e.g. Bench Press, Overhead Press, and Pull ups).
@Observable
final class Program: Codable, Identifiable {
    var name: String
    
    var exercises: [Exercise] = []

    var workouts: [Workout] = []
    
    /// Date the user started working out. This is used to compute the current week number.
    var started: Date? = nil

    /// Shown in EditPrograms view to briefly describe the program.
    var summary: String? = nil
        
    var version: Int = 1

    var id = UUID()

    init(_ name: String) {
        self.name = name
    }
    
    func fixup() {
//        if name == "My" && started == nil {
//            let calendar = Calendar.current
//            started = calendar.date(byAdding: .day, value: -7, to: Date())
//        }
//        if !workouts.contains(where: {$0.name == "Rest"}) {
//            let schedule = Schedule.anyDay
//            let workout = Workout("Rest", schedule)
//            workout.weeks = 8...8
//            addWorkout(workout)
//        }

        for e in exercises {
            e.fixup()
        }
        for w in workouts {
            w.fixup(self)
        }
    }
    
    func didExercise() {
        if started == nil {
            started = Date()
        }
    }
    
    func currentWeek(on: Date) -> Int? {
        let t = totalWeeks()
        if t == 1 {
            return 1
        }
        let s = started ?? oldestWorkout()
        if let l = s.weekNumber(), let r = on.weekNumber() {
            return (r - l) % t + 1
        }
        return nil
    }
    
    func usesWeeks() -> Bool {
        for w in workouts {
            if w.weeks != nil {
                return true
            }
        }
        return false
    }
    
    func setCurrentWeek(_ n: Int) {
        // Initially set started to the start of this week.
        let calendar = Calendar.current
        if let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) {
            started = interval.start
        } else {
            started = Date()
        }
        
        // Then advance backward by n - 1 weeks. This can set the current week to
        // something larger than totalWeeks but that's OK.
        if n > 1 {
            if let nextWeek = calendar.date(byAdding: .weekOfYear, value: -(n - 1), to: started!) {
                started = nextWeek
            }
        }
//        print("started: \(started!)")
    }

    private func totalWeeks() -> Int {
        var total = 1
        for w in workouts {
            if let r = w.weeks, r.upperBound > total {
                total = r.upperBound
            }
        }
        return total
    }
        
    // TODO get rid of this
    func startWorkout() -> Date? {
        return started ?? oldestWorkout()
    }
        
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
    }
    
    func deleteExercises(_ names: [String]) {
        for name in names {
            for w in workouts {
                for (i, e) in w.entries.enumerated() {   // note that we may need to remove multiple matches
                    if e.name == name {
                        w.entries.remove(at: i)
                    }
                }
            }
            if let index = self.exercises.firstIndex(where: {$0.name == name}) {
                self.exercises.remove(at: index)
            }
        }
    }

    func deleteWorkouts(_ names: [String]) {
        for name in names {
            if let index = self.workouts.firstIndex(where: {$0.name == name}) {
                self.workouts.remove(at: index)
            }
        }
    }
    
    func findExercise(_ name: String) -> Exercise? {
        return exercises.first(where: {$0.name == name})
    }
    
    func setExerciseName(_ exercise: Exercise, _ name: String) {
        for w in workouts {
            for e in w.entries {
                if e.name == exercise.name {
                    e.name = name
                }
            }
        }
        for e in exercises {
            if case .percent(var d) = e.data, d.other == exercise.name {
                d.other = name
                e.data = .percent(d)
            }
        }
        exercise.name = name
    }
    
    private func oldestWorkout() -> Date {
        var candidate = Date()  // we'll go ahead and use today if the user hasn't actually finished anything
        for e in exercises {
            if let o = e.history.first {
                if o.completed < candidate {
                    candidate = o.completed
                }
            }
        }
        return candidate
    }
}
