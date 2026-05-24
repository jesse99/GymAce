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
    let cable = DiscreteWeights(weights: [2.5, 7.5, 12.5, 17.5, 22.5, 27.5, 32.5, 37.5, 42.5, 47.5, 52.5, 57.5, 62.5, 67.5, 72.5, 77.5, 82.5, 87.5, 92.5, 97.5], units: .Imperial)
    model.weightSets["Cable Machine"] = WeightSet.discrete(cable)

    let dumbbells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0], units: .Imperial)
    model.weightSets["Dumbbells"] = WeightSet.discrete(dumbbells)

    var plates = [Plate(2.5, 2), Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
    var dual = DualPlates(plates: plates, bar: 45.0, units: .Imperial)
    model.weightSets["Dual Plates"] = WeightSet.dual(dual)

    plates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
    dual = DualPlates(plates: plates, bar: 60.0, units: .Imperial)
    model.weightSets["Trapbar"] = WeightSet.dual(dual)
}

fileprivate func addCompletedReps(_ exercise: Exercise, daysAgo: Int, sets: [Int], weight: Float? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let c = Completed(reps: sets, weight: weight, units: .Imperial, completed: d!)
    exercise.history.append(c)
}

fileprivate func addCompletedSecs(_ exercise: Exercise, daysAgo: Int, sets: [Int], weight: Float? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let c = Completed(secs: sets, weight: weight, units: .Imperial, completed: d!)
    exercise.history.append(c)
}

fileprivate func addPreviewExercises(_ program: Program) {    
    let warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
    let dwarmup = [FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 75), FixedReps(reps: 1, percent: 90)]
    
    let reps3 = [VariableReps(3, to: 5), VariableReps(3, to: 5), VariableReps(3, to: 5)]
    let reps5 = [VariableReps(5), VariableReps(5), VariableReps(5)]
    let reps12 = [VariableReps(8, to: 12), VariableReps(8, to: 12), VariableReps(8, to: 12)]

    let backoff = [FixedReps(reps: 5, percent: 80)]

    var exercise = makeReps("Light Bench", "Bench Press", warmups: warmup, worksets: reps5, weights: "Dual Plates", weight: 130, rest: 10)
    addCompletedReps(exercise, daysAgo: 5, sets: [5, 5, 5], weight: 130)
    addCompletedReps(exercise, daysAgo: 3, sets: [5, 5, 5], weight: 135)
    addCompletedReps(exercise, daysAgo: 1, sets: [5, 5, 5], weight: 135)
    program.exercises.append(exercise)

    exercise = makeReps("Heavy Bench", "Bench Press", warmups: warmup, worksets: reps3, weights: "Dual Plates", weight: 145, rest: 12)
    program.exercises.append(exercise)
    
    exercise = makeReps("OHP", "Overhead Press", warmups: warmup, worksets: reps3, weights: "Dual Plates", weight: 80, rest: 9)
    program.exercises.append(exercise)

    exercise = makeReps("Squat", "High bar Squat", warmups: warmup, worksets: reps3, weights: "Dual Plates", weight: 140, rest: 8)
    program.exercises.append(exercise)

    exercise = makeReps("Deadlift", "Deadlift", warmups: dwarmup, worksets: reps3, backoff: backoff, weights: "Dual Plates", weight: 230, rest: 10)
    program.exercises.append(exercise)

    exercise = makeReps("Light Face Pulls", "Face Pull", worksets: reps5, weights: "Cable Machine", weight: 40.0, rest: nil)
    program.exercises.append(exercise)

    exercise = makeReps("Face Pulls", "Face Pull", worksets: reps12, weights: "Cable Machine", weight: 40.0, rest: 10)
    program.exercises.append(exercise)

    exercise = makeDurations("Quad Stretch", "Standing Quad Stretch", secs: [10, 20, 30])
    addCompletedSecs(exercise, daysAgo: 5, sets: [10, 10, 10])
    addCompletedSecs(exercise, daysAgo: 3, sets: [20, 20, 20])
    addCompletedSecs(exercise, daysAgo: 1, sets: [20, 20, 20])
    program.exercises.append(exercise)

    exercise = makeDurations("Third World Squat", "Third World Squat", secs: [20, 30, 40], weights: "Dumbbells", weight: 80.0)
    program.exercises.append(exercise)

    exercise = makeDurations("Cossack Squat", "Cossack Squat", secs: [30, 30, 30, 40])
    program.exercises.append(exercise)
}

func addPreviewProgram(_ model: Model) {
    func addUpper(_ program: Program) {
        let schedule = Schedule.days(Weekdays(days: [2, 4]))    // mon and wed
        let workout = Workout("Upper", schedule)
        workout.weeks = 1...3
        
        workout.addExercise(name: "Light Bench")
        workout.addExercise(name: "Heavy Bench")
        workout.addExercise(name: "OHP")
        workout.addExercise(name: "Light Face Pulls")
        workout.addExercise(name: "Face Pulls")
        
        program.addWorkout(workout)
    }

    func addLower(_ program: Program) {
        let schedule = Schedule.days(Weekdays(days: [6]))       // friday
        let workout = Workout("Lower", schedule)
        workout.weeks = 1...3

        workout.addExercise(name: "Quad Stretch")
        workout.addExercise(name: "Squat")
        workout.addExercise(name: "Deadlift")

        program.addWorkout(workout)
    }

    func addActiveRest(_ program: Program) {
        let schedule = Schedule.anyDay
        let workout = Workout("Active Rest", schedule)
        workout.weeks = 4...4

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
    model.notes.addDefaults()
    addPreviewWeightSets(model)
    addPreviewProgram(model)
    return model
}
