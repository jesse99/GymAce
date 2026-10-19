// TODO should rename this file
import Foundation

func defaultWeightSets(_ units: Units) -> [String: WeightSet] {
    if case .Metric = units {
        return metricWeights()
    } else {
        return imperialWeights()
    }
}

fileprivate func imperialWeights() -> [String: WeightSet] {
    var sets: [String: WeightSet] = [:]
    
    let upperPlates = [Plate(2.5, 2), Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
    let lowerPlates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]

    var dual = PlateWeights(dual: true, plates: lowerPlates, bar: 45.0, units: .Imperial)
    sets["Dual Lower Plates"] = WeightSet.plates(dual)

    dual = PlateWeights(dual: true, plates: upperPlates, bar: 45.0, units: .Imperial)
    sets["Dual Upper Plates"] = WeightSet.plates(dual)
    
    var single = PlateWeights(dual: false, plates: lowerPlates, bar: 45.0, units: .Imperial)
    sets["Single Lower Plates"] = WeightSet.plates(single)
    
    single = PlateWeights(dual: false, plates: upperPlates, bar: 45.0, units: .Imperial)
    sets["Single Upper Plates"] = WeightSet.plates(single)

    dual = PlateWeights(dual: true, plates: lowerPlates, bar: 0.0, units: .Imperial)
    sets["Dual Lower Plates no bar"] = WeightSet.plates(dual)

    dual = PlateWeights(dual: true, plates: upperPlates, bar: 0.0, units: .Imperial)
    sets["Dual Upper Plates no bar"] = WeightSet.plates(dual)

    single = PlateWeights(dual: false, plates: lowerPlates, bar: 0.0, units: .Imperial)
    sets["Single Lower Plates no bar"] = WeightSet.plates(single)

    single = PlateWeights(dual: false, plates: upperPlates, bar: 0.0, units: .Imperial)
    sets["Single Upper Plates no bar"] = WeightSet.plates(single)
    
    dual = PlateWeights(dual: true, plates: lowerPlates, bar: 60.0, units: .Imperial)
    sets["Trapbar"] = WeightSet.plates(dual)

    let cable = DiscreteWeights(weights: [2.5, 7.5, 12.5, 17.5, 22.5, 27.5, 32.5, 37.5, 42.5, 47.5, 52.5, 57.5, 62.5, 67.5, 72.5, 77.5, 82.5, 87.5, 92.5, 97.5], units: .Imperial)
    sets["Cable Machine"] = WeightSet.discrete(cable)

    var dumbbells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0], units: .Imperial)
    sets["Dumbbells"] = WeightSet.discrete(dumbbells)

    dumbbells = DiscreteWeights(weights: [5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0, 30.0, 40.0, 45.0, 52.5], units: .Imperial)
    sets["Home Dumbbells"] = WeightSet.discrete(dumbbells)

    let kettlebells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 40.0, 50], units: .Imperial)
    sets["Kettlebells"] = WeightSet.discrete(kettlebells)
    
    return sets
}

fileprivate func metricWeights() -> [String: WeightSet] {
    var sets: [String: WeightSet] = [:]
    
    let upperPlates = [Plate(1.25, 2), Plate(2.5, 4), Plate(5.0, 4), Plate(10.0, 4), Plate(20.0, 6)]
    let lowerPlates = [Plate(2.5, 4), Plate(5.0, 4), Plate(10.0, 4), Plate(20.0, 6)]

    var dual = PlateWeights(dual: true, plates: lowerPlates, bar: 20, units: .Metric)
    sets["Dual Lower Plates"] = WeightSet.plates(dual)

    dual = PlateWeights(dual: true, plates: upperPlates, bar: 20, units: .Metric)
    sets["Dual Upper Plates"] = WeightSet.plates(dual)
    
    var single = PlateWeights(dual: false, plates: lowerPlates, bar: 20, units: .Metric)
    sets["Single Lower Plates"] = WeightSet.plates(single)
    
    single = PlateWeights(dual: false, plates: upperPlates, bar: 20, units: .Metric)
    sets["Single Upper Plates"] = WeightSet.plates(single)

    dual = PlateWeights(dual: true, plates: lowerPlates, bar: 0.0, units: .Metric)
    sets["Dual Lower Plates no bar"] = WeightSet.plates(dual)

    dual = PlateWeights(dual: true, plates: upperPlates, bar: 0.0, units: .Metric)
    sets["Dual Upper Plates no bar"] = WeightSet.plates(dual)

    single = PlateWeights(dual: false, plates: lowerPlates, bar: 0.0, units: .Metric)
    sets["Single Lower Plates no bar"] = WeightSet.plates(single)

    single = PlateWeights(dual: false, plates: upperPlates, bar: 0.0, units: .Metric)
    sets["Single Upper Plates no bar"] = WeightSet.plates(single)
    
    dual = PlateWeights(dual: true, plates: lowerPlates, bar: 25, units: .Metric)
    sets["Trapbar"] = WeightSet.plates(dual)

    let cable = DiscreteWeights(weights: [2.5, 5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0, 27.5, 30.0, 32.5, 35.0, 37.5, 40.0, 42.5, 45.0, 47.5, 50.0], units: .Metric)
    sets["Cable Machine"] = WeightSet.discrete(cable)

    var dumbbells = DiscreteWeights(weights: [2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 30.0, 32.0, 34.0, 36.0, 38.0, 40.0, 42.0, 44.0, 46.0, 48.0, 50.0], units: .Metric)
    sets["Dumbbells"] = WeightSet.discrete(dumbbells)

    dumbbells = DiscreteWeights(weights: [2.5, 5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0, 27.5, 30.0, 32.5, 35.0, 37.5, 40.0, 42.5, 45.0, 47.5, 50.0], units: .Metric)
    sets["Dumbbells2"] = WeightSet.discrete(dumbbells)

    dumbbells = DiscreteWeights(weights: [2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0], units: .Metric)
    sets["Home Dumbbells"] = WeightSet.discrete(dumbbells)

    dumbbells = DiscreteWeights(weights: [2.5, 5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0], units: .Metric)
    sets["Home Dumbbells2"] = WeightSet.discrete(dumbbells)

    let kettlebells = DiscreteWeights(weights: [4, 6, 8, 12, 16, 20, 24, 28], units: .Metric)
    sets["Kettlebells"] = WeightSet.discrete(kettlebells)
    
    return sets
}

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

// Public for unit tests
func make(_ name: String, _ formalName: String, _ styleName: String, weights: String? = nil, weight: Float? = nil) -> Exercise {
    let w = if let x = weight {
        BaseWeight.weight(x)
    } else {
        BaseWeight.none
    }
    if let n = weights {
        return Exercise(name: name, formalName: formalName, styleName: styleName, weights: n, weight: w)
    } else {
        return Exercise(name: name, formalName: formalName, styleName: styleName, weight: w)
    }
}

func make(_ name: String, _ formalName: String, _ styleName: String, weights: String? = nil, base: BaseWeight) -> Exercise {
    if let n = weights {
        return Exercise(name: name, formalName: formalName, styleName: styleName, weights: n, weight: base)
    } else {
        return Exercise(name: name, formalName: formalName, styleName: styleName, weight: base)
    }
}

// Public for unit tests
func addCompleted(_ program: Program, _ exercise: Exercise, daysAgo: Int, reps: [Int], weights: [Float]? = nil, note: String? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let b = exercise.findBaseWeight(program)
    let c = Completed(reps: reps, weights: weights, baseWeight: b, units: .Imperial, completed: d!)
    c.note = note
    exercise.history.append(c)
}

// Public for unit tests
func addCompleted(_ program: Program, _ exercise: Exercise, daysAgo: Int, secs: [Int], weights: [Float]? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let b = exercise.findBaseWeight(program)
    let c = Completed(secs: secs, weights: weights, baseWeight: b, units: .Imperial, completed: d!)
    exercise.history.append(c)
}

// TODO may want to move these to wizard
func amrapStyle(warmup: String, workset: String, rest: String) -> Style {
    if let i = AMRAPInfo(warmup: warmup, workset: workset, rest: rest) {
        return .amrap(i)
    } else {
        fatalError("bad args")
    }
}

func basicStyle(warmup: String, workset: String, rest: String) -> Style {
    if let i = BasicInfo(warmup: warmup, workset: workset, rest: rest) {
        return .basic(i)
    } else {
        fatalError("bad args")
    }
}

func manualStyle(warmup: String, workset: String, rest: String) -> Style {
    if let i = VariableInfo(warmup: warmup, workset: workset, rest: rest) {
        return .manual(i)
    } else {
        fatalError("bad args")
    }
}

func variableStyle(warmup: String, workset: String, rest: String) -> Style {
    if let i = VariableInfo(warmup: warmup, workset: workset, rest: rest) {
        return .variable(i)
    } else {
        fatalError("bad args")
    }
}

func oneRepMaxStyle(warmup: String, workset: String, rest: String) -> Style {
    if let i = OneRepMaxInfo(warmup: warmup, workset: workset, rest: rest) {
        return .oneRepMax(i)
    } else {
        fatalError("bad args")
    }
}

func durationsStyle(secs: String, targetSecs: String) -> Style {
    if let i = DurationsInfo(secs: secs, targetSecs: targetSecs) {
        return .durations(i)
    } else {
        fatalError("bad args")
    }
}

