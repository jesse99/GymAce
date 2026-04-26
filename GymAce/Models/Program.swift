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

    // Note that SwiftData will load these in a random order, but that's OK because the ContentView
    // will sort them according to when they are due to be executed.
    var workouts: [Workout] = []

    // TODO support blocks
    // TODO support notes?
    var name: String    
}

func makePreviewProgram() -> Program {
    func makeUpper() -> Workout {
        let schedule = Schedule.days(Weekdays(days: [2, 4]))    // mon and wed
        let workout = Workout("Upper", schedule)

        workout.addReps(name: "Bench Press1", formalName: "Bench Press", worksets: [1, 2, 3])
        workout.addReps(name: "Press2", formalName: "Bench Press", worksets: [2, 3, 4])
        workout.addReps(name: "OHP3", formalName: "Bench Press", worksets: [3, 4, 5])

        return workout
    }

    func makeLower() -> Workout {
        let schedule = Schedule.days(Weekdays(days: [6]))       // friday
        let workout = Workout("Lower", schedule)

        workout.addReps(name: "Squat1", formalName: "High bar Squat", worksets: [1, 2, 3])
        workout.addReps(name: "Deadlift2", formalName: "High bar Squat", worksets: [2, 3, 4])
        workout.addReps(name: "Face Pulls3", formalName: "High bar Squat", worksets: [3, 4, 5])

        return workout
    }

    func makeActiveRest() -> Workout {
        let schedule = Schedule.every(2)
        let workout = Workout("Active Rest", schedule)

        workout.addDurations(name: "Quad Stretch1", formalName: "Quad Stretch", secs: [10, 20, 30])
        workout.addDurations(name: "Third World Squat2", formalName: "Quad Stretch", secs: [20, 30, 40])
        workout.addDurations(name: "Cossack Squat3", formalName: "Quad Stretch", secs: [30, 30, 30, 40])

        return workout
    }

    let program = Program(name: "Preview")
    program.active = true
    program.addWorkout(makeUpper())
    program.addWorkout(makeLower())
    program.addWorkout(makeActiveRest())
    return program
}

let testProgram: Program = makePreviewProgram()
