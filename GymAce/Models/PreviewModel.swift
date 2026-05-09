import Foundation

fileprivate func makeDurations(_ name: String, _ formalName: String, secs: [Int], weights: String? = nil, weight: Float? = nil) -> Exercise {
    let durations = DurationsData(secs: secs, targetSecs: nil)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, durations: durations, weights: n, weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, durations: durations)
    }
}

fileprivate func makeReps(_ name: String, _ formalName: String, warmups: [FixedReps] = [], worksets: [VariableReps], backoff: [FixedReps] = [], weights: String? = nil, weight: Float? = nil, rest: Int? = nil) -> Exercise {
    let reps = RepsData(warmups: warmups, worksets: worksets, backoff: backoff, rest: rest)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, reps: reps, weights: n, weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, reps: reps)
    }
}

fileprivate func addPreviewWeightSets(_ model: Model) {
    let cable = DiscreteWeights(weights: [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0], units: .Imperial)
    model.weightSets["Cable"] = WeightSet.discrete(cable)

    let dumbbells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0], units: .Imperial)
    model.weightSets["Dumbbells"] = WeightSet.discrete(dumbbells)

    let plates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 4)]
    let dual = DualPlates(plates: plates, bar: 45.0, units: .Imperial)
    model.weightSets["Dual"] = WeightSet.dual(dual)
}

fileprivate func addPreviewExercises(_ program: Program) {    
    let warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
    let dwarmup = [FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 75), FixedReps(reps: 1, percent: 90)]
    
    let reps3 = [VariableReps(3, to: 5), VariableReps(3, to: 5), VariableReps(3, to: 5)]
    let reps5 = [VariableReps(5), VariableReps(5), VariableReps(5)]
    let reps12 = [VariableReps(8, to: 12), VariableReps(8, to: 12), VariableReps(8, to: 12)]

    let backoff = [FixedReps(reps: 5, percent: 80)]

    var exercise = makeReps("Light Bench", "Bench Press", warmups: warmup, worksets: reps5, weights: "Dual", weight: 130, rest: 10)
    program.exercises.append(exercise)

    exercise = makeReps("Heavy Bench", "Bench Press", warmups: warmup, worksets: reps3, weights: "Dual", weight: 145, rest: 12)
    program.exercises.append(exercise)
    
    exercise = makeReps("OHP", "Bench Press", warmups: warmup, worksets: reps3, weights: "Dual", weight: 80, rest: 9)
    program.exercises.append(exercise)

    exercise = makeReps("Squat", "High bar Squat", warmups: warmup, worksets: reps3, weights: "Dual", weight: 140, rest: 8)
    program.exercises.append(exercise)

    exercise = makeReps("Deadlift", "Deadlift", warmups: dwarmup, worksets: reps3, backoff: backoff, weights: "Dual", weight: 230, rest: 10)
    program.exercises.append(exercise)

    exercise = makeReps("Face Pulls", "Face Pulls", worksets: reps12, weights: "Cable", weight: 40.0, rest: 5)
    program.exercises.append(exercise)

    exercise = makeDurations("Quad Stretch", "Quad Stretch", secs: [10, 20, 30])
    program.exercises.append(exercise)

    exercise = makeDurations("Third World Squat", "Third World Squat2", secs: [20, 30, 40], weights: "Dumbbells", weight: 80.0)
    program.exercises.append(exercise)

    exercise = makeDurations("Cossack Squat", "Quad Stretch", secs: [30, 30, 30, 40])
    program.exercises.append(exercise)
}

func addPreviewProgram(_ model: Model) {
    func addUpper(_ program: Program) {
        let schedule = Schedule.days(Weekdays(days: [2, 4]))    // mon and wed
        let workout = Workout("Upper", schedule)
        
        workout.addExercise(name: "Light Bench")
        workout.addExercise(name: "OHP")
        workout.addExercise(name: "Face Pulls")
        
        program.addWorkout(workout)
    }

    func addLower(_ program: Program) {
        let schedule = Schedule.days(Weekdays(days: [6]))       // friday
        let workout = Workout("Lower", schedule)

        workout.addExercise(name: "Quad Stretch")
        workout.addExercise(name: "Squat")
        workout.addExercise(name: "Deadlift")

        program.addWorkout(workout)
    }

    func addActiveRest(_ program: Program) {
        let schedule = Schedule.every(2)
        let workout = Workout("Active Rest", schedule)

        workout.addExercise(name: "Quad Stretch")
        workout.addExercise(name: "Third World Squat")
        workout.addExercise(name: "Cossack Squat")

        program.addWorkout(workout)
    }

    let program = Program("Preview")
    addPreviewExercises(program)
    addUpper(program)
    addLower(program)
    addActiveRest(program)
    model.programs.append(program)
}

func previewModel() -> Model {
    let model = Model()
    model.activeProgram = "Preview"
    addPreviewWeightSets(model)
    addPreviewProgram(model)
    return model
}
