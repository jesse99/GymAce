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
    var name: String    
}

func makePreviewProgram() -> Program {
    func makeUpper() -> Workout {
        let schedule = Schedule.days(Weekdays(days: [1, 3]))    // mon and wed
        let workout = Workout("Upper", schedule)

        let exercise = Exercise.durations(ExerciseData(name: "Bench Press", formalName: "Bench Press"))
        workout.addExercise(exercise)

        return workout
    }

    func makeLower() -> Workout {
        let schedule = Schedule.days(Weekdays(days: [5]))       // friday
        let workout = Workout("Lower", schedule)

        let exercise = Exercise.durations(ExerciseData(name: "Squat", formalName: "High bar Squat"))
        workout.addExercise(exercise)

        return workout
    }

    let program = Program(name: "Preview")
    program.active = true
    program.addWorkout(makeUpper())
    program.addWorkout(makeLower())
    return program
}

let testProgram: Program = makePreviewProgram()
