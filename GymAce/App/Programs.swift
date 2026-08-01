import Foundation

// TODO when adding a new program verify that the links the exercises use all work
let defaultPrograms: [Program] = [boringButBigProgram3(), boringButBigProgram4(), complexBeginner(), complexIntermediate(), dumbbellPPL4(), dumbbellPPL7(), myProgram(), previewProgram(), stopgapProgram(), strongCurves1()]

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
    } else if name == "Kettlebells" {
        let kettlebells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 40.0, 50], units: .Imperial)
        return WeightSet.discrete(kettlebells)
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
        
        let reps1: [VariableReps] = [.variable(3, 5)]
        let reps2: [VariableReps] = [.variable(3, 5), .variable(3, 5)]
        let reps3: [VariableReps] = [.variable(3, 5), .variable(3, 5), .variable(3, 5)]
        let reps12: [VariableReps] = [.variable(8, 12), .variable(8, 12), .variable(8, 12)]

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

        let creps: [VariableReps] = [.variable(3, 8), .variable(3, 8)]
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

func add531Exercises(_ program: Program) {
    let warmup = [FixedReps(reps: 5, percent: 40), FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 60)]
    
    let warmup2 = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
    let reps5: [VariableReps] = [.fixed(5, 65), .fixed(5, 75), .amrap(5, 85)]
    let reps3: [VariableReps] = [.fixed(3, 70), .fixed(3, 80), .amrap(3, 90)]
    let reps1: [VariableReps] = [.fixed(5, 75), .fixed(3, 85), .amrap(1, 90)]
    let repsd: [VariableReps] = [.fixed(5, 40), .fixed(5, 50), .fixed(5, 60)]
    let reps10: [VariableReps] = [.fixed(10, 30), .fixed(10, 40), .fixed(10, 50), .fixed(10, 60), .fixed(10, 70)]

    // 1 rep max
    var exercise = make("Max OHP", "Overhead Press", warmups: warmup2, oneRepMax: true, weights: "Dual Plates", weight: 80)
    program.exercises.append(exercise)

    exercise = make("Max Bench", "Bench Press", warmups: warmup2, oneRepMax: true, weights: "Dual Plates", weight: 160)
    program.exercises.append(exercise)
    
    exercise = make("Max Deadlift", "Deadlift", warmups: warmup2, oneRepMax: true, weights: "Dual Plates", weight: 200)
    program.exercises.append(exercise)
    
    exercise = make("Max Squat", "Low bar Squat", warmups: warmup2, oneRepMax: true, weights: "Dual Plates", weight: 225)
    program.exercises.append(exercise)

    // 5 reps part of 531
    exercise = make("OHP 5", "Overhead Press", "Max OHP", percent: 100, warmups: warmup, worksets: reps5, weights: "Dual Plates", rest: 2*60)
    program.exercises.append(exercise)
    
    exercise = make("Deadlift 5", "Deadlift", "Max Deadlift", percent: 100, warmups: warmup, worksets: reps5, weights: "Dual Plates", rest: 3*60)
    program.exercises.append(exercise)

    exercise = make("Squat 5", "Low bar Squat", "Max Squat", percent: 100, warmups: warmup, worksets: reps5, weights: "Dual Plates", rest: 3*60)
    program.exercises.append(exercise)

    exercise = make("Bench 5", "Bench Press", "Max Bench", percent: 100, warmups: warmup, worksets: reps5, weights: "Dual Plates", rest: 2*60)
    program.exercises.append(exercise)

    // 3 reps part of 531
    exercise = make("OHP 3", "Overhead Press", "Max OHP", percent: 100, warmups: warmup, worksets: reps3, weights: "Dual Plates", rest: 2*60)
    program.exercises.append(exercise)
    
    exercise = make("Deadlift 3", "Deadlift", "Max Deadlift", percent: 100, warmups: warmup, worksets: reps3, weights: "Dual Plates", rest: 3*60)
    program.exercises.append(exercise)

    exercise = make("Squat 3", "Low bar Squat", "Max Squat", percent: 100, warmups: warmup, worksets: reps3, weights: "Dual Plates", rest: 3*60)
    program.exercises.append(exercise)

    exercise = make("Bench 3", "Bench Press", "Max Bench", percent: 100, warmups: warmup, worksets: reps3, weights: "Dual Plates", rest: 2*60)
    program.exercises.append(exercise)

    // 1 rep part of 531
    exercise = make("OHP 1", "Overhead Press", "Max OHP", percent: 100, warmups: warmup, worksets: reps1, weights: "Dual Plates", rest: 2*60)
    program.exercises.append(exercise)
    
    exercise = make("Deadlift 1", "Deadlift", "Max Deadlift", percent: 100, warmups: warmup, worksets: reps1, weights: "Dual Plates", rest: 1*60)
    program.exercises.append(exercise)

    exercise = make("Squat 1", "Low bar Squat", "Max Squat", percent: 100, warmups: warmup, worksets: reps1, weights: "Dual Plates", rest: 1*60)
    program.exercises.append(exercise)

    exercise = make("Bench 1", "Bench Press", "Max Bench", percent: 100, warmups: warmup, worksets: reps1, weights: "Dual Plates", rest: 2*60)
    program.exercises.append(exercise)
    
    // deload
    exercise = make("OHP deload", "Overhead Press", "Max OHP", percent: 100, warmups: warmup, worksets: repsd, weights: "Dual Plates", rest: 2*60)
    program.exercises.append(exercise)
    
    exercise = make("Deadlift deload", "Deadlift", "Max Deadlift", percent: 100, warmups: warmup, worksets: repsd, weights: "Dual Plates", rest: 1*60)
    program.exercises.append(exercise)

    exercise = make("Squat deload", "Low bar Squat", "Max Squat", percent: 100, warmups: warmup, worksets: repsd, weights: "Dual Plates", rest: 1*60)
    program.exercises.append(exercise)

    exercise = make("Bench deload", "Bench Press", "Max Bench", percent: 100, warmups: warmup, worksets: repsd, weights: "Dual Plates", rest: 2*60)
    program.exercises.append(exercise)

    // 5 sets of 10 reps
    exercise = make("Bench Press", "Bench Press", "Max Bench", percent: 100, warmups: [], worksets: reps10, weights: "Dual Plates", rest: 2*60)
    program.exercises.append(exercise)
    
    exercise = make("Deadlift", "Deadlift", "Max Deadlift", percent: 100, warmups: [], worksets: reps10, weights: "Dual Plates", rest: 3*60)
    program.exercises.append(exercise)

    exercise = make("Squat", "Low bar Squat", "Max Squat", percent: 100, warmups: [], worksets: reps10, weights: "Dual Plates", rest: 3*60)
    program.exercises.append(exercise)

    exercise = make("OHP", "Overhead Press", "Max OHP", percent: 100, warmups: [], worksets: reps10, weights: "Dual Plates", rest: 2*60)
    program.exercises.append(exercise)

    // accessories
    let creps: [VariableReps] = [.fixed(10), .fixed(10), .fixed(10), .fixed(10), .fixed(10)]
    exercise = make("Chin Ups", "Chin-up", warmups: [], worksets: creps, weights: "Dumbbells", weight: 0, rest: 2*60)
    program.exercises.append(exercise)

    let areps: [VariableReps] = [.fixed(1), .fixed(1), .fixed(1), .fixed(1), .fixed(1)]
    exercise = make("Ab Wheel", "Ab Wheel Rollout", warmups: [], worksets: areps, rest: 2*60)
    program.exercises.append(exercise)
}

func add531Max(_ program: Program) {
    let schedule = Schedule.anyDay
    let workout = Workout("One Rep Max", schedule)
    
    workout.addExercise(name: "Max Bench")
    workout.addExercise(name: "Max OHP")
    workout.addExercise(name: "Max Squat")
    workout.addExercise(name: "Max Deadlift")

    program.addWorkout(workout)
}

fileprivate func boringButBigProgram3() -> Program {
    func wname(_ week: Int) -> String {
        if week == 5 {
            return "deload"
        } else {
            return "\(week)"
        }
    }

    func addPress(_ program: Program, _ day: Weekdays.Day, _ week: Int, _ version: String) {
        let schedule = Schedule.days(Weekdays([day]))
        let workout = Workout("Press \(wname(week))", schedule)
        workout.weeks = week...week
        
        workout.addExercise(name: "OHP \(version)")
        workout.addExercise(name: "Bench Press")
        workout.addExercise(name: "Chin Ups")
        
        program.addWorkout(workout)
    }

    func addDeadlift(_ program: Program, _ day: Weekdays.Day, _ week: Int, _ version: String) {
        let schedule = Schedule.days(Weekdays([day]))
        let workout = Workout("Deadlift \(wname(week))", schedule)
        workout.weeks = week...week

        workout.addExercise(name: "Deadlift \(version)")
        workout.addExercise(name: "Squat")
        workout.addExercise(name: "Ab Wheel")

        program.addWorkout(workout)
    }

    func addBench(_ program: Program, _ day: Weekdays.Day, _ week: Int, _ version: String) {
        let schedule = Schedule.days(Weekdays([day]))
        let workout = Workout("Bench \(wname(week))", schedule)
        workout.weeks = week...week

        workout.addExercise(name: "Bench \(version)")
        workout.addExercise(name: "OHP")
        workout.addExercise(name: "Chin Ups")

        program.addWorkout(workout)
    }

    func addSquat(_ program: Program, _ day: Weekdays.Day, _ week: Int, _ version: String) {
        let schedule = Schedule.days(Weekdays([day]))
        let workout = Workout("Squat \(wname(week))", schedule)
        workout.weeks = week...week

        workout.addExercise(name: "Squat \(version)")
        workout.addExercise(name: "Deadlift")
        workout.addExercise(name: "Ab Wheel")
        
        if version == "deload" {
            workout.notes = "If you were able to hit the rep goals for an exercise then use Edit Exercise to up the weight for the \"Max\" version of the exercise. Otherwise drop the weight by 10% for that exercise."
        }

        program.addWorkout(workout)
    }

    let program = Program("531 Boring but Big 3")
    program.summary = "[This](https://www.jimwendler.com/blogs/jimwendler-com/101077382-boring-but-big) is a high volume program for intermediate to advanced lifters. This version is three days a week and uses a five week cycle with one deload week. The exercises use percentages based on your one rep max for the exercise (set these using Edit Exercise, e.g. for \"Max Bench\"). When starting out use a low weight, espcially for the lower body exercises."
    add531Exercises(program)
    add531Max(program)

    addPress(program, .monday, 1, "5")
    addDeadlift(program, .wednesday, 1, "5")
    addBench(program, .friday, 1, "5")

    addSquat(program, .monday, 2, "5")
    addPress(program, .wednesday, 2, "3")
    addDeadlift(program, .friday, 2, "3")

    addBench(program, .monday, 3, "3")
    addSquat(program, .wednesday, 3, "3")
    addPress(program, .friday, 3, "1")

    addDeadlift(program, .monday, 4, "1")
    addBench(program, .wednesday, 4, "1")
    addSquat(program, .friday, 4, "1")

    addPress(program, .monday, 5, "deload")
    addBench(program, .wednesday, 5, "deload")
    addSquat(program, .friday, 5, "deload")

    return program
}

fileprivate func boringButBigProgram4() -> Program {
    func wname(_ week: Int) -> String {
        if week == 4 {
            return "deload"
        } else {
            return "\(week)"
        }
    }

    func suffix(_ week: Int) -> String {
        if week == 1 {
            return "5"
        } else if week == 2 {
            return "3"
        } else if week == 3 {
            return "1"
        } else {
            return "deload"
        }
    }

    func addPress(_ program: Program, _ week: Int) {
        let schedule = Schedule.days(Weekdays([.monday]))
        let workout = Workout("Press \(wname(week))", schedule)
        workout.weeks = week...week
        
        workout.addExercise(name: "OHP \(suffix(week))")
        workout.addExercise(name: "Bench Press")
        workout.addExercise(name: "Chin Ups")
        
        program.addWorkout(workout)
    }

    func addDeadlift(_ program: Program, _ week: Int) {
        let schedule = Schedule.days(Weekdays([.tuesday]))
        let workout = Workout("Deadlift \(wname(week))", schedule)
        workout.weeks = week...week

        workout.addExercise(name: "Deadlift \(suffix(week))")
        workout.addExercise(name: "Squat")
        workout.addExercise(name: "Ab Wheel")
        
        program.addWorkout(workout)
    }

    func addBench(_ program: Program, _ week: Int) {
        let schedule = Schedule.days(Weekdays([.thursday]))
        let workout = Workout("Bench \(wname(week))", schedule)
        workout.weeks = week...week

        workout.addExercise(name: "Bench \(suffix(week))")
        workout.addExercise(name: "OHP")
        workout.addExercise(name: "Chin Ups")

        program.addWorkout(workout)
    }

    func addSquat(_ program: Program, _ week: Int) {
        let schedule = Schedule.days(Weekdays([.friday]))
        let workout = Workout("Squat \(wname(week))", schedule)
        workout.weeks = week...week

        workout.addExercise(name: "Squat \(suffix(week))")
        workout.addExercise(name: "Deadlift")
        workout.addExercise(name: "Ab Wheel")
        
        if week == 4 {
            workout.notes = "If you were able to hit the rep goals for an exercise then use Edit Exercise to up the weight for the \"Max\" version of the exercise. Otherwise drop the weight by 10% for that exercise."
        }

        program.addWorkout(workout)
    }

    let program = Program("531 Boring but Big 4")
    program.summary = "[This](https://www.jimwendler.com/blogs/jimwendler-com/101077382-boring-but-big) is a high volume program for intermediate to advanced lifters. This version is four days a week and uses a four week cycle with one deload week. The exercises use percentages based on your one rep max for the exercise (set these using Edit Exercise, e.g. for \"Max Bench\"). When starting out use a low weight, espcially for the lower body exercises. You can substitute in alternate versions of exercises but you shouldn't add new exercises to this program."
    add531Exercises(program)
    add531Max(program)
    for week in 1...4 {
        addPress(program, week)
        addDeadlift(program, week)
        addBench(program, week)
        addSquat(program, week)
    }
    return program
}

fileprivate func complexBeginner() -> Program {
    let program = Program("Complex - beginner")
    program.summary = "[Complexes](https://lipsticklifters.com/articles/dumbbell-complex/) are a blend between cardio and weight lifting. The idea is that you peform a set of exercises with a fixed weight without resting or setting the weight down, do a short rest, and repeat. Unless you are in great shape this will quickly get intense so start with a weight much lighter than what you can do for one of the exercises."

    let reps: [VariableReps] = [.fixed(1), .fixed(1), .fixed(1)]
    let exercise = make("Complex", "Complex - beginner", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
    program.exercises.append(exercise)

    let schedule = Schedule.days(Weekdays([.monday, .wednesday, .friday]))
    let workout = Workout("Complex", schedule)
    workout.addExercise(name: "Complex")
    program.addWorkout(workout)

    return program
}

fileprivate func complexIntermediate() -> Program {
    let program = Program("Complex - intermediate")
    program.summary = "[Complexes](https://lipsticklifters.com/articles/dumbbell-complex/) are a blend between cardio and weight lifting. The idea is that you peform a set of exercises with a fixed weight without resting or setting the weight down, do a short rest, and repeat. Unless you are in great shape this will quickly get intense so start with a weight much lighter than what you can do for one of the exercises."

    let reps: [VariableReps] = [.fixed(1), .fixed(1), .fixed(1), .fixed(1)]
    let exercise = make("Complex", "Complex - intermediate", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 10, rest: 90)
    program.exercises.append(exercise)

    let schedule = Schedule.days(Weekdays([.monday, .wednesday, .friday]))
    let workout = Workout("Complex", schedule)
    workout.addExercise(name: "Complex")
    program.addWorkout(workout)

    return program
}

fileprivate func dumbbellPPL47() -> (Program, Program) {
    func addExercises(_ program: Program) {
        let reps: [VariableReps] = [.variable(4, 12), .variable(4, 12), .variable(4, 12)]

        var exercise = make("Chest Press", "Dumbbell Bench Press", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Incline Fly", "Dumbbell Incline Flyes", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Arnold Press", "Arnold Press", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Overhead Tricep Extension", "Standing Triceps Press", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
        program.exercises.append(exercise)

        
        exercise = make("Split Squat", "Dumbbell Single Leg Split Squat", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Bent-over Row", "Bent Over Dumbbell Row", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Reverse Fly", "Reverse Flyes", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Shrug", "Dumbbell Shrug", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Bicep Curl", "Concentration Curls", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
        program.exercises.append(exercise)

        
        exercise = make("Pull-ups", "Pull-up", warmups: [], worksets: reps, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Goblet Squat", "Goblet Squat", warmups: [], worksets: reps, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Lunge", "Dumbbell Lunge", warmups: [], worksets: reps, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Single Leg Deadlift", "Single Leg Dumbbell Deadlift", warmups: [], worksets: reps, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Calf Raise", "One-Leg DB Calf Raises", warmups: [], worksets: reps, rest: 90)
        program.exercises.append(exercise)


        exercise = make("Hanging Leg Raises", "Hanging Leg Raise", warmups: [], worksets: reps, rest: 90)
        program.exercises.append(exercise)
    }

    func push1(_ program: Program) {
        let workout = Workout("Push1", .cyclic)
        workout.addExercise(name: "Chest Press")
        workout.addExercise(name: "Incline Fly")
        workout.addExercise(name: "Arnold Press")
        workout.addExercise(name: "Overhead Tricep Extension")
        program.addWorkout(workout)
    }

    func pull1(_ program: Program) {
        let workout = Workout("Pull1", .cyclic)
        workout.addExercise(name: "Pull-ups")
        workout.addExercise(name: "Bent-over Row")
        workout.addExercise(name: "Reverse Fly")
        workout.addExercise(name: "Shrug")
        workout.addExercise(name: "Bicep Curl")
        workout.addExercise(name: "Hanging Leg Raises")
        program.addWorkout(workout)
    }

    func legs1(_ program: Program) {
        let workout = Workout("Legs1", .cyclic)
        workout.addExercise(name: "Goblet Squat")
        workout.addExercise(name: "Split Squat", enabled: false)
        workout.addExercise(name: "Lunge")
        workout.addExercise(name: "Single Leg Deadlift")
        workout.addExercise(name: "Calf Raise")
        program.addWorkout(workout)
    }

    func rest1(_ program: Program) {
        let workout = Workout("Rest1", .cyclic)
        program.addWorkout(workout)
    }

    func push2(_ program: Program) {
        let workout = Workout("Push2", .cyclic)
        workout.addExercise(name: "Chest Press")
        workout.addExercise(name: "Incline Fly")
        workout.addExercise(name: "Arnold Press")
        workout.addExercise(name: "Overhead Tricep Extension")
        workout.addExercise(name: "Hanging Leg Raises")
        program.addWorkout(workout)
    }

    func pull2(_ program: Program) {
        let workout = Workout("Pull2", .cyclic)
        workout.addExercise(name: "Pull-ups")
        workout.addExercise(name: "Bent-over Row")
        workout.addExercise(name: "Reverse Fly")
        workout.addExercise(name: "Shrug")
        workout.addExercise(name: "Bicep Curl")
        program.addWorkout(workout)
    }

    func legs2(_ program: Program) {
        let workout = Workout("Legs2", .cyclic)
        workout.addExercise(name: "Goblet Squat")
        workout.addExercise(name: "Split Squat", enabled: false)
        workout.addExercise(name: "Lunge")
        workout.addExercise(name: "Single Leg Deadlift")
        workout.addExercise(name: "Calf Raise")
        workout.addExercise(name: "Hanging Leg Raises")
        program.addWorkout(workout)
    }

    func rest(_ program: Program, suffix: String) {
        let workout = Workout("Rest\(suffix)", .cyclic)
        program.addWorkout(workout)
    }

    let program4 = Program("Dumbbell PPL4")
    program4.summary = "A Push/Pull/Legs beginner [program](https://thefitness.wiki/reddit-archive/dumbbell-stopgap-ppl/) that requires minimal equipment. Note that there are some optional exercises that you can enable using Edit Program on the top right of the main screen. This version uses a 4 day cycle with one rest day."
    addExercises(program4)
    push1(program4)
    pull1(program4)
    legs1(program4)
    rest(program4, suffix: "1")
    push2(program4)
    pull2(program4)
    legs2(program4)
    rest(program4, suffix: "2")
    for w in program4.workouts {
        w.notes = "Increase weight once you can do twelve reps for all three sets. If you can't increase weight or reps for an exercise after three tries then deload the weight for that exercise by two increments."
    }

    let program7 = Program("Dumbbell PPL7")
    program7.summary = "A Push/Pull/Legs beginner [program](https://thefitness.wiki/reddit-archive/dumbbell-stopgap-ppl/) that requires minimal equipment. Note that there are some optional exercises that you can enable using Edit Program on the top right of the main screen. This version uses a 7 day cycle with one rest day."
    addExercises(program7)
    push1(program7)
    pull1(program7)
    legs1(program7)
    push2(program7)
    pull2(program7)
    legs2(program7)
    rest(program4, suffix: "")
    for w in program7.workouts {
        w.notes = "Increase weight once you can do twelve reps for all three sets. If you can't increase weight or reps for an exercise after three tries then deload the weight for that exercise by two increments."
    }
    return (program4, program7)
}

fileprivate func dumbbellPPL4() -> Program {
    let (program, _) = dumbbellPPL47()
    return program
}

fileprivate func dumbbellPPL7() -> Program {
    let (_, program) = dumbbellPPL47()
    return program
}

/// Simulator only program used for testing.
fileprivate func previewProgram() -> Program {   // TODO get rid of this?
    func addExercises(_ program: Program) {
        let warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
        let dwarmup = [FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 75), FixedReps(reps: 1, percent: 90)]
        
        let reps3: [VariableReps] = [.variable(3, 5), .variable(3, 5), .variable(3, 5)]
        let reps5: [VariableReps] = [.fixed(5), .fixed(5), .fixed(5)]
        let areps5: [VariableReps] = [.fixed(5), .fixed(5), .amrap(5)]
        let reps12: [VariableReps] = [.variable(8, 12), .variable(8, 12), .variable(8, 12)]

        let backoff = [FixedReps(reps: 5, percent: 80)]

        var exercise = make("Light Bench", "Bench Press", warmups: warmup, worksets: areps5, weights: "Dual Plates", weight: 130, rest: 10)
        addCompleted(exercise, daysAgo: 5, reps: [5, 5, 5], weights: [130], note: "So hard, nearly died")
        addCompleted(exercise, daysAgo: 3, reps: [5, 5, 5], weights: [135], note: "Went up easy peasy")
        addCompleted(exercise, daysAgo: 1, reps: [5, 5, 5], weights: [135])
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
        let reps: [VariableReps] = [.variable(3, 10), .variable(3, 10), .variable(3, 10)]
        let areps: [VariableReps] = [.amrap(3), .amrap(3), .amrap(3)]

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

fileprivate func strongCurves1() -> Program {
    func addExercises(_ program: Program) {
        // Workout A 1-4
        var exercise = make("Glute Bridge", "Glute Bridge", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("One-arm Row", "Kroc Row", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 20, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Box Squat", "Body-weight Box Squat", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("DB Bench Press", "Dumbbell Bench Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 20, rest: 90)
        program.exercises.append(exercise)

        exercise = make("DB Romanian Deadlift", "Dumbbell Romanian Deadlift", workstr: "10-20 10-20 10-20", weights: "Dumbbells", weight: 20, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Side Lying Abduction", "Side Lying Abduction", workstr: "15-30 15-30", rest: 90)
        program.exercises.append(exercise)
        
        exercise = make("Front Plank", "Plank", secs: [20], target: 120)
        program.exercises.append(exercise)

        exercise = make("Side Plank", "Kneeling Side Plank", secs: [20, 20], target: 60)
        program.exercises.append(exercise)

        // Workout B 1-4
        exercise = make("Single-leg Glute Bridge", "Single Leg Glute Bridge", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Lat Pulldown", "Lat Pulldown", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 30, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Step-ups", "Step-ups", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Overhead Press", "Overhead Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 10, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Back Extension", "Back Extension", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Crunches", "Swiss Ball Hip Internal Rotation", workstr: "15-30", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Side Crunch", "Exercise Ball Side Crunch", workstr: "15-30 15-30", rest: 90)
        program.exercises.append(exercise)

        // Workout C 1-4        
        exercise = make("Glute March", "Glute March", secs: [60, 60, 60])
        program.exercises.append(exercise)

        exercise = make("Cable Row", "Seated Cable Row", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 30, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Squat", "Body-weight Squat", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Incline Press", "Dumbbell Incline Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 10, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Single-Leg Romanian Deadlift", "Body-weight Single-Leg Romanian Deadlift", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("X-Band Walk (light)", "X-Band Walk", workstr: "10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("RKC Plank", "RKC Plank", secs: [10], target: 30)
        program.exercises.append(exercise)

        exercise = make("Cable Wood Chop", "Cable Wood Chop", workstr: "5-10 5-10", weights: "Cable Machine", weight: 20, rest: 90)
        program.exercises.append(exercise)

        // Workout A 5-8
        exercise = make("Body-weight Hip Thrust", "Body-weight Hip Thrust", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Standing One Arm Cable Row", "Standing One Arm Cable Row", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 20, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Step Up + Reverse Lunge", "Body-weight Step Up + Reverse Lunge", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Bench Press", "Bench Press", workstr: "8-12 8-12 8-12", weights: "Dual Plates", weight: 55, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Romanian Deadlift", "Romanian Deadlift", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 65, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Side Lying Abduction", "Side Lying Abduction", workstr: "15-30 15-30", rest: 90)
        program.exercises.append(exercise)
        
        exercise = make("Feet Elevated Plank", "Plank", secs: [20], target: 60)
        program.exercises.append(exercise)

//        exercise = make("Side Plank", "Kneeling Side Plank", secs: [20], target: 60)

        // Workout B 5-8
//        exercise = make("Single-leg Glute Bridge", "Single Leg Glute Bridge", workstr: "10-20 10-20", rest: 90)

        exercise = make("Negative Chin-ups", "Chin-up", workstr: "3 3 3", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Walking Lunge", "Body-weight Walking Lunge", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

//        exercise = make("Overhead Press", "Overhead Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 10, rest: 90)

        exercise = make("Reverse Hyper", "Reverse Hyperextension", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Clam", "Clam", workstr: "15-30 15-30", rest: 90)
        program.exercises.append(exercise)

//        exercise = make("Crunches", "Swiss Ball Hip Internal Rotation", workstr: "15-30", rest: 90)
//        exercise = make("Side Crunch", "Exercise Ball Side Crunch", workstr: "15-30 15-30", rest: 90)

        // Workout C 5-8
        exercise = make("Hip Thrust (rest pause)", "Hip Thrust (rest pause)", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Inverted Row", "Inverted Row", workstr: "8-12 8-12 8-12", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Goblet Squat", "Goblet Squat", workstr: "10-20 10-20 10-20", weights: "Dumbbells", weight: 30, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Close-Grip Bench Press", "Close-Grip Bench Press", workstr: "8-12 8-12 8-12", weights: "Dual Plates", weight: 45, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Kettlebell Swing", "Kettlebell Two Arm Swing", workstr: "10-20 10-20 10-20", weights: "Kettlebells", weight: 20, rest: 90)
        program.exercises.append(exercise)

        exercise = make("X-Band Walk (moderate)", "X-Band Walk", workstr: "15-30 15-30", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Situp", "Situp", workstr: "15-30", rest: 90)
        program.exercises.append(exercise)

        exercise = make("Band Rotary Hold", "Band Anti-Rotary Hold", secs: [10, 10], target: 20)
        program.exercises.append(exercise)

        // Workout A 9-12
        exercise = make("Hip Thrust", "Hip Thrust", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 65, rest: 90)
        program.exercises.append(exercise)
        
//        exercise = make("One-arm Row", "Kroc Row", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 10, rest: 90)

        exercise = make("Box Squat", "Box Squat", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 65, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Pushup", "Pushup", workstr: "3-10 3-10 3-10", rest: 90)
        program.exercises.append(exercise)
        
        exercise = make("Deadlift", "Deadlift", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 75, rest: 90)
        program.exercises.append(exercise)
        
//        exercise = make("Side Lying Abduction", "Side Lying Abduction", workstr: "15-30 15-30", rest: 90)
//        exercise = make("Crunches", "Swiss Ball Hip Internal Rotation", workstr: "15-30", rest: 90)

        exercise = make("Anti-Rotation Press", "Half-kneeling Cable Anti-Rotation Press", workstr: "10-15 10-15", weights: "Cable Machine", weight: 20, rest: 90)
        program.exercises.append(exercise)

        // Workout B 9-12
        exercise = make("Hip Thrust (shoulders elevated)", "Hip Thrust (shoulders elevated)", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)
        
        exercise = make("Chin-ups", "Chin-up", workstr: "1-5 1-5 1-5", rest: 90)
        program.exercises.append(exercise)
        
        exercise = make("Bulgarian Split Squat", "Body-weight Bulgarian Split Squat", workstr: "10-20 10-20 10-20", rest: 90)
        program.exercises.append(exercise)
        
//        exercise = make("Overhead Press", "Overhead Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 10, rest: 90)
        
        exercise = make("Good Morning", "Good Morning", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 65, rest: 90)
        program.exercises.append(exercise)
        
//        exercise = make("X-Band Walk (moderate)", "X-Band Walk", workstr: "10-20 10-20", rest: 90)
        exercise = make("Feet Elevated Plank 2", "Plank", secs: [60], target: 120)
        
        exercise = make("Side Bend", "Dumbbell Side Bend", workstr: "15-30 15-30", weights: "Dumbbells", weight: 20, rest: 90)
        program.exercises.append(exercise)

        // Workout C 9-12  Inverted Row
        exercise = make("Hip Thrust (pause rep)", "Hip Thrust", workstr: "8-15 8-15 8-15", weights: "Dual Plates", weight: 65, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Dumbbell Incline Row", "Dumbbell Incline Row", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 20, rest: 90)
        program.exercises.append(exercise)
        
        exercise = make("High bar Squat", "High bar Squat", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 65, rest: 90)
        program.exercises.append(exercise)

        exercise = make("Incline Bench Press", "Incline Bench Press", workstr: "3-10 3-10 3-10", weights: "Dual Plates", weight: 45, rest: 90)
        program.exercises.append(exercise)
        
        exercise = make("Back Extension2", "Back Extension", workstr: "10-30 10-30 10-30", rest: 90)
        program.exercises.append(exercise)
        
//        exercise = make("Clam", "Clam", workstr: "15-30 15-30", rest: 90)
        
        exercise = make("Hanging Leg Raise", "Hanging Leg Raise", workstr: "10-20", rest: 90)
        program.exercises.append(exercise)
        
//        exercise = make("Cable Wood Chop", "Cable Wood Chop", workstr: "10-15 10-15", weights: "Cable Machine", weight: 30, rest: 90)
    }
    
    func addA14(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.monday, .thursday]))
        let workout = Workout("A14", schedule)
        workout.weeks = 1...4
        workout.addExercise(name: "Glute Bridge")   // TODO super set these two
        workout.addExercise(name: "One-arm Row")
        workout.addExercise(name: "Box Squat")   // TODO super set these two
        workout.addExercise(name: "DB Bench Press")
        workout.addExercise(name: "DB Romanian Deadlift")
        workout.addExercise(name: "Side Lying Abduction")
        workout.addExercise(name: "Front Plank")
        workout.addExercise(name: "Side Plank")
        program.addWorkout(workout)
    }

    func addB14(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.tuesday]))
        let workout = Workout("B14", schedule)
        workout.weeks = 1...4
        workout.addExercise(name: "Single-leg Glute Bridge")   // TODO super set these two
        workout.addExercise(name: "Lat Pulldown")
        workout.addExercise(name: "Step-ups")   // TODO super set these two
        workout.addExercise(name: "Overhead Press")
        workout.addExercise(name: "Back Extension")
        workout.addExercise(name: "Crunches")
        workout.addExercise(name: "Side Crunch")
        program.addWorkout(workout)
    }

    func addC14(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.friday]))
        let workout = Workout("C14", schedule)
        workout.weeks = 1...4
        workout.addExercise(name: "Glute March")   // TODO super set these two
        workout.addExercise(name: "Cable Row")
        workout.addExercise(name: "Squat")   // TODO super set these two
        workout.addExercise(name: "Incline Press")
        workout.addExercise(name: "Single-Leg Romanian Deadlift")
        workout.addExercise(name: "X-Band Walk (light)")
        workout.addExercise(name: "RKC Plank")
        workout.addExercise(name: "Cable Wood Chop")
        program.addWorkout(workout)
    }

    func addA58(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.monday, .thursday]))
        let workout = Workout("A58", schedule)
        workout.weeks = 5...8
        workout.addExercise(name: "Body-weight Hip Thrust")   // TODO super set these two
        workout.addExercise(name: "Standing One Arm Cable Row")
        workout.addExercise(name: "Step Up + Reverse Lunge")   // TODO super set these two
        workout.addExercise(name: "Bench Press")
        workout.addExercise(name: "Romanian Deadlift")
        workout.addExercise(name: "Side Lying Abduction")
        workout.addExercise(name: "Feet Elevated Plank")
        workout.addExercise(name: "Side Plank")
        program.addWorkout(workout)
    }

    func addB58(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.tuesday]))
        let workout = Workout("B58", schedule)
        workout.weeks = 5...8
        workout.addExercise(name: "Single-leg Glute Bridge")   // TODO super set these two
        workout.addExercise(name: "Negative Chin-ups")
        workout.addExercise(name: "Walking Lunge")   // TODO super set these two
        workout.addExercise(name: "Overhead Press")
        workout.addExercise(name: "Reverse Hyper")
        workout.addExercise(name: "Clam")
        workout.addExercise(name: "Crunches")
        workout.addExercise(name: "Side Crunch")
        program.addWorkout(workout)
    }

    func addC58(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.friday]))
        let workout = Workout("C58", schedule)
        workout.weeks = 5...8
        workout.addExercise(name: "Hip Thrust (rest pause)")   // TODO super set these two
        workout.addExercise(name: "Inverted Row")
        workout.addExercise(name: "Goblet Squat")   // TODO super set these two
        workout.addExercise(name: "Close-Grip Bench Press")
        workout.addExercise(name: "Kettlebell Swing")
        workout.addExercise(name: "X-Band Walk (moderate)")
        workout.addExercise(name: "Situp")
        workout.addExercise(name: "Band Rotary Hold")
        program.addWorkout(workout)
    }

    func addA912(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.monday, .thursday]))
        let workout = Workout("A912", schedule)
        workout.weeks = 9...42              // 42 so users can keep going for a while if they want
        workout.addExercise(name: "Hip Thrust")   // TODO super set these two
        workout.addExercise(name: "One-arm Row")
        workout.addExercise(name: "Box Squat")   // TODO super set these two
        workout.addExercise(name: "Pushup")
        workout.addExercise(name: "Deadlift")
        workout.addExercise(name: "Side Lying Abduction")
        workout.addExercise(name: "Crunches")
        workout.addExercise(name: "Anti-Rotation Press")
        program.addWorkout(workout)
    }

    func addB912(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.tuesday]))
        let workout = Workout("B912", schedule)
        workout.weeks = 9...42
        workout.addExercise(name: "Hip Thrust (shoulders elevated)")   // TODO super set these two
        workout.addExercise(name: "Chin-ups")
        workout.addExercise(name: "Bulgarian Split Squat")   // TODO super set these two
        workout.addExercise(name: "Overhead Press")
        workout.addExercise(name: "Good Morning")
        workout.addExercise(name: "X-Band Walk (moderate)")
        workout.addExercise(name: "Feet Elevated Plank 2")
        workout.addExercise(name: "Side Bend")
        program.addWorkout(workout)
    }

    func addC912(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.friday]))
        let workout = Workout("C912", schedule)
        workout.weeks = 9...42
        workout.addExercise(name: "Hip Thrust (pause rep)")   // TODO super set these two
        workout.addExercise(name: "Dumbbell Incline Row")
        workout.addExercise(name: "High bar Squat")   // TODO super set these two
        workout.addExercise(name: "Incline Bench Press")
        workout.addExercise(name: "Back Extension2")
        workout.addExercise(name: "Clam")
        workout.addExercise(name: "Hanging Leg Raise")
        workout.addExercise(name: "Cable Wood Chop")
        program.addWorkout(workout)
    }

    let program = Program("Strong Curves beginner")
    program.summary = "A 12-week four workouts a week [program](https://www.amazon.com/Strong-Curves-Womans-Building-Better/dp/1936608642) designed for women. After the 12 weeks are up you can continue the week 9-12 workouts or switch to the advanced program."
    addExercises(program)
    addA14(program)
    addB14(program)
    addC14(program)

    addA58(program)
    addB58(program)
    addC58(program)

    addA912(program)
    addB912(program)
    addC912(program)
    return program
}

fileprivate func make(_ name: String, _ formalName: String, secs: [Int], target: Int? = nil, weights: String? = nil, weight: Float? = nil) -> Exercise {
    let durations = DurationsData(secs: secs, targetSecs: target)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, durations: durations, weights: n, weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, durations: durations)
    }
}

fileprivate func make(_ name: String, _ formalName: String, warmups: [FixedReps] = [], oneRepMax: Bool, weights: String? = nil, weight: Float? = nil) -> Exercise {
    let reps = OneRepMaxData(warmups: warmups)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, orm: reps, weights: n, weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, orm: reps)
    }
}

fileprivate func make(_ name: String, _ formalName: String, warmups: [FixedReps] = [], worksets: [VariableReps], backoff: [FixedReps] = [], weights: String? = nil, weight: Float? = nil, rest: Int? = nil) -> Exercise {
    let reps = RepsData(warmups: warmups, worksets: worksets, backoff: backoff, rest: rest)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, reps: reps, weights: n, weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, reps: reps)
    }
}

fileprivate func make(_ name: String, _ formalName: String, warmups: [FixedReps] = [], workstr: String, weights: String? = nil, weight: Float? = nil, rest: Int? = nil) -> Exercise {
    let worksets: [VariableReps] = workstr.split(separator: " ").map {
        VariableReps(String($0))!
    }
    let reps = RepsData(warmups: warmups, worksets: worksets, backoff: [], rest: rest)
    if let n = weights {
        return Exercise(name: name, formalName: formalName, reps: reps, weights: n, weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, reps: reps)
    }
}

fileprivate func make(_ name: String, _ formalName: String, _ other: String, percent: Int, warmups: [FixedReps], worksets: [VariableReps], weights: String, rest: Int) -> Exercise {
    let percent = PercentData(other: other, percent: percent, warmups: warmups, workset: worksets, rest: rest)
    return Exercise(name: name, formalName: formalName, percent: percent, weights: weights)
}

/// timed
fileprivate func make(_ name: String, _ formalName: String) -> Exercise {
    return Exercise(name: name, formalName: formalName, weights: nil)
}

fileprivate func addCompleted(_ exercise: Exercise, daysAgo: Int, reps: [Int], weights: [Float]? = nil, note: String? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let c = Completed(reps: reps, weights: weights, units: .Imperial, completed: d!)
    c.note = note
    exercise.history.append(c)
}

fileprivate func addCompleted(_ exercise: Exercise, daysAgo: Int, secs: [Int], weights: [Float]? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let c = Completed(secs: secs, weights: weights, units: .Imperial, completed: d!)
    exercise.history.append(c)
}

