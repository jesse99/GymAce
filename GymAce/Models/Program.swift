import Foundation
import SwiftData
import SwiftUI

/// A list of workouts that the user performs. Workouts are scheduled (e.g. Lower on Monday and Upper on Wednesday)
/// and contain a list of exercises (e.g. Bench Press, Overhead Press, and Pull ups).
@Model
final class Program {
    init(name: String) {
        self.name = name
    }
    
    func addWorkout(_ workout: Workout) {
        self.workouts.append(workout)
    }
    
    func deleteWorkout(_ workout: Workout) {
        if let index = self.workouts.firstIndex(of: workout) {
            self.workouts.remove(at: index)
        }   // TODO some sort of warning if it wasn't found?
    }

    func deleteWorkouts(_ offsets: IndexSet) {
        self.workouts.remove(atOffsets: offsets)
    }

    /// If true the program currently being used. At most one program should be active.
    var active = false

    var workouts: [Workout] = []

    // TODO support blocks
    // TODO support notes?
    private(set) var name: String    
}

func makeTestProgram() -> Program {
    let schedule = Schedule.days([.monday, .wednesday])
    let workout = Workout("Upper", schedule)

    let exercise = Exercise.durations(ExerciseData(name: "Bench Press", formalName: "Bench Press"))
    workout.addExercise(exercise)

    let program = Program(name: "Test")
    program.active = true
    program.addWorkout(workout)
    return program
}

let testProgram: Program = makeTestProgram()
