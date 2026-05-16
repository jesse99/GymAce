import Foundation
import SwiftUI

@main
struct GymAceApp: App {
    var model: Model
    
    init() {
        model = Model.load()
        if model.programs.isEmpty { // TODO only do this if DEBUG?
            model.notes.addDefaults()
            model = previewModel()
            addMyProgram(model)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}

// TODO get rid of this stuff at some point
fileprivate func makeDurations(_ name: String, _ formalName: String, secs: [Int], weights: String? = nil, weight: Float? = nil) -> Exercise {
    let durations = DurationsData(secs: secs, targetSecs: nil)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, durations: durations, weights: n, weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, durations: durations)
    }
}

fileprivate func makeReps(_ name: String, _ formalName: String, warmups: [FixedReps], worksets: [VariableReps], backoff: [FixedReps] = [], weights: String, weight: Float, rest: Int?) -> Exercise {
    let reps = RepsData(warmups: warmups, worksets: worksets, backoff: backoff, rest: rest)
    return Exercise(name: name, formalName: formalName, reps: reps, weights: weights, weight: weight)
}

fileprivate func makePercent(_ name: String, _ formalName: String, _ other: String, percent: Int, warmups: [FixedReps], worksets: [Int], weights: String, rest: Int) -> Exercise {
    let percent = PercentData(other: other, percent: percent, warmups: warmups, worksets: worksets, rest: rest)
    return Exercise(name: name, formalName: formalName, percent: percent, weights: weights)
}

// These are in the preview model code
//model.weightSets["Cable Machine"]
//model.weightSets["Dual Plates"]
//model.weightSets["Dumbbells"]
//model.weightSets["Trapbar"]

fileprivate func addMyExercises(_ program: Program) {
    let warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
    let dwarmup = [FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
    
    let reps1 = [VariableReps(3, to: 5)]
    let reps2 = [VariableReps(3, to: 5), VariableReps(3, to: 5)]
    let reps3 = [VariableReps(3, to: 5), VariableReps(3, to: 5), VariableReps(3, to: 5)]
    let reps12 = [VariableReps(8, to: 12), VariableReps(8, to: 12), VariableReps(8, to: 12)]

    var exercise = makeDurations("Quad Stretch", "Standing Quad Stretch", secs: [30])
    program.exercises.append(exercise)

    exercise = makePercent("Light Squat", "High bar Squat", "Heavy Squat", percent: 90, warmups: warmup, worksets: [5, 5, 5], weights: "Dual Plates", rest: Int(3.5*60))
    program.exercises.append(exercise)

    exercise = makeReps("Heavy Squat", "High bar Squat", warmups: warmup, worksets: reps2, weights: "Dual Plates", weight: 145, rest: Int(3.5*60))
    program.exercises.append(exercise)

    exercise = makeReps("Face Pulls", "Face Pull", warmups: [], worksets: reps12, weights: "Cable Machine", weight: 32.5, rest: Int(2.5*60))
    program.exercises.append(exercise)

    exercise = makeReps("Trap Deadlift", "Trap Bar Deadlift", warmups: dwarmup, worksets: reps1, weights: "Dual Plates", weight: 235, rest: nil)
    program.exercises.append(exercise)
    
    exercise = makePercent("Light Bench", "Bench Press", "Heavy Bench", percent: 90, warmups: warmup, worksets: [5, 5, 5], weights: "Dual Plates", rest: Int(3.0*60))
    program.exercises.append(exercise)

    exercise = makeReps("Heavy Bench", "Bench Press", warmups: warmup, worksets: reps2, weights: "Dual Plates", weight: 145, rest: Int(3.5*60))
    program.exercises.append(exercise)

    let creps = [VariableReps(3, to: 8), VariableReps(3, to: 8)]
    exercise = makeReps("Chin Ups", "Chin-up", warmups: [], worksets: creps, weights: "Dumbbells", weight: 30, rest: Int(3.0*60))
    program.exercises.append(exercise)

    exercise = makeReps("OHP", "Overhead Press", warmups: warmup, worksets: reps3, weights: "Dual Plates", weight: 80, rest: Int(3.0*60))
    program.exercises.append(exercise)

    exercise = makeReps("DB OHP", "Overhead Press", warmups: dwarmup, worksets: reps3, weights: "Dumbbells", weight: 30, rest: Int(3.0*60))
    program.exercises.append(exercise)
}

fileprivate func addMyProgram(_ model: Model) {
    func addBench(_ program: Program) {
        let schedule = Schedule.days(Weekdays(days: [3]))    // tues
        let workout = Workout("Bench", schedule)
        
        workout.addExercise(name: "Heavy Bench")
        workout.addExercise(name: "OHP")
        workout.addExercise(name: "DB OHP")
        workout.addExercise(name: "Chin Ups")
        
        program.addWorkout(workout)
    }

    func addSquat(_ program: Program) {
        let schedule = Schedule.days(Weekdays(days: [5]))    // thurs
        let workout = Workout("Squat", schedule)
        
        workout.addExercise(name: "Light Bench")
        workout.addExercise(name: "Quad Stretch")
        workout.addExercise(name: "Heavy Squat")
        workout.addExercise(name: "Chin Ups")
        
        program.addWorkout(workout)
    }

    func addDeadlift(_ program: Program) {
        let schedule = Schedule.days(Weekdays(days: [1]))    // sun
        let workout = Workout("Deadlift", schedule)
        
        workout.addExercise(name: "Quad Stretch")
        workout.addExercise(name: "Light Squat")
        workout.addExercise(name: "Face Pulls")
        workout.addExercise(name: "Trap Deadlift")
        
        program.addWorkout(workout)
    }

    let program = Program("My")
    addMyExercises(program)
    addBench(program)
    addSquat(program)
    addDeadlift(program)
    model.programs.append(program)
}
