import Foundation

// TODO when adding a new program verify that the links the exercises use all work
let defaultPrograms: [Program] = [myProgram(), previewProgram(), stopgapProgram()]

func findDefaultWeightSet(_ name: String) -> WeightSet? {
    if name == "Cable Machine" {
        let cable = DiscreteWeights(weights: [2.5, 7.5, 12.5, 17.5, 22.5, 27.5, 32.5, 37.5, 42.5, 47.5, 52.5, 57.5, 62.5, 67.5, 72.5, 77.5, 82.5, 87.5, 92.5, 97.5], units: .Imperial)
        return WeightSet.discrete(cable)
    } else if name == "Dumbbells" {
        let dumbbells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0], units: .Imperial)
        return WeightSet.discrete(dumbbells)
    } else if name == "Dual Plates" {
        let plates = [Plate(2.5, 2), Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
        let dual = PlateWeights(dual: true, plates: plates, bar: 45.0, units: .Imperial)
        return WeightSet.plates(dual)
    } else if name == "Trapbar" {
        let plates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
        let dual = PlateWeights(dual: true, plates: plates, bar: 60.0, units: .Imperial)
        return WeightSet.plates(dual)
    } else if name == "Home Dumbbells" {
        let dumbbells = DiscreteWeights(weights: [5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0, 30.0, 40.0, 45.0, 52.5], units: .Imperial)
        return WeightSet.discrete(dumbbells)
    } else {
        return nil
    }
}

/// For previews
func previewModel() -> Model {
    let model = Model()
    model.activeProgram = "Preview"
    model.programs.append(previewProgram())
    model.addMissingWeightsets()
    return model
}

// TODO Get rid of this at some point
fileprivate func myProgram() -> Program {
    func addMyExercises(_ program: Program) {
        let warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
        let owarmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
        let dwarmup = [FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
        
        let reps1: [VariableRep] = [.variable(3, 5)]
        let reps2: [VariableRep] = [.variable(3, 5), .variable(3, 5)]
        let reps3: [VariableRep] = [.variable(3, 5), .variable(3, 5), .variable(3, 5)]
        let reps12: [VariableRep] = [.variable(8, 12), .variable(8, 12), .variable(8, 12)]

        var exercise = make("Quad Stretch", "Standing Quad Stretch", secs: [30])
        program.exercises.append(exercise)

        exercise = make("Light Squat", "High bar Squat", "Heavy Squat", percent: 90, warmups: warmup, worksets: [.fixed(5), .fixed(5), .fixed(5)], weights: "Dual Plates", rest: Int(3.5*60))
        program.exercises.append(exercise)

        exercise = make("Heavy Squat", "High bar Squat", warmups: warmup, worksets: reps2, weights: "Dual Plates", weight: 145, rest: Int(3.5*60))
        program.exercises.append(exercise)

        exercise = make("Face Pulls", "Face Pull", warmups: [], worksets: reps12, weights: "Cable Machine", weight: 32.5, rest: Int(2.5*60))
        program.exercises.append(exercise)

        exercise = make("Trap Deadlift", "Trap Bar Deadlift", warmups: dwarmup, worksets: reps1, weights: "Trapbar", weight: 235, rest: nil)
        program.exercises.append(exercise)
        
        exercise = make("Light Bench", "Bench Press", "Heavy Bench", percent: 90, warmups: warmup, worksets: [.fixed(5), .fixed(5), .fixed(5)], weights: "Dual Plates", rest: Int(3.0*60))
        program.exercises.append(exercise)

        exercise = make("Heavy Bench", "Bench Press", warmups: warmup, worksets: reps2, weights: "Dual Plates", weight: 145, rest: Int(3.5*60))
        program.exercises.append(exercise)

        let creps: [VariableRep] = [.variable(3, 8), .variable(3, 8)]
        exercise = make("Chin Ups", "Chin-up", warmups: [], worksets: creps, weights: "Dumbbells", weight: 30, rest: Int(3.0*60))
        program.exercises.append(exercise)

        exercise = make("OHP", "Overhead Press", warmups: owarmup, worksets: reps3, weights: "Dual Plates", weight: 80, rest: Int(3.0*60))
        program.exercises.append(exercise)

        exercise = make("DB OHP", "Overhead Press", warmups: dwarmup, worksets: reps3, weights: "Dumbbells", weight: 30, rest: Int(3.0*60))
        program.exercises.append(exercise)
    }

    func addBench(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.tuesday]))
        let workout = Workout("Bench", schedule)
        workout.weeks = 1...6
        
        workout.addExercise(name: "Heavy Bench")
        workout.addExercise(name: "OHP")
        workout.addExercise(name: "DB OHP")
        workout.addExercise(name: "Chin Ups")
        
        program.addWorkout(workout)
    }

    func addSquat(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.thursday]))
        let workout = Workout("Squat", schedule)
        workout.weeks = 1...7

        workout.addExercise(name: "Light Bench")
        workout.addExercise(name: "Quad Stretch")
        workout.addExercise(name: "Heavy Squat")
        workout.addExercise(name: "Chin Ups")
        
        program.addWorkout(workout)
    }

    func addDeadlift(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.sunday]))
        let workout = Workout("Deadlift", schedule)
        workout.weeks = 1...7

        workout.addExercise(name: "Quad Stretch")
        workout.addExercise(name: "Light Squat")
        workout.addExercise(name: "Face Pulls")
        workout.addExercise(name: "Trap Deadlift")
        
        program.addWorkout(workout)
    }

    func addRest(_ program: Program) {
        let schedule = Schedule.anyDay
        let workout = Workout("Rest", schedule)
        workout.weeks = 8...8
        
        program.addWorkout(workout)
    }

    let program = Program("My")
    program.summary = "The program GH is currently using. Requires a gym and is designed for an older lifter."
    addMyExercises(program)
    addBench(program)
    addSquat(program)
    addDeadlift(program)
    addRest(program)
    return program
}

/// Simulator only program used for testing.
fileprivate func previewProgram() -> Program {   // TODO get rid of this?
    func addExercises(_ program: Program) {
        let warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
        let dwarmup = [FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 75), FixedReps(reps: 1, percent: 90)]
        
        let reps3: [VariableRep] = [.variable(3, 5), .variable(3, 5), .variable(3, 5)]
        let reps5: [VariableRep] = [.fixed(5), .fixed(5), .fixed(5)]
        let areps5: [VariableRep] = [.fixed(5), .fixed(5), .amrap(5)]
        let reps12: [VariableRep] = [.variable(8, 12), .variable(8, 12), .variable(8, 12)]

        let backoff = [FixedReps(reps: 5, percent: 80)]

        var exercise = make("Light Bench", "Bench Press", warmups: warmup, worksets: areps5, weights: "Dual Plates", weight: 130, rest: 10)
        addCompleted(exercise, daysAgo: 5, reps: [5, 5, 5], weight: 130, note: "So hard, nearly died")
        addCompleted(exercise, daysAgo: 3, reps: [5, 5, 5], weight: 135, note: "Went up easy peasy")
        addCompleted(exercise, daysAgo: 1, reps: [5, 5, 5], weight: 135)
        program.exercises.append(exercise)

        exercise = make("Heavy Bench", "Bench Press", warmups: warmup, worksets: reps3, weights: "Dual Plates", weight: 145, rest: 12)
        program.exercises.append(exercise)
        
        exercise = make("OHP", "Overhead Press", warmups: warmup, worksets: reps3, weights: "Dual Plates", weight: 80, rest: 9)
        program.exercises.append(exercise)

        exercise = make("Squat", "High bar Squat", warmups: warmup, worksets: reps3, weights: "Dual Plates", weight: 140, rest: 8)
        program.exercises.append(exercise)

        exercise = make("Deadlift", "Deadlift", warmups: dwarmup, worksets: reps3, backoff: backoff, weights: "Dual Plates", weight: 230, rest: 10)
        program.exercises.append(exercise)

        exercise = make("Light Face Pulls", "Face Pull", worksets: reps5, weights: "Cable Machine", weight: 40.0, rest: nil)
        program.exercises.append(exercise)

        exercise = make("Face Pulls", "Face Pull", worksets: reps12, weights: "Cable Machine", weight: 40.0, rest: 10)
        program.exercises.append(exercise)

        exercise = make("Quad Stretch", "Standing Quad Stretch", secs: [10, 20, 30])
        addCompleted(exercise, daysAgo: 5, secs: [10, 10, 10])
        addCompleted(exercise, daysAgo: 3, secs: [20, 20, 20])
        addCompleted(exercise, daysAgo: 1, secs: [20, 20, 20])
        program.exercises.append(exercise)

        exercise = make("Third World Squat", "Third World Squat", secs: [20, 30, 40], weights: "Dumbbells", weight: 80.0)
        program.exercises.append(exercise)

        exercise = make("Cossack Squat", "Cossack Squat", secs: [30, 30, 30, 40])
        program.exercises.append(exercise)

        exercise = make("Walk", "Walking")
        program.exercises.append(exercise)
    }

    func addUpper(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.monday, .wednesday]))
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
        let schedule = Schedule.days(Weekdays([.friday]))
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
        workout.addExercise(name: "Walk")

        program.addWorkout(workout)
    }

    let program = Program("Preview")
    program.summary = "A program for testing the app."
    addExercises(program)
    addUpper(program)
    addLower(program)
    addActiveRest(program)
    return program
}

fileprivate func stopgapProgram() -> Program {
    func addExercises(_ program: Program) {
        let reps: [VariableRep] = [.variable(3, 10), .variable(3, 10), .variable(3, 10)]
        let areps: [VariableRep] = [.amrap(3), .amrap(3), .amrap(3)]

        var exercise = make("Split Squat", "Dumbbell Single Leg Split Squat", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 60)
        program.exercises.append(exercise)

        exercise = make("Floor Press", "Dumbbell Floor Press", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 60)
        program.exercises.append(exercise)

        exercise = make("Shoulder Press", "Dumbbell Seated Shoulder Press", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 60)
        program.exercises.append(exercise)

        exercise = make("Deadlift", "Dumbbell Deadlift", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 60)
        program.exercises.append(exercise)

        exercise = make("Plank", "Plank", secs: [30, 30, 30])
        program.exercises.append(exercise)

        exercise = make("Row", "Bent Over Dumbbell Row", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 60)
        program.exercises.append(exercise)
        
        // optional
        exercise = make("Lunge", "Dumbbell Lunge", warmups: [], worksets: areps, weights: "Home Dumbbells", weight: 5, rest: 60)
        program.exercises.append(exercise)

        exercise = make("Dips", "Dips", warmups: [], worksets: areps, rest: 60)
        program.exercises.append(exercise)

        exercise = make("Pull-ups", "Pull-up", warmups: [], worksets: areps, rest: 60)
        program.exercises.append(exercise)
    }

    func addA(_ program: Program, _ workout: Workout) {
        workout.addExercise(name: "Split Squat")
        workout.addExercise(name: "Lunge", enabled: false)
        workout.addExercise(name: "Floor Press")
        workout.addExercise(name: "Deadlift")
        workout.addExercise(name: "Pull-ups", enabled: false)
        workout.addExercise(name: "Plank")
        program.addWorkout(workout)
    }

    func addB(_ program: Program, _ workout: Workout) {
        workout.addExercise(name: "Split Squat")
        workout.addExercise(name: "Lunge", enabled: false)
        workout.addExercise(name: "Shoulder Press")
        workout.addExercise(name: "Row")
        workout.addExercise(name: "Dips", enabled: false)
        workout.addExercise(name: "Plank")
        program.addWorkout(workout)
    }

    // First week is A B A
    func addA1(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.monday, .friday]))
        let workout = Workout("A1", schedule)
        workout.weeks = 1...1
        addA(program, workout)
    }

    func addB1(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.wednesday]))
        let workout = Workout("B1", schedule)
        workout.weeks = 1...1
        addB(program, workout)
    }

    // Second week is B A B
    func addA2(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.wednesday]))
        let workout = Workout("A2", schedule)
        workout.weeks = 2...2
        addA(program, workout)
    }

    func addB2(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.monday, .friday]))
        let workout = Workout("B2", schedule)
        workout.weeks = 2...2
        addB(program, workout)
    }

    let program = Program("Dumbbell Stopgap")
    program.summary = "[Designed](https://thefitness.wiki/reddit-archive/dumbbell-stopgap/) for home workouts with a small set of dummbells (or adjustable dumbbells) though it can also be used at a gym. Note that there are some optional exercises that you can enable using Edit Program on the top right of the main screen."
    addExercises(program)
    addA1(program)
    addB1(program)
    addA2(program)
    addB2(program)
    for w in program.workouts {
        w.notes = "Start with easy weights. Increase the weight once you can do all three sets of ten. If you get stuck at the same number of reps and weight three times, then drop the weight by two increments and continue. For planks hold them as long as you can."
    }
    return program
}

fileprivate func make(_ name: String, _ formalName: String, secs: [Int], weights: String? = nil, weight: Float? = nil) -> Exercise {
    let durations = DurationsData(secs: secs, targetSecs: nil)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, durations: durations, weights: n, weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, durations: durations)
    }
}

fileprivate func make(_ name: String, _ formalName: String, warmups: [FixedReps] = [], worksets: [VariableRep], backoff: [FixedReps] = [], weights: String? = nil, weight: Float? = nil, rest: Int? = nil) -> Exercise {
    let reps = RepsData(warmups: warmups, worksets: worksets, backoff: backoff, rest: rest)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, reps: reps, weights: n, weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, reps: reps)
    }
}

fileprivate func make(_ name: String, _ formalName: String, _ other: String, percent: Int, warmups: [FixedReps], worksets: [VariableRep], weights: String, rest: Int) -> Exercise {
    let percent = PercentData(other: other, percent: percent, warmups: warmups, workset: worksets, rest: rest)
    return Exercise(name: name, formalName: formalName, percent: percent, weights: weights)
}

/// timed
fileprivate func make(_ name: String, _ formalName: String) -> Exercise {
    return Exercise(name: name, formalName: formalName, weights: nil)
}

fileprivate func addCompleted(_ exercise: Exercise, daysAgo: Int, reps: [Int], weight: Float? = nil, note: String? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let c = Completed(reps: reps, weight: weight, units: .Imperial, completed: d!)
    c.note = note
    exercise.history.append(c)
}

fileprivate func addCompleted(_ exercise: Exercise, daysAgo: Int, secs: [Int], weight: Float? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let c = Completed(secs: secs, weight: weight, units: .Imperial, completed: d!)
    exercise.history.append(c)
}

