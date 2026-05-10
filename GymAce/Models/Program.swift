import Foundation
import SwiftUI

/// A list of workouts that the user performs. Workouts are scheduled (e.g. Lower on Monday and Upper on Wednesday)
/// and contain a list of exercises (e.g. Bench Press, Overhead Press, and Pull ups).
@Observable
final class Program: Codable, Identifiable {
    var name: String
    
    var exercises: [Exercise] = []

    var workouts: [Workout] = []
    
    /// Shown in ProgramView. Typically has notes for things like how to handle progression.
    var note: String = ""   // TODO support this?
        
    /// Number of weeks till the next rest days from the last rest.
    var restWeek: Int? = nil    // TODO support this
    
    /// Number of days to rest.
    var restDays: Int = 7
    
    /// Date the last rest started.
    var lastRest: Date? = nil
    
    /// Shown in EditProgramsView when the program is selected.
    var description = ""

    var id = UUID()

    var version: Int = 1

    init(_ name: String) {
        self.name = name
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
    }
        
//    func deleteWorkout(_ workout: Workout) {
//        if let index = self.workouts.firstIndex(of: workout) {
//            self.workouts.remove(at: index)
//        }   // TODO some sort of warning if it wasn't found?
//    }
    
    func deleteWorkouts(_ offsets: IndexSet) {
        self.workouts.remove(atOffsets: offsets)
    }
    
    func findExercise(_ name: String) -> Exercise? {
        return exercises.first(where: {$0.name == name})
    }
}
