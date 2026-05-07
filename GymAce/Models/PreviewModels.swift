import Foundation
import SwiftData

fileprivate func makeDurations(name: String, formalName: String, secs: [Int], weights: String? = nil, weight: Float? = nil) -> Exercise {
    let durations = DurationsData(secs: secs, targetSecs: nil)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, durations: durations, weights: testWeightSets[n], weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, durations: durations)
    }
}

fileprivate func makeReps(name: String, formalName: String, warmups: [FixedReps] = [], worksets: [VariableReps], backoff: [FixedReps] = [], weights: String? = nil, weight: Float? = nil, rest: Int? = nil) -> Exercise {
    let reps = RepsData(warmups: warmups, worksets: worksets, backoff: backoff, rest: rest)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, reps: reps, weights: testWeightSets[n], weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, reps: reps)
    }
}

fileprivate func makePreviewWeightSets() -> [String: WeightSet] {
    var weights: [String: WeightSet] = [:]
    
    let cable = DiscreteWeights(weights: [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0], units: .Imperial)
    var ws = WeightSet(name: "Cable", discrete: cable)
    weights[ws.name] = ws

    let dumbbells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0], units: .Imperial)
    ws = WeightSet(name: "Dumbbells", discrete: dumbbells)
    weights[ws.name] = ws

    let plates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 4)]
    let dual = DualPlates(plates: plates, bar: 45.0, units: .Imperial)
    ws = WeightSet(name: "Dual", dual: dual)
    weights[ws.name] = ws

    return weights
}

fileprivate func makePreviewExercises() -> [String: Exercise] {
    var exercises = [String: Exercise]()
    
    let warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
    let dwarmup = [FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 75), FixedReps(reps: 1, percent: 90)]
    
    let reps3 = [VariableReps(3, to: 5), VariableReps(3, to: 5), VariableReps(3, to: 5)]
    let reps5 = [VariableReps(5), VariableReps(5), VariableReps(5)]
    let reps12 = [VariableReps(8, to: 12), VariableReps(8, to: 12), VariableReps(8, to: 12)]

    let backoff = [FixedReps(reps: 5, percent: 80)]

    var exercise = makeReps(name: "Light Bench", formalName: "Bench Press", warmups: warmup, worksets: reps5, weights: "Dual", weight: 130, rest: 10)
    exercises[exercise.name] = exercise
    
    exercise = makeReps(name: "Heavy Bench", formalName: "Bench Press", warmups: warmup, worksets: reps3, weights: "Dual", weight: 145, rest: 12)
    exercises[exercise.name] = exercise
    
    exercise = makeReps(name: "OHP", formalName: "Bench Press", warmups: warmup, worksets: reps3, weights: "Dual", weight: 80, rest: 9)
    exercises[exercise.name] = exercise
    
    exercise = makeReps(name: "Squat", formalName: "High bar Squat", warmups: warmup, worksets: reps3, weights: "Dual", weight: 140, rest: 8)
    exercises[exercise.name] = exercise
    
    exercise = makeReps(name: "Deadlift", formalName: "Deadlift", warmups: dwarmup, worksets: reps3, backoff: backoff, weights: "Dual", weight: 230, rest: 10)
    exercises[exercise.name] = exercise
    
    exercise = makeReps(name: "Face Pulls", formalName: "Face Pulls", worksets: reps12, weights: "Cable", weight: 40.0, rest: 5)
    exercises[exercise.name] = exercise
    
    exercise = makeDurations(name: "Quad Stretch", formalName: "Quad Stretch", secs: [10, 20, 30])
    exercises[exercise.name] = exercise
    
    exercise = makeDurations(name: "Third World Squat", formalName: "Third World Squat2", secs: [20, 30, 40], weights: "Dumbbells", weight: 80.0)
    exercises[exercise.name] = exercise
    
    exercise = makeDurations(name: "Cossack Squat", formalName: "Quad Stretch", secs: [30, 30, 30, 40])
    exercises[exercise.name] = exercise
    
    return exercises
}

fileprivate func makePreviewProgram() -> Program {
    func makeUpper() -> Workout {
        let schedule = Schedule.days(Weekdays(days: [2, 4]))    // mon and wed
        let workout = Workout("Upper", schedule)
        
        workout.addExercise(exercise: testExercises["Light Bench"]!)
        workout.addExercise(exercise: testExercises["OHP"]!)
        workout.addExercise(exercise: testExercises["Face Pulls"]!)

        return workout
    }

    func makeLower() -> Workout {
        let schedule = Schedule.days(Weekdays(days: [6]))       // friday
        let workout = Workout("Lower", schedule)

        workout.addExercise(exercise: testExercises["Quad Stretch"]!)
        workout.addExercise(exercise: testExercises["Squat"]!)
        workout.addExercise(exercise: testExercises["Deadlift"]!)

        return workout
    }

    func makeActiveRest() -> Workout {
        let schedule = Schedule.every(2)
        let workout = Workout("Active Rest", schedule)

        workout.addExercise(exercise: testExercises["Quad Stretch"]!)
        workout.addExercise(exercise: testExercises["Third World Squat"]!)
        workout.addExercise(exercise: testExercises["Cossack Squat"]!)

        return workout
    }

    let program = Program(name: "Preview")
    program.active = true
    program.addWorkout(makeUpper())
    program.addWorkout(makeLower())
    program.addWorkout(makeActiveRest())
    return program
}

let testWeightSets: [String: WeightSet] = makePreviewWeightSets()
let testExercises: [String: Exercise] = makePreviewExercises()
let testProgram: Program = makePreviewProgram()
