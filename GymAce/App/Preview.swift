import Foundation

func previewModel() -> Model {
    let model = Model()
    model.activeProgram = "Preview"
    model.programs.append(previewProgram())
    model.addMissingWeightsets()
    return model
}

/// Simulator only program used for testing.
fileprivate func previewProgram() -> Program {
    func addStyles(_ program: Program) {
        program.styles["Main"] = variableStyle(warmup: "5/0 5/60 3/80 1/90", workset: "5 5 5", rest: "3m")
        program.styles["Manual"] = manualStyle(warmup: "5/0 5/60 3/80 1/90", workset: "5 5 5", rest: "3m")
        program.styles["Accessory"] = variableStyle(warmup: "", workset: "8-12 8-12 8-12", rest: "2m")
        program.styles["Light"] = basicStyle(warmup: "5/0 5/40 3/50 1/70", workset: "5/80 5/80 5/80", rest: "2m")
        program.styles["Stretch"] = durationsStyle(secs: "30s 30s 30s", targetSecs: "")
        program.styles["Walk"] = Style.timed
        program.styles["1RM"] = .oneRepMax(OneRepMaxInfo(warmup: "5/0 5/57 3/67 1/77", workset: "5", rest: "2m")!)  // workset is at 87%
        program.styles["AMRAP"] = amrapStyle(warmup: "5/40 3/50 1/70", workset: "3", rest: "3m")
    }
    
    func addExercises(_ program: Program) {
        var exercise = make("Light Bench", "Bench Press", "Light", weights: "Dual Upper Plates", base: .other)
        addCompleted(program, exercise, daysAgo: 5, reps: [5, 5, 5], weights: [130], note: "So hard, nearly died")
        addCompleted(program, exercise, daysAgo: 3, reps: [5, 5, 5], weights: [135], note: "Went up easy peasy")
        addCompleted(program, exercise, daysAgo: 1, reps: [5, 5, 5], weights: [135])
        program.exercises.append(exercise)

        exercise = make("Heavy Bench", "Bench Press", "Main", weights: "Dual Upper Plates", weight: 145)
        program.exercises.append(exercise)
        
        exercise = make("OHP", "Overhead Press", "Main", weights: "Dual Upper Plates", weight: 80)
        program.exercises.append(exercise)

        exercise = make("Manual OHP", "Overhead Press", "Manual", weights: "Dual Upper Plates", weight: 80)
        program.exercises.append(exercise)

        exercise = make("Squat", "High bar Squat", "Main", weights: "Dual Lower Plates", weight: 140)
        program.exercises.append(exercise)

        exercise = make("Max Squat", "High bar Squat", "1RM", weights: "Dual Lower Plates", weight: 140)
        program.exercises.append(exercise)

        exercise = make("Deadlift", "Deadlift", "Main", weights: "Dual Lower Plates", weight: 230)
        program.exercises.append(exercise)

        exercise = make("OHP (amrap)", "Overhead Press", "AMRAP", weights: "Dual Upper Plates", weight: 80)
        program.exercises.append(exercise)

        exercise = make("Light Face Pulls", "Face Pull", "Light", weights: "Cable Machine", base: .other)
        program.exercises.append(exercise)

        exercise = make("Face Pulls", "Face Pull", "Accessory", weights: "Cable Machine", weight: 40.0)
        program.exercises.append(exercise)

        exercise = make("Quad Stretch", "Standing Quad Stretch", "Stretch")
        addCompleted(program, exercise, daysAgo: 5, secs: [10, 10, 10])
        addCompleted(program, exercise, daysAgo: 3, secs: [20, 20, 20])
        addCompleted(program, exercise, daysAgo: 1, secs: [20, 20, 20])
        program.exercises.append(exercise)

        exercise = make("Third World Squat", "Third World Squat", "Accessory", weights: "Dumbbells", weight: 80.0)
        program.exercises.append(exercise)

        exercise = make("Cossack Squat", "Cossack Squat", "Stretch")
        program.exercises.append(exercise)

        exercise = make("Walk", "Walking", "Walk")
        program.exercises.append(exercise)
    }

    func addUpper(_ program: Program) {
        let schedule = Schedule.days(Weekdays([.monday, .wednesday]))
        let workout = Workout("Upper", schedule)
        workout.weeks = 1...3
        
        workout.addExercise(name: "Light Bench")
        workout.addExercise(name: "Heavy Bench")
        workout.addExercise(name: "OHP")
        workout.addExercise(name: "Manual OHP")
        workout.addExercise(name: "OHP (amrap)")
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
        workout.addExercise(name: "Max Squat")
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
    addStyles(program)
    addExercises(program)
    addUpper(program)
    addLower(program)
    addActiveRest(program)
    return program
}
