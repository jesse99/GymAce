import Foundation

// TODO when adding a new program verify that the links the exercises use all work
let defaultPrograms: [Program] = [previewProgram()]

func findDefaultWeightSet(_ name: String) -> WeightSet? {
    if name == "Cable Machine" {
        let cable = DiscreteWeights(weights: [2.5, 7.5, 12.5, 17.5, 22.5, 27.5, 32.5, 37.5, 42.5, 47.5, 52.5, 57.5, 62.5, 67.5, 72.5, 77.5, 82.5, 87.5, 92.5, 97.5], units: .Imperial)
        return WeightSet.discrete(cable)
    } else if name == "Deadlift" {
        let plates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
        let dual = PlateWeights(dual: true, plates: plates, bar: 45.0, units: .Imperial)
        return WeightSet.plates(dual)
    } else if name == "Dumbbells" {
        let dumbbells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0], units: .Imperial)
        return WeightSet.discrete(dumbbells)
    } else if name == "Dual Plates" {
        let plates = [Plate(2.5, 2), Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
        let dual = PlateWeights(dual: true, plates: plates, bar: 45.0, units: .Imperial)
        return WeightSet.plates(dual)
    } else if name == "Home Dumbbells" {
        let dumbbells = DiscreteWeights(weights: [5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0, 30.0, 40.0, 45.0, 52.5], units: .Imperial)
        return WeightSet.discrete(dumbbells)
    } else if name == "Kettlebells" {
        let kettlebells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 40.0, 50], units: .Imperial)
        return WeightSet.discrete(kettlebells)
    } else if name == "Single Plates" {
        let plates = [Plate(2.5, 2), Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
        let single = PlateWeights(dual: false, plates: plates, bar: 45.0, units: .Imperial)
        return WeightSet.plates(single)
    } else if name == "Smith Machine" {
        let plates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
        let dual = PlateWeights(dual: true, plates: plates, bar: 0.0, units: .Imperial)
        return WeightSet.plates(dual)
    } else if name == "Trapbar" {
        let plates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
        let dual = PlateWeights(dual: true, plates: plates, bar: 60.0, units: .Imperial)
        return WeightSet.plates(dual)
    } else {
        return nil
    }
}

/// For previews, TODO don't include this in program list?
func previewModel() -> Model {
    let model = Model()
    model.activeProgram = "Preview"
    model.programs.append(previewProgram())
    model.addMissingWeightsets()
    return model
}

//fileprivate func basic() -> Program {
//    func addExercises(_ program: Program) {
//        let warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//        let warmup2 = [FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80)]
//        let dwarmup = [FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//        
//        let reps: [VariableReps] = [.fixed(5, 100), .fixed(5, 100), .amrap(5, 100)]
//
//        var exercise = make("Pendlay Row", "Pendlay Row", warmups: warmup2, worksets: reps, weights: "Dual Plates", weight: 55, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Bench Press", "Bench Press", warmups: warmup, worksets: reps, weights: "Dual Plates", weight: 65, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Squat", "High bar Squat", warmups: warmup, worksets: reps, weights: "Dual Plates", weight: 85, rest: 3*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Chin Ups", "Chin-up", warmups: [], worksets: reps, rest: 3*60)
//        program.exercises.append(exercise)
//
//        exercise = make("OHP", "Overhead Press", warmups: warmup, worksets: reps, weights: "Dual Plates", weight: 55, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Deadlift", "Deadlift", warmups: dwarmup, worksets: reps, weights: "Deadlift", weight: 95, rest: 3*60)
//        program.exercises.append(exercise)
//        
//        exercise = make("Lat Pulldown", "Lat Pulldown", warmups: warmup2, worksets: reps, weights: "Cable Machine", weight: 30, rest: 2*60)
//        program.exercises.append(exercise)
//    }
//
//    func addSquat(_ program: Program, _ weekdays: Weekdays, week: Int) {
//        let schedule = Schedule.days(weekdays)
//        let workout = Workout("Squat \(week)", schedule)
//        workout.weeks = week...week
//        
//        workout.addExercise(name: "Pendlay Row")
//        workout.addExercise(name: "Bench Press")
//        workout.addExercise(name: "Squat")
//        
//        program.addWorkout(workout)
//    }
//
//    func addDead(_ program: Program, _ weekdays: Weekdays, week: Int) {
//        let schedule = Schedule.days(weekdays)
//        let workout = Workout("Deadlift \(week)", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "Chin Ups")
//        workout.addExercise(name: "Lat Pulldown", enabled: false)
//        workout.addExercise(name: "OHP")
//        workout.addExercise(name: "Deadlift")
//        
//        program.addWorkout(workout)
//    }
//
//    let program = Program("Basic Beginner")
//    program.summary = "A simple gym [program](https://thefitness.wiki/routines/r-fitness-basic-beginner-routine) for beginners. It's meant to be run for three months after which you should switch to another program like 531. Try to increase weights each workout. For the last sets do as many reps as you can but try to stop when you have 1-2 reps left."
//    addExercises(program)
//    addSquat(program, Weekdays([.monday, .friday]), week: 1)
//    addDead(program, Weekdays([.wednesday]), week: 1)
//    addDead(program, Weekdays([.monday, .friday]), week: 2)
//    addSquat(program, Weekdays([.wednesday]), week: 2)
//    return program
//}
//
//fileprivate func masterGZCL() -> Program {
//    func addExercises(_ program: Program) {
//        let max_warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//        let max_d_warmup = [FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//        
//        let t1_warmup = [
//            [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 45), FixedReps(reps: 3, percent: 65), FixedReps(reps: 1, percent: 75)],
//            [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 70), FixedReps(reps: 1, percent: 80)],
//            [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 47), FixedReps(reps: 3, percent: 67), FixedReps(reps: 1, percent: 77)],
//            [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 70), FixedReps(reps: 1, percent: 80)]
//        ]
//        let t1_d_warmup = [
//            [FixedReps(reps: 5, percent: 45), FixedReps(reps: 3, percent: 65), FixedReps(reps: 1, percent: 75)],
//            [FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 70), FixedReps(reps: 1, percent: 80)],
//            [FixedReps(reps: 5, percent: 47), FixedReps(reps: 3, percent: 67), FixedReps(reps: 1, percent: 77)],
//            [FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 70), FixedReps(reps: 1, percent: 80)]
//        ]
//        let t1_sets: [[VariableReps]] = [
//            [.fixed(4, 85), .fixed(4, 85), .fixed(4, 85)],                // 12 reps, want ~10 reps here
//            [.fixed(3, 90), .fixed(3, 90), .fixed(3, 90)],                // 9 reps
//            [.fixed(3, 87), .fixed(2, 92), .fixed(2, 92), .fixed(1, 97)], // 8 reps
//            [.fixed(3, 90), .fixed(2, 95), .amrap(1, 100)]]               // 6+ reps
//
//        let t2_warmup = [
//            [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 25), FixedReps(reps: 3, percent: 45), FixedReps(reps: 1, percent: 55)],
//            [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 30), FixedReps(reps: 3, percent: 50), FixedReps(reps: 1, percent: 60)],
//            [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 35), FixedReps(reps: 3, percent: 55), FixedReps(reps: 1, percent: 65)],
//            [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 40), FixedReps(reps: 3, percent: 60), FixedReps(reps: 1, percent: 70)]
//        ]
//        let t2_d_warmup = [
//            [FixedReps(reps: 5, percent: 25), FixedReps(reps: 3, percent: 45), FixedReps(reps: 1, percent: 55)],
//            [FixedReps(reps: 5, percent: 30), FixedReps(reps: 3, percent: 50), FixedReps(reps: 1, percent: 60)],
//            [FixedReps(reps: 5, percent: 35), FixedReps(reps: 3, percent: 55), FixedReps(reps: 1, percent: 65)],
//            [FixedReps(reps: 5, percent: 40), FixedReps(reps: 3, percent: 60), FixedReps(reps: 1, percent: 70)]
//        ]
//        let t2_sets: [[VariableReps]] =
//            [[.fixed(6, 65), .fixed(6, 65), .fixed(6, 65), .fixed(6, 65)],   // 24 reps, want 2x T1 reps here
//             [.fixed(6, 70), .fixed(6, 70), .fixed(6, 70)],                  // 18 reps
//             [.fixed(5, 75), .fixed(5, 75), .fixed(5, 75)],                  // 15 reps
//             [.fixed(4, 80), .fixed(4, 80), .fixed(4, 80)]]                  // 12 reps
//
//        let creps: [VariableReps] = [.variable(3, 8), .variable(3, 8)]
//        let t3: [VariableReps] = [.variable(8, 12), .variable(8, 12), .variable(8, 12)] // 24 reps, ideally want 3x T1 reps here
//
//        // one rep max
//        var exercise = make("Max Bench", "Bench Press", warmups: max_warmup, oneRepMax: true, weights: "Dual Plates", weight: 160)
//        program.exercises.append(exercise)
//        
//        exercise = make("Max Deadlift", "Trap Bar Deadlift", warmups: max_d_warmup, oneRepMax: true, weights: "Trapbar", weight: 220)
//        program.exercises.append(exercise)
//        
//        exercise = make("Max Squat", "High bar Squat", warmups: max_warmup, oneRepMax: true, weights: "Dual Plates", weight: 180)
//        program.exercises.append(exercise)
//
//        for week in 1...4 {
//            // T1
//            exercise = make("T1.\(week) Squat", "High bar Squat", "Max Squat", percent: 100, warmups: t1_warmup[week-1], worksets: t1_sets[week-1], weights: "Dual Plates", rest: 4*60)
//            program.exercises.append(exercise)
//            
//            exercise = make("T1.\(week) Bench", "Bench Press", "Max Bench", percent: 100, warmups: t1_warmup[week-1], worksets: t1_sets[week-1], weights: "Dual Plates", rest: 3*60)
//            program.exercises.append(exercise)
//
//            exercise = make("T1.\(week) Deadlift", "Trap Bar Deadlift", "Max Deadlift", percent: 100, warmups: t1_d_warmup[week-1], worksets: t1_sets[week-1], weights: "Trapbar", rest: 4*60)
//            program.exercises.append(exercise)
//
//            // T2
//            exercise = make("T2.\(week) Squat", "High bar Squat", "Max Squat", percent: 100, warmups: t2_warmup[week-1], worksets: t2_sets[week-1], weights: "Dual Plates", rest: 4*60)
//            program.exercises.append(exercise)
//            
//            exercise = make("T2.\(week) Bench", "Bench Press", "Max Bench", percent: 100, warmups: t2_warmup[week-1], worksets: t2_sets[week-1], weights: "Dual Plates", rest: 3*60)
//            program.exercises.append(exercise)
//
//            exercise = make("T2.\(week) Deadlift", "Trap Bar Deadlift", "Max Deadlift", percent: 100, warmups: t2_d_warmup[week-1], worksets: t2_sets[week-1], weights: "Trapbar", rest: 4*60)
//            program.exercises.append(exercise)
//        }
//
//        // T3
//        exercise = make("T3 Chin Ups", "Chin-up", warmups: [], worksets: creps, weights: "Single Plates", weight: 5, rest: 3*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Face Pulls", "Face Pull", warmups: [], worksets: t3, weights: "Cable Machine", weight: 32.5, rest: Int(2.5*60))
//        program.exercises.append(exercise)
//    }
//
//    func addMax(_ program: Program) {
//        let schedule = Schedule.anyDay
//        let workout = Workout("One Rep Max", schedule)
//        
//        workout.addExercise(name: "Max Squat")
//        workout.addExercise(name: "Max Bench")
//        workout.addExercise(name: "Max Deadlift")
//
//        program.addWorkout(workout)
//    }
//
//    func addBench(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.tuesday]))
//        let workout = Workout("Bench week \(week)", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "T1.\(week) Bench")
//        workout.addExercise(name: "T2.\(week) Squat")
//        workout.addExercise(name: "T3 Chin Ups")
//        
//        if week == 4 {
//            workout.notes = "On the AMRAP set if you were able to do two reps then up the weight for the \"Max\" version of the exercise by one. If you were able to do three reps then up it by two."
//        }
//
//        program.addWorkout(workout)
//    }
//
//    func addSquat(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.thursday]))
//        let workout = Workout("Squat week \(week)", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "T1.\(week) Squat")
//        workout.addExercise(name: "T2.\(week) Deadlift")
//        workout.addExercise(name: "T3 Chin Ups")
//        
//        if week == 4 {
//            workout.notes = "On the AMRAP set if you were able to do two reps then up the weight for the \"Max\" version of the exercise by one. If you were able to do three reps then up it by two."
//        }
//
//        program.addWorkout(workout)
//    }
//    
//    func addDeadlift(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.sunday]))
//        let workout = Workout("Deadlift week \(week)", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "T1.\(week) Deadlift")
//        workout.addExercise(name: "T2.\(week) Bench")
//        workout.addExercise(name: "T3 Face Pulls")
//        
//        if week == 4 {
//            workout.notes = "On the AMRAP set if you were able to do two reps then up the weight for the \"Max\" version of the exercise by one. If you were able to do three reps then up it by two."
//        }
//
//        program.addWorkout(workout)
//    }
//
//    let program = Program("Masters GZCL")
//    program.summary = "This is an intermediate program for older lifters inspired by the [GZCL program](https://swoleateveryheight.blogspot.com/2014/07/the-gzcl-method-simplified_13.html). The exercises use percentages based on your one rep max for the exercise (set these using Edit Exercise, e.g. for \"Max Bench\"). There are three workouts per week where the weight percentages increase but reps drop. On the fourth week your one rep max is tested and increased based on how many extra reps you were able to do. This program does require a gym."
//    addExercises(program)
//    
//    addMax(program)
//    for week in 1...4 {
//        addBench(program, week)
//        addSquat(program, week)
//        addDeadlift(program, week)
//    }
//
//    return program
//}
//
//fileprivate func GZCL() -> Program {
//    func addExercises(_ program: Program) { // TODO review warmups
//        let max_warmup = [FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//        
//        let t1_warmup = [
//            [FixedReps(reps: 5, percent: 45), FixedReps(reps: 3, percent: 65), FixedReps(reps: 1, percent: 75)],
//            [FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 70), FixedReps(reps: 1, percent: 80)],
//            [FixedReps(reps: 5, percent: 47), FixedReps(reps: 3, percent: 67), FixedReps(reps: 1, percent: 77)],
//            [FixedReps(reps: 5, percent: 50), FixedReps(reps: 3, percent: 70), FixedReps(reps: 1, percent: 80)]
//        ]
//        let t1_sets: [[VariableReps]] = [
//            [.fixed(5, 85), .fixed(5, 85), .fixed(5, 85)],                  // 15 reps
//            [.fixed(3, 90), .fixed(3, 90), .fixed(3, 90), .fixed(3, 90)],   // 12 reps
//            [.fixed(3, 87), .fixed(2, 92), .fixed(2, 92), .fixed(1, 97),    // 10 reps
//             .fixed(1, 97), .fixed(1, 97)],
//            [.fixed(3, 90), .fixed(2, 95), .amrap(1, 100)]]                 // 6+ reps
//
//        let t2_warmup = [
//            [FixedReps(reps: 5, percent: 25), FixedReps(reps: 3, percent: 45), FixedReps(reps: 1, percent: 55)],
//            [FixedReps(reps: 5, percent: 30), FixedReps(reps: 3, percent: 50), FixedReps(reps: 1, percent: 60)],
//            [FixedReps(reps: 5, percent: 35), FixedReps(reps: 3, percent: 55), FixedReps(reps: 1, percent: 65)],
//            [FixedReps(reps: 5, percent: 40), FixedReps(reps: 3, percent: 60), FixedReps(reps: 1, percent: 70)]
//        ]
//        let t2_sets: [[VariableReps]] =
//            [[.fixed(8, 65), .fixed(8, 65), .fixed(8, 65), .fixed(8, 65)],                // 32 reps
//             [.fixed(6, 70), .fixed(6, 70), .fixed(6, 70), .fixed(6, 70), .fixed(6, 70)], // 24 reps
//             [.fixed(5, 75), .fixed(5, 75), .fixed(5, 75), .fixed(5, 75), .fixed(5, 75)], // 25 reps
//             [.fixed(4, 80), .fixed(4, 80), .fixed(4, 80), .fixed(4, 80), .fixed(4, 80)]] // 20 reps
//
//        let t3: [VariableReps] = [.variable(8, 12), .variable(8, 12), .variable(8, 12)] // 24 reps
//
//        // one rep max
//        var exercise = make("Max Squat", "Low bar Squat", warmups: max_warmup, oneRepMax: true, weights: "Dual Plates", weight: 200)
//        program.exercises.append(exercise)
//
//        exercise = make("Max Bench", "Bench Press", warmups: max_warmup, oneRepMax: true, weights: "Dual Plates", weight: 180)
//        program.exercises.append(exercise)
//        
//        exercise = make("Max Deadlift", "Deadlift", warmups: max_warmup, oneRepMax: true, weights: "Deadlift", weight: 240)
//        program.exercises.append(exercise)
//        
//        exercise = make("Max OHP", "Overhead Press", warmups: max_warmup, oneRepMax: true, weights: "Dual Plates", weight: 85)
//        program.exercises.append(exercise)
//
//        for week in 1...4 {
//            // T1
//            exercise = make("T1.\(week) Squat", "Low bar Squat", "Max Squat", percent: 100, warmups: t1_warmup[week-1], worksets: t1_sets[week-1], weights: "Dual Plates", rest: 4*60)
//            program.exercises.append(exercise)
//            
//            exercise = make("T1.\(week) Bench", "Bench Press", "Max Bench", percent: 100, warmups: t1_warmup[week-1], worksets: t1_sets[week-1], weights: "Dual Plates", rest: 3*60)
//            program.exercises.append(exercise)
//
//            exercise = make("T1.\(week) Deadlift", "Deadlift", "Max Deadlift", percent: 100, warmups: t1_warmup[week-1], worksets: t1_sets[week-1], weights: "Deadlift", rest: 4*60)
//            program.exercises.append(exercise)
//
//            exercise = make("T1.\(week) OHP", "Overhead Press", "Max OHP", percent: 100, warmups: t1_warmup[week-1], worksets: t1_sets[week-1], weights: "Dual Plates", rest: 3*60)
//            program.exercises.append(exercise)
//
//            // T2, it's odd that these are percentages of the T1 exercises but that seems to be what GZCL calls for...
//            exercise = make("T2.\(week) Front Squat", "Front Squat", "Max Squat", percent: 100, warmups: t2_warmup[week-1], worksets: t2_sets[week-1], weights: "Dual Plates", rest: 4*60)
//            program.exercises.append(exercise)
//            
//            exercise = make("T2.\(week) Decline Bench", "Decline Bench Press", "Max Bench", percent: 100, warmups: t2_warmup[week-1], worksets: t2_sets[week-1], weights: "Dual Plates", rest: 3*60)
//            program.exercises.append(exercise)
//
//            exercise = make("T2.\(week) Good Morning", "Good Morning", "Max Deadlift", percent: 100, warmups: t2_warmup[week-1], worksets: t2_sets[week-1], weights: "Deadlift", rest: 4*60)
//            program.exercises.append(exercise)
//
//            exercise = make("T2.\(week) Incline Bench", "Incline Bench Press", "Max OHP", percent: 100, warmups: t2_warmup[week-1], worksets: t2_sets[week-1], weights: "Dual Plates", rest: 3*60)
//            program.exercises.append(exercise)
//        }
//
//        // T3
//        exercise = make("T3 Leg Curl", "Seated Leg Curl", warmups: [], worksets: t3, weights: "Cable Machine", weight: 30, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Leg Extension", "Leg Extensions", warmups: [], worksets: t3, weights: "Cable Machine", weight: 30, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Dips", "Dips", warmups: [], worksets: t3, weights: "Single Plates", weight: 10, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Triceps Pushdown", "Triceps Pushdown (rope)", warmups: [], worksets: t3, weights: "Cable Machine", weight: 20, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Shrugs", "Barbell Shrug", warmups: [], worksets: t3, weights: "Dual Plates", weight: 95, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Upright Row", "Upright Row", warmups: [], worksets: t3, weights: "Dual Plates", weight: 65, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Arnold Press", "Arnold Press", warmups: [], worksets: t3, weights: "Dumbbells", weight: 20, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Lateral Raise", "Side Lateral Raise", warmups: [], worksets: t3, weights: "Dumbbells", weight: 10, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Calf Raises", "Standing Calf Raises", warmups: [], worksets: t3, weights: "Dual Plates", weight: 95, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Preacher Curl", "Preacher Curl", warmups: [], worksets: t3, weights: "Dual Plates", weight: 40, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Pull-up", "Pull-up", warmups: [], worksets: t3, weights: "Single Plates", weight: 10, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("T3 Face Pull", "Face Pull", warmups: [], worksets: t3, weights: "Cable Machine", weight: 50, rest: 2*60)
//        program.exercises.append(exercise)
//    }
//
//    func addMax(_ program: Program) {
//        let schedule = Schedule.anyDay
//        let workout = Workout("One Rep Max", schedule)
//        
//        workout.addExercise(name: "Max Squat")
//        workout.addExercise(name: "Max Bench")
//        workout.addExercise(name: "Max Deadlift")
//        workout.addExercise(name: "Max OHP")
//
//        program.addWorkout(workout)
//    }
//
//    func addSquat(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.monday]))
//        let workout = Workout("Squat week \(week)", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "T1.\(week) Squat")
//        workout.addExercise(name: "T2.\(week) Front Squat")
//        workout.addExercise(name: "T3 Leg Curl")
//        workout.addExercise(name: "T3 Leg Extension")
//        workout.addExercise(name: "T3 T3 Calf Raises", enabled: false)
//        
//        if week == 4 {
//            workout.notes = "On the AMRAP set if you were able to do two reps then up the weight for the \"Max\" version of the exercise by one. If you were able to do three reps then up it by two."
//        }
//
//        program.addWorkout(workout)
//    }
//    
//    func addBench(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.tuesday]))
//        let workout = Workout("Bench week \(week)", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "T1.\(week) Bench")
//        workout.addExercise(name: "T2.\(week) Decline Bench")
//        workout.addExercise(name: "T3 Dips")
//        workout.addExercise(name: "T3 Triceps Pushdown")
//        workout.addExercise(name: "T3 Preacher Curl", enabled: false)
//        
//        if week == 4 {
//            workout.notes = "On the AMRAP set if you were able to do two reps then up the weight for the \"Max\" version of the exercise by one. If you were able to do three reps then up it by two."
//        }
//
//        program.addWorkout(workout)
//    }
//
//    func addDeadlift(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.thursday]))
//        let workout = Workout("Deadlift week \(week)", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "T1.\(week) Deadlift")
//        workout.addExercise(name: "T2.\(week) Good Morning")
//        workout.addExercise(name: "T3 Shrugs")
//        workout.addExercise(name: "T3 Upright Row")
//        workout.addExercise(name: "T3 Pull-up", enabled: false)
//        
//        if week == 4 {
//            workout.notes = "On the AMRAP set if you were able to do two reps then up the weight for the \"Max\" version of the exercise by one. If you were able to do three reps then up it by two."
//        }
//
//        program.addWorkout(workout)
//    }
//
//    func addOHP(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("OHP week \(week)", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "T1.\(week) OHP")
//        workout.addExercise(name: "T2.\(week) Incline Bench")
//        workout.addExercise(name: "T3 Shrugs")
//        workout.addExercise(name: "T3 Arnold Press")
//        workout.addExercise(name: "T3 Lateral Raise")
//        workout.addExercise(name: "T3 Face Pull", enabled: false)
//        
//        if week == 4 {
//            workout.notes = "On the AMRAP set if you were able to do two reps then up the weight for the \"Max\" version of the exercise by one. If you were able to do three reps then up it by two."
//        }
//
//        program.addWorkout(workout)
//    }
//
//    let program = Program("GZCL")
//    program.summary = "This is an intermediate [program](https://swoleateveryheight.blogspot.com/2014/07/the-gzcl-method-simplified_13.html). The exercises use percentages based on your one rep max for the exercise (set these using Edit Exercise, e.g. for \"Max Bench\"). There are four workouts per week where the weight percentages increase but reps drop. On the fourth week your one rep max is tested and increased based on how many extra reps you were able to do. This program does require a gym."
//    addExercises(program)
//    
//    addMax(program)
//    for week in 1...4 {
//        addBench(program, week)
//        addSquat(program, week)
//        addDeadlift(program, week)
//        addOHP(program, week)
//    }
//
//    return program
//}

//func add531Exercises(_ program: Program) {
//    let max_warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//    let max_warmup_dead = [FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//
//    let warmup5 = [FixedReps(reps: 5, percent: 25), FixedReps(reps: 3, percent: 45), FixedReps(reps: 1, percent: 55)]
//    let warmup3 = [FixedReps(reps: 5, percent: 30), FixedReps(reps: 3, percent: 50), FixedReps(reps: 1, percent: 60)]
//    let warmup1 = [FixedReps(reps: 5, percent: 35), FixedReps(reps: 3, percent: 55), FixedReps(reps: 1, percent: 65)]
//    
//    let reps5: [VariableReps] = [.fixed(5, 65), .fixed(5, 75), .amrap(5, 85)]
//    let reps3: [VariableReps] = [.fixed(3, 70), .fixed(3, 80), .amrap(3, 90)]
//    let reps1: [VariableReps] = [.fixed(5, 75), .fixed(3, 85), .amrap(1, 90)]
//    let repsd: [VariableReps] = [.fixed(5, 40), .fixed(5, 50), .fixed(5, 60)]
//    let reps10: [VariableReps] = [.fixed(10, 30), .fixed(10, 40), .fixed(10, 50), .fixed(10, 60), .fixed(10, 70)]
//
//    // 1 rep max
//    var exercise = make("Max OHP", "Overhead Press", warmups: max_warmup, oneRepMax: true, weights: "Dual Plates", weight: 80)
//    program.exercises.append(exercise)
//
//    exercise = make("Max Bench", "Bench Press", warmups: max_warmup, oneRepMax: true, weights: "Dual Plates", weight: 160)
//    program.exercises.append(exercise)
//    
//    exercise = make("Max Deadlift", "Deadlift", warmups: max_warmup_dead, oneRepMax: true, weights: "Dual Plates", weight: 200)
//    program.exercises.append(exercise)
//    
//    exercise = make("Max Squat", "Low bar Squat", warmups: max_warmup, oneRepMax: true, weights: "Dual Plates", weight: 225)
//    program.exercises.append(exercise)
//
//    // 5 reps part of 531
//    exercise = make("OHP 5", "Overhead Press", "Max OHP", percent: 100, warmups: warmup5, worksets: reps5, weights: "Dual Plates", rest: 2*60)
//    program.exercises.append(exercise)
//    
//    exercise = make("Deadlift 5", "Deadlift", "Max Deadlift", percent: 100, warmups: warmup5, worksets: reps5, weights: "Dual Plates", rest: 3*60)
//    program.exercises.append(exercise)
//
//    exercise = make("Squat 5", "Low bar Squat", "Max Squat", percent: 100, warmups: warmup5, worksets: reps5, weights: "Dual Plates", rest: 3*60)
//    program.exercises.append(exercise)
//
//    exercise = make("Bench 5", "Bench Press", "Max Bench", percent: 100, warmups: warmup5, worksets: reps5, weights: "Dual Plates", rest: 2*60)
//    program.exercises.append(exercise)
//
//    // 3 reps part of 531
//    exercise = make("OHP 3", "Overhead Press", "Max OHP", percent: 100, warmups: warmup3, worksets: reps3, weights: "Dual Plates", rest: 2*60)
//    program.exercises.append(exercise)
//    
//    exercise = make("Deadlift 3", "Deadlift", "Max Deadlift", percent: 100, warmups: warmup3, worksets: reps3, weights: "Dual Plates", rest: 3*60)
//    program.exercises.append(exercise)
//
//    exercise = make("Squat 3", "Low bar Squat", "Max Squat", percent: 100, warmups: warmup3, worksets: reps3, weights: "Dual Plates", rest: 3*60)
//    program.exercises.append(exercise)
//
//    exercise = make("Bench 3", "Bench Press", "Max Bench", percent: 100, warmups: warmup3, worksets: reps3, weights: "Dual Plates", rest: 2*60)
//    program.exercises.append(exercise)
//
//    // 1 rep part of 531
//    exercise = make("OHP 1", "Overhead Press", "Max OHP", percent: 100, warmups: warmup1, worksets: reps1, weights: "Dual Plates", rest: 2*60)
//    program.exercises.append(exercise)
//    
//    exercise = make("Deadlift 1", "Deadlift", "Max Deadlift", percent: 100, warmups: warmup1, worksets: reps1, weights: "Dual Plates", rest: 1*60)
//    program.exercises.append(exercise)
//
//    exercise = make("Squat 1", "Low bar Squat", "Max Squat", percent: 100, warmups: warmup1, worksets: reps1, weights: "Dual Plates", rest: 1*60)
//    program.exercises.append(exercise)
//
//    exercise = make("Bench 1", "Bench Press", "Max Bench", percent: 100, warmups: warmup1, worksets: reps1, weights: "Dual Plates", rest: 2*60)
//    program.exercises.append(exercise)
//    
//    // deload
//    exercise = make("OHP deload", "Overhead Press", "Max OHP", percent: 100, warmups: [], worksets: repsd, weights: "Dual Plates", rest: 2*60)
//    program.exercises.append(exercise)
//    
//    exercise = make("Deadlift deload", "Deadlift", "Max Deadlift", percent: 100, warmups: [], worksets: repsd, weights: "Dual Plates", rest: 1*60)
//    program.exercises.append(exercise)
//
//    exercise = make("Squat deload", "Low bar Squat", "Max Squat", percent: 100, warmups: [], worksets: repsd, weights: "Dual Plates", rest: 1*60)
//    program.exercises.append(exercise)
//
//    exercise = make("Bench deload", "Bench Press", "Max Bench", percent: 100, warmups: [], worksets: repsd, weights: "Dual Plates", rest: 2*60)
//    program.exercises.append(exercise)
//
//    // 5 sets of 10 reps
//    exercise = make("Bench Press", "Bench Press", "Max Bench", percent: 100, warmups: [], worksets: reps10, weights: "Dual Plates", rest: 2*60)
//    program.exercises.append(exercise)
//    
//    exercise = make("Deadlift", "Deadlift", "Max Deadlift", percent: 100, warmups: [], worksets: reps10, weights: "Dual Plates", rest: 3*60)
//    program.exercises.append(exercise)
//
//    exercise = make("Squat", "Low bar Squat", "Max Squat", percent: 100, warmups: [], worksets: reps10, weights: "Dual Plates", rest: 3*60)
//    program.exercises.append(exercise)
//
//    exercise = make("OHP", "Overhead Press", "Max OHP", percent: 100, warmups: [], worksets: reps10, weights: "Dual Plates", rest: 2*60)
//    program.exercises.append(exercise)
//
//    // accessories
//    let creps: [VariableReps] = [.fixed(10), .fixed(10), .fixed(10), .fixed(10), .fixed(10)]
//    exercise = make("Chin Ups", "Chin-up", warmups: [], worksets: creps, weights: "Dumbbells", weight: 0, rest: 2*60)
//    program.exercises.append(exercise)
//
//    let areps: [VariableReps] = [.fixed(1), .fixed(1), .fixed(1), .fixed(1), .fixed(1)]
//    exercise = make("Ab Wheel", "Ab Wheel Rollout", warmups: [], worksets: areps, rest: 2*60)
//    program.exercises.append(exercise)
//}
//
//func add531Max(_ program: Program) {
//    let schedule = Schedule.anyDay
//    let workout = Workout("One Rep Max", schedule)
//    
//    workout.addExercise(name: "Max Bench")
//    workout.addExercise(name: "Max OHP")
//    workout.addExercise(name: "Max Squat")
//    workout.addExercise(name: "Max Deadlift")
//
//    program.addWorkout(workout)
//}
//
//fileprivate func boringButBigProgram3() -> Program {
//    func wname(_ week: Int) -> String {
//        if week == 5 {
//            return "deload"
//        } else {
//            return "\(week)"
//        }
//    }
//
//    func addPress(_ program: Program, _ day: Weekdays.Day, _ week: Int, _ version: String) {
//        let schedule = Schedule.days(Weekdays([day]))
//        let workout = Workout("Press \(wname(week))", schedule)
//        workout.weeks = week...week
//        
//        workout.addExercise(name: "OHP \(version)")
//        workout.addExercise(name: "Bench Press")
//        workout.addExercise(name: "Chin Ups")
//        
//        program.addWorkout(workout)
//    }
//
//    func addDeadlift(_ program: Program, _ day: Weekdays.Day, _ week: Int, _ version: String) {
//        let schedule = Schedule.days(Weekdays([day]))
//        let workout = Workout("Deadlift \(wname(week))", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "Deadlift \(version)")
//        workout.addExercise(name: "Squat")
//        workout.addExercise(name: "Ab Wheel")
//
//        program.addWorkout(workout)
//    }
//
//    func addBench(_ program: Program, _ day: Weekdays.Day, _ week: Int, _ version: String) {
//        let schedule = Schedule.days(Weekdays([day]))
//        let workout = Workout("Bench \(wname(week))", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "Bench \(version)")
//        workout.addExercise(name: "OHP")
//        workout.addExercise(name: "Chin Ups")
//
//        program.addWorkout(workout)
//    }
//
//    func addSquat(_ program: Program, _ day: Weekdays.Day, _ week: Int, _ version: String) {
//        let schedule = Schedule.days(Weekdays([day]))
//        let workout = Workout("Squat \(wname(week))", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "Squat \(version)")
//        workout.addExercise(name: "Deadlift")
//        workout.addExercise(name: "Ab Wheel")
//        
//        if version == "deload" {
//            workout.notes = "If you were able to hit the rep goals for an exercise then use Edit Exercise to up the weight for the \"Max\" version of the exercise. Otherwise drop the weight by 10% for that exercise."
//        }
//
//        program.addWorkout(workout)
//    }
//
//    let program = Program("531 Boring but Big 3")
//    program.summary = "[This](https://www.jimwendler.com/blogs/jimwendler-com/101077382-boring-but-big) is a high volume program for intermediate to advanced lifters. This version is three days a week and uses a five week cycle with one deload week. The exercises use percentages based on your one rep max for the exercise (set these using Edit Exercise, e.g. for \"Max Bench\"). When starting out use a low weight, espcially for the lower body exercises."
//    add531Exercises(program)
//    add531Max(program)
//
//    addPress(program, .monday, 1, "5")
//    addDeadlift(program, .wednesday, 1, "5")
//    addBench(program, .friday, 1, "5")
//
//    addSquat(program, .monday, 2, "5")
//    addPress(program, .wednesday, 2, "3")
//    addDeadlift(program, .friday, 2, "3")
//
//    addBench(program, .monday, 3, "3")
//    addSquat(program, .wednesday, 3, "3")
//    addPress(program, .friday, 3, "1")
//
//    addDeadlift(program, .monday, 4, "1")
//    addBench(program, .wednesday, 4, "1")
//    addSquat(program, .friday, 4, "1")
//
//    addPress(program, .monday, 5, "deload")
//    addBench(program, .wednesday, 5, "deload")
//    addSquat(program, .friday, 5, "deload")
//
//    return program
//}
//
//fileprivate func boringButBigProgram4() -> Program {
//    func wname(_ week: Int) -> String {
//        if week == 4 {
//            return "deload"
//        } else {
//            return "\(week)"
//        }
//    }
//
//    func suffix(_ week: Int) -> String {
//        if week == 1 {
//            return "5"
//        } else if week == 2 {
//            return "3"
//        } else if week == 3 {
//            return "1"
//        } else {
//            return "deload"
//        }
//    }
//
//    func addPress(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.monday]))
//        let workout = Workout("Press \(wname(week))", schedule)
//        workout.weeks = week...week
//        
//        workout.addExercise(name: "OHP \(suffix(week))")
//        workout.addExercise(name: "Bench Press")
//        workout.addExercise(name: "Chin Ups")
//        
//        program.addWorkout(workout)
//    }
//
//    func addDeadlift(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.tuesday]))
//        let workout = Workout("Deadlift \(wname(week))", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "Deadlift \(suffix(week))")
//        workout.addExercise(name: "Squat")
//        workout.addExercise(name: "Ab Wheel")
//        
//        program.addWorkout(workout)
//    }
//
//    func addBench(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.thursday]))
//        let workout = Workout("Bench \(wname(week))", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "Bench \(suffix(week))")
//        workout.addExercise(name: "OHP")
//        workout.addExercise(name: "Chin Ups")
//
//        program.addWorkout(workout)
//    }
//
//    func addSquat(_ program: Program, _ week: Int) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("Squat \(wname(week))", schedule)
//        workout.weeks = week...week
//
//        workout.addExercise(name: "Squat \(suffix(week))")
//        workout.addExercise(name: "Deadlift")
//        workout.addExercise(name: "Ab Wheel")
//        
//        if week == 4 {
//            workout.notes = "If you were able to hit the rep goals for an exercise then use Edit Exercise to up the weight for the \"Max\" version of the exercise. Otherwise drop the weight by 10% for that exercise."
//        }
//
//        program.addWorkout(workout)
//    }
//
//    let program = Program("531 Boring but Big 4")
//    program.summary = "[This](https://www.jimwendler.com/blogs/jimwendler-com/101077382-boring-but-big) is a high volume program for intermediate to advanced lifters. This version is four days a week and uses a four week cycle with one deload week. The exercises use percentages based on your one rep max for the exercise (set these using Edit Exercise, e.g. for \"Max Bench\"). When starting out use a low weight, espcially for the lower body exercises. You can substitute in alternate versions of exercises but you shouldn't add new exercises to this program."
//    add531Exercises(program)
//    add531Max(program)
//    for week in 1...4 {
//        addPress(program, week)
//        addDeadlift(program, week)
//        addBench(program, week)
//        addSquat(program, week)
//    }
//    return program
//}
//
//fileprivate func complexBeginner() -> Program {
//    let program = Program("Complex - beginner")
//    program.summary = "[Complexes](https://lipsticklifters.com/articles/dumbbell-complex/) are a blend between cardio and weight lifting. The idea is that you peform a set of exercises with a fixed weight without resting or setting the weight down, do a short rest, and repeat. Unless you are in great shape this will quickly get intense so start with a weight much lighter than what you can do for one of the exercises."
//
//    let reps: [VariableReps] = [.fixed(1), .fixed(1), .fixed(1)]
//    let exercise = make("Complex", "Complex - beginner", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
//    program.exercises.append(exercise)
//
//    let schedule = Schedule.days(Weekdays([.monday, .wednesday, .friday]))
//    let workout = Workout("Complex", schedule)
//    workout.addExercise(name: "Complex")
//    program.addWorkout(workout)
//
//    return program
//}
//
//fileprivate func complexIntermediate() -> Program {
//    let program = Program("Complex - intermediate")
//    program.summary = "[Complexes](https://lipsticklifters.com/articles/dumbbell-complex/) are a blend between cardio and weight lifting. The idea is that you peform a set of exercises with a fixed weight without resting or setting the weight down, do a short rest, and repeat. Unless you are in great shape this will quickly get intense so start with a weight much lighter than what you can do for one of the exercises."
//
//    let reps: [VariableReps] = [.fixed(1), .fixed(1), .fixed(1), .fixed(1)]
//    let exercise = make("Complex", "Complex - intermediate", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 10, rest: 90)
//    program.exercises.append(exercise)
//
//    let schedule = Schedule.days(Weekdays([.monday, .wednesday, .friday]))
//    let workout = Workout("Complex", schedule)
//    workout.addExercise(name: "Complex")
//    program.addWorkout(workout)
//
//    return program
//}
//
//fileprivate func dumbbellPPL47() -> (Program, Program) {
//    func addExercises(_ program: Program) {
//        let reps: [VariableReps] = [.variable(4, 12), .variable(4, 12), .variable(4, 12)]
//
//        var exercise = make("Chest Press", "Dumbbell Bench Press", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Incline Fly", "Dumbbell Incline Flyes", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Arnold Press", "Arnold Press", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Overhead Tricep Extension", "Standing Triceps Press", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
//        program.exercises.append(exercise)
//
//        
//        exercise = make("Split Squat", "Dumbbell Single Leg Split Squat", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Bent-over Row", "Bent Over Dumbbell Row", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Reverse Fly", "Reverse Flyes", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Shrug", "Dumbbell Shrug", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Bicep Curl", "Concentration Curls", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 90)
//        program.exercises.append(exercise)
//
//        
//        exercise = make("Pull-ups", "Pull-up", warmups: [], worksets: reps, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Goblet Squat", "Goblet Squat", warmups: [], worksets: reps, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Lunge", "Dumbbell Lunge", warmups: [], worksets: reps, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Single Leg Deadlift", "Single Leg Dumbbell Deadlift", warmups: [], worksets: reps, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Calf Raise", "One-Leg DB Calf Raises", warmups: [], worksets: reps, rest: 90)
//        program.exercises.append(exercise)
//
//
//        exercise = make("Hanging Leg Raises", "Hanging Leg Raise", warmups: [], worksets: reps, rest: 90)
//        program.exercises.append(exercise)
//    }
//
//    func push1(_ program: Program) {
//        let workout = Workout("Push1", .cyclic)
//        workout.addExercise(name: "Chest Press")
//        workout.addExercise(name: "Incline Fly")
//        workout.addExercise(name: "Arnold Press")
//        workout.addExercise(name: "Overhead Tricep Extension")
//        program.addWorkout(workout)
//    }
//
//    func pull1(_ program: Program) {
//        let workout = Workout("Pull1", .cyclic)
//        workout.addExercise(name: "Pull-ups")
//        workout.addExercise(name: "Bent-over Row")
//        workout.addExercise(name: "Reverse Fly")
//        workout.addExercise(name: "Shrug")
//        workout.addExercise(name: "Bicep Curl")
//        workout.addExercise(name: "Hanging Leg Raises")
//        program.addWorkout(workout)
//    }
//
//    func legs1(_ program: Program) {
//        let workout = Workout("Legs1", .cyclic)
//        workout.addExercise(name: "Goblet Squat")
//        workout.addExercise(name: "Split Squat", enabled: false)
//        workout.addExercise(name: "Lunge")
//        workout.addExercise(name: "Single Leg Deadlift")
//        workout.addExercise(name: "Calf Raise")
//        program.addWorkout(workout)
//    }
//
//    func rest1(_ program: Program) {
//        let workout = Workout("Rest1", .cyclic)
//        program.addWorkout(workout)
//    }
//
//    func push2(_ program: Program) {
//        let workout = Workout("Push2", .cyclic)
//        workout.addExercise(name: "Chest Press")
//        workout.addExercise(name: "Incline Fly")
//        workout.addExercise(name: "Arnold Press")
//        workout.addExercise(name: "Overhead Tricep Extension")
//        workout.addExercise(name: "Hanging Leg Raises")
//        program.addWorkout(workout)
//    }
//
//    func pull2(_ program: Program) {
//        let workout = Workout("Pull2", .cyclic)
//        workout.addExercise(name: "Pull-ups")
//        workout.addExercise(name: "Bent-over Row")
//        workout.addExercise(name: "Reverse Fly")
//        workout.addExercise(name: "Shrug")
//        workout.addExercise(name: "Bicep Curl")
//        program.addWorkout(workout)
//    }
//
//    func legs2(_ program: Program) {
//        let workout = Workout("Legs2", .cyclic)
//        workout.addExercise(name: "Goblet Squat")
//        workout.addExercise(name: "Split Squat", enabled: false)
//        workout.addExercise(name: "Lunge")
//        workout.addExercise(name: "Single Leg Deadlift")
//        workout.addExercise(name: "Calf Raise")
//        workout.addExercise(name: "Hanging Leg Raises")
//        program.addWorkout(workout)
//    }
//
//    func rest(_ program: Program, suffix: String) {
//        let workout = Workout("Rest\(suffix)", .cyclic)
//        program.addWorkout(workout)
//    }
//
//    let program4 = Program("Dumbbell PPL4")
//    program4.summary = "A Push/Pull/Legs beginner [program](https://thefitness.wiki/reddit-archive/dumbbell-stopgap-ppl/) that requires minimal equipment. Note that there are some optional exercises that you can enable using Edit Program on the top right of the main screen. This version uses a 4 day cycle with one rest day."
//    addExercises(program4)
//    push1(program4)
//    pull1(program4)
//    legs1(program4)
//    rest(program4, suffix: "1")
//    push2(program4)
//    pull2(program4)
//    legs2(program4)
//    rest(program4, suffix: "2")
//    for w in program4.workouts {
//        w.notes = "Increase weight once you can do twelve reps for all three sets. If you can't increase weight or reps for an exercise after three tries then deload the weight for that exercise by two increments."
//    }
//
//    let program7 = Program("Dumbbell PPL7")
//    program7.summary = "A Push/Pull/Legs beginner [program](https://thefitness.wiki/reddit-archive/dumbbell-stopgap-ppl/) that requires minimal equipment. Note that there are some optional exercises that you can enable using Edit Program on the top right of the main screen. This version uses a 7 day cycle with one rest day."
//    addExercises(program7)
//    push1(program7)
//    pull1(program7)
//    legs1(program7)
//    push2(program7)
//    pull2(program7)
//    legs2(program7)
//    rest(program4, suffix: "")
//    for w in program7.workouts {
//        w.notes = "Increase weight once you can do twelve reps for all three sets. If you can't increase weight or reps for an exercise after three tries then deload the weight for that exercise by two increments."
//    }
//    return (program4, program7)
//}
//
//fileprivate func dumbbellPPL4() -> Program {
//    let (program, _) = dumbbellPPL47()
//    return program
//}
//
//fileprivate func dumbbellPPL7() -> Program {
//    let (_, program) = dumbbellPPL47()
//    return program
//}
//
//fileprivate func machine() -> Program {
//    func addExercises(_ program: Program) {
//        let warmup = [FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//
//        // Push
//        var exercise = make("Machine Bench Press", "Machine Bench Press", warmups: warmup, workstr: "6-10 6-10 6-10 6-10", weights: "Dual Plates", weight: 90, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Machine Incline Press", "Machine Incline Press", warmups: warmup, workstr: "10-15 10-15 10-15", weights: "Dual Plates", weight: 60, rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Pec Deck Fly", "Pec Deck Fly", workstr: "10-15 10-15 10-15", weights: "Cable Machine", weight: 40.0, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Machine Shoulder Press", "Machine Shoulder Press", workstr: "6-10 6-10 6-10 6-10", weights: "Dual Plates", weight: 50, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Machine Lateral Raise", "Machine Lateral Raise", workstr: "10-15 10-15 10-15", weights: "Cable Machine", weight: 30.0, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Tricep Pushdown", "Triceps Pushdown (rope)", workstr: "10-15 10-15 10-15", weights: "Cable Machine", weight: 20.0, rest: 45)
//        program.exercises.append(exercise)
//
//        // Pull
//        exercise = make("Lat Pulldown", "Lat Pulldown", warmups: warmup, workstr: "6-10 6-10 6-10 6-10", weights: "Cable Machine", weight: 30, rest: 45)
//        program.exercises.append(exercise)
//
//        exercise = make("Seated Cable Row", "Seated Cable Row", workstr: "6-10 6-10 6-10 6-10", weights: "Cable Machine", weight: 40.0, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Machine Pullover", "Machine Pullover", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 30.0, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Machine Preacher Curl", "Machine Preacher Curl", workstr: "8-12 8-12 8-12", weights: "Dual Plates", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Cable Hammer Curls", "Cable Hammer Curls", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 20.0, rest: 90)
//        program.exercises.append(exercise)
//
//        // Legs
//        exercise = make("Hack Squat", "Hack Squat", warmups: warmup, workstr: "6-10 6-10 6-10 6-10", weights: "Dual Plates", weight: 100, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("SM Squat", "Smith Machine Squat", warmups: warmup, workstr: "6-10 6-10 6-10 6-10", weights: "Smith Machine", weight: 100, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Leg Press", "Leg Press", warmups: warmup, workstr: "6-10 6-10 6-10 6-10", weights: "Dual Plates", weight: 120, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Leg Curl", "Seated Leg Curl", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 40.0, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Leg Extension", "Leg Extensions", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 40.0, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Glute Kickbacks", "One-Legged Cable Kickback", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 20.0, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Calf Raises", "Standing Calf Raises", workstr: "15 15 15", weights: "Smith Machine", weight: 140, rest: 90)
//        program.exercises.append(exercise)
//    }
//
//    func addPush(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday]))
//        let workout = Workout("Push", schedule)
//
//        workout.addExercise(name: "Machine Bench Press")
//        workout.addExercise(name: "Machine Incline Press")
//        workout.addExercise(name: "Pec Deck Fly")
//        workout.addExercise(name: "Machine Shoulder Press")
//        workout.addExercise(name: "Machine Lateral Raise")
//        workout.addExercise(name: "Tricep Pushdown")
//
//        program.addWorkout(workout)
//    }
//
//    func addPull(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.wednesday]))
//        let workout = Workout("Pull", schedule)
//        
//        workout.addExercise(name: "Lat Pulldown")
//        workout.addExercise(name: "Seated Cable Row")
//        workout.addExercise(name: "Machine Pullover")
//        workout.addExercise(name: "Machine Preacher Curl")
//        workout.addExercise(name: "Cable Hammer Curls")
//
//        program.addWorkout(workout)
//    }
//
//    func addLegs(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("Legs", schedule)
//
//        workout.addExercise(name: "Hack Squat")
//        workout.addExercise(name: "SM Squat", enabled: false)
//        workout.addExercise(name: "Leg Press")
//        workout.addExercise(name: "Leg Curl")
//        workout.addExercise(name: "Leg Extension")
//        workout.addExercise(name: "Glute Kickbacks")
//        workout.addExercise(name: "Calf Raises")
//
//        program.addWorkout(workout)
//    }
//
//    let program = Program("Machine")
//    program.summary = "A [program](https://www.muscleandstrength.com/workouts/machines-only-3-day-split) centered on using machines instead of free weights. This is a 3-day a week push/pull/leg split workout."
//    addExercises(program)
//    addPush(program)
//    addPull(program)
//    addLegs(program)
//    return program
//}
//
//fileprivate func pf6() -> Program {
//    func addExercises(_ program: Program) {
//        let warmup = [FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//
//        // Pull
//        var exercise = make("SM Deadlift", "Smith Machine Deadlift", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 90, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Pullups", "Pull-up", workstr: "8-12 8-12 8-12", rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Seated Cable Row", "Seated Cable Row", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 40.0, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Hammer Curls", "Hammer Curls", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 20, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Face Pulls", "Face Pull", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 32.5, rest: Int(1.5*60))
//        program.exercises.append(exercise)
//
//        exercise = make("SM Row", "Smith Machine Bent-Over Row", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 80, rest: 2*60)
//        program.exercises.append(exercise)
//        
//        // Push
//        exercise = make("SM Bench Press", "Smith Machine Bench", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 90, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("DB OHP", "Dumbbell Shoulder Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 30, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Incline DB Press", "Incline Bench Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 30, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Tricep Pushdown", "Triceps Pushdown (rope)", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 20.0, rest: Int(1.5*60))
//        program.exercises.append(exercise)
//
//        exercise = make("Lateral Raise", "Side Lateral Raise", workstr: "15 15 15", weights: "Dumbbells", weight: 5, rest: Int(1.5*60))
//        program.exercises.append(exercise)
//        
//        // Legs
//        exercise = make("SM Squat", "Smith Machine Squat", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 90, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("SM Romanian Deadlift", "Smith Machine Romanian Deadlift", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 90, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Leg Press", "Leg Press", warmups: warmup, workstr: "8-12 8-12 8-12", weights: "Dual Plates", weight: 225, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("SM Calf Raises", "Standing Calf Raises", warmups: warmup, workstr: "30 30 30", weights: "Smith Machine", weight: 180, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Seated Leg Curls", "Seated Leg Curl", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 40.0, rest: Int(1.5*60))
//        program.exercises.append(exercise)
//
//        exercise = make("SM Front Squat", "Smith Machine Front Squat", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 90, rest: 2*60)
//        program.exercises.append(exercise)
//    }
//
//    func addPull1(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday]))
//        let workout = Workout("Pull 1", schedule)
//        workout.weeks = 1...1
//        
//        workout.addExercise(name: "SM Deadlift")
//        workout.addExercise(name: "Pullups")
//        workout.addExercise(name: "Seated Cable Row")
//        workout.addExercise(name: "Hammer Curls")
//        workout.addExercise(name: "Face Pulls")
//        workout.notes = "To save time you can superset Hammer Curls/Face Pulls."
//
//        program.addWorkout(workout)
//    }
//
//    func addPull2(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.thursday]))
//        let workout = Workout("Pull 2", schedule)
//        workout.weeks = 2...2
//        
//        workout.addExercise(name: "SM Row")
//        workout.addExercise(name: "Pullups")
//        workout.addExercise(name: "Seated Cable Row")
//        workout.addExercise(name: "Hammer Curls")
//        workout.addExercise(name: "Face Pulls")
//        workout.notes = "To save time you can superset Hammer Curls/Face Pulls."
//
//        program.addWorkout(workout)
//    }
//
//    func addPush1(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.tuesday]))
//        let workout = Workout("Push 1", schedule)
//        workout.weeks = 1...1
//
//        workout.addExercise(name: "SM Bench Press")
//        workout.addExercise(name: "DB OHP")
//        workout.addExercise(name: "Incline DB Press")
//        workout.addExercise(name: "Tricep Pushdown")
//        workout.addExercise(name: "Lateral Raise")
//        workout.notes = "To save time you can superset Tricep Pushdown/Lateral Raise."
//
//        program.addWorkout(workout)
//    }
//
//    func addPush2(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("Push 2", schedule)
//        workout.weeks = 2...2
//
//        workout.addExercise(name: "SM Bench Press")
//        workout.addExercise(name: "DB OHP")
//        workout.addExercise(name: "Incline DB Press")
//        workout.addExercise(name: "Tricep Pushdown")
//        workout.addExercise(name: "Lateral Raise")
//        workout.notes = "To save time you can superset Tricep Pushdown/Lateral Raise."
//
//        program.addWorkout(workout)
//    }
//
//    func addLegs1(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.wednesday]))
//        let workout = Workout("Legs 1", schedule)
//        workout.weeks = 1...1
//
//        workout.addExercise(name: "SM Squat")
//        workout.addExercise(name: "SM Romanian Deadlift")
//        workout.addExercise(name: "Leg Press")
//        workout.addExercise(name: "SM Calf Raises")
//        workout.addExercise(name: "Seated Leg Curls")
//        workout.notes = "To save time you can superset Calf Raises/Leg Curls."
//
//        program.addWorkout(workout)
//    }
//
//    func addLegs2(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.saturday]))
//        let workout = Workout("Legs 2", schedule)
//        workout.weeks = 2...2
//
//        workout.addExercise(name: "SM Front Squat")
//        workout.addExercise(name: "SM Romanian Deadlift")
//        workout.addExercise(name: "Leg Press")
//        workout.addExercise(name: "SM Calf Raises")
//        workout.addExercise(name: "Seated Leg Curls")
//        workout.notes = "To save time you can superset Calf Raises/Leg Curls."
//
//        program.addWorkout(workout)
//    }
//
//    let program = Program("Planet Fitness 6")
//    program.summary = "Intermediate [program](https://www.reddit.com/r/Fitness/comments/9ldxy3/planet_fitness_hotel_apartment_gym_workout) for gyms without free barbells. This is a push/pull/legs split and designed to be performed six days a week."
//    addExercises(program)
//    addPull1(program)
//    addPush1(program)
//    addLegs1(program)
//    addPull2(program)
//    addPush2(program)
//    addLegs2(program)
//    return program
//}
//
//fileprivate func pf3() -> Program {
//    func addExercises(_ program: Program) {
//        let warmup = [FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//
//        // Pull
//        var exercise = make("SM Deadlift", "Smith Machine Deadlift", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 90, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Pullups", "Pull-up", workstr: "8-12 8-12 8-12", rest: 2*60)
//        program.exercises.append(exercise)
//        
//        exercise = make("Lat Pulldown", "Lat Pulldown", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 30, rest: Int(1.5*60))
//        program.exercises.append(exercise)
//
//        exercise = make("Seated Cable Row", "Seated Cable Row", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 40.0, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Hammer Curls", "Hammer Curls", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 20, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Face Pulls", "Face Pull", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 32.5, rest: Int(1.5*60))
//        program.exercises.append(exercise)
//
//        exercise = make("SM Row", "Smith Machine Bent-Over Row", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 80, rest: 2*60)
//        program.exercises.append(exercise)
//        
//        // Push
//        exercise = make("SM Bench Press", "Smith Machine Bench", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 90, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("DB OHP", "Dumbbell Shoulder Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 30, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Incline DB Press", "Incline Bench Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 30, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Tricep Pushdown", "Triceps Pushdown (rope)", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 20.0, rest: Int(1.5*60))
//        program.exercises.append(exercise)
//
//        exercise = make("Lateral Raise", "Side Lateral Raise", workstr: "15 15 15", weights: "Dumbbells", weight: 5, rest: Int(1.5*60))
//        program.exercises.append(exercise)
//        
//        // Legs
//        exercise = make("SM Squat", "Smith Machine Squat", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 90, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("SM Romanian Deadlift", "Smith Machine Romanian Deadlift", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 90, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Leg Press", "Leg Press", warmups: warmup, workstr: "8-12 8-12 8-12", weights: "Dual Plates", weight: 225, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("SM Calf Raises", "Standing Calf Raises", warmups: warmup, workstr: "30 30 30", weights: "Smith Machine", weight: 180, rest: 2*60)
//        program.exercises.append(exercise)
//
//        exercise = make("Seated Leg Curls", "Seated Leg Curl", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 40.0, rest: Int(1.5*60))
//        program.exercises.append(exercise)
//
//        exercise = make("SM Front Squat", "Smith Machine Front Squat", warmups: warmup, workstr: "5 5 5+", weights: "Smith Machine", weight: 90, rest: 2*60)
//        program.exercises.append(exercise)
//    }
//
//    func addPull(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday]))
//        let workout = Workout("Pull", schedule)
//        
//        workout.addExercise(name: "SM Deadlift")
//        workout.addExercise(name: "Lat Pulldown")
//        workout.addExercise(name: "Pullups", enabled: false)
//        workout.addExercise(name: "Seated Cable Row")
//        workout.addExercise(name: "Hammer Curls")
//        workout.addExercise(name: "Face Pulls", enabled: false)
//
//        program.addWorkout(workout)
//    }
//
//    func addPush(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.wednesday]))
//        let workout = Workout("Push", schedule)
//
//        workout.addExercise(name: "SM Bench Press")
//        workout.addExercise(name: "DB OHP")
//        workout.addExercise(name: "Incline DB Press")
//        workout.addExercise(name: "Tricep Pushdown", enabled: false)
//        workout.addExercise(name: "Lateral Raise")
//
//        program.addWorkout(workout)
//    }
//
//    func addLegs(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("Legs", schedule)
//
//        workout.addExercise(name: "SM Squat")
//        workout.addExercise(name: "SM Romanian Deadlift")
//        workout.addExercise(name: "Leg Press")
//        workout.addExercise(name: "SM Calf Raises", enabled: false)
//        workout.addExercise(name: "Seated Leg Curls")
//
//        program.addWorkout(workout)
//    }
//
//    let program = Program("Planet Fitness 3")
//    program.summary = "[Program](https://www.reddit.com/r/Fitness/comments/9ldxy3/planet_fitness_hotel_apartment_gym_workout) for gyms without free barbells. This is a push/pull/legs split and designed to be performed three days a week."
//    addExercises(program)
//    addPull(program)
//    addPush(program)
//    addLegs(program)
//    return program
//}

/// Simulator only program used for testing.
fileprivate func previewProgram() -> Program {
    func addStyles(_ program: Program) {
        program.styles["Main"] = doubleStyle(warmup: "5/0 5/60 3/80 1/90", workset: "5 5 5+", rest: "3m")
        program.styles["Accessory"] = doubleStyle(warmup: "", workset: "8-12 8-12 8-12", rest: "2m")
        program.styles["Light"] = percentStyle(percent: 0.9, rest: "2m")
        program.styles["Stretch"] = durationsStyle(secs: "30s 30s 30s", targetSecs: "")
        program.styles["Walk"] = Style.timed
    }
    
    func addExercises(_ program: Program) {
        var exercise = make("Light Bench", "Bench Press", "Light", weights: "Dual Plates")
        addCompleted(exercise, daysAgo: 5, reps: [5, 5, 5], weights: [130], note: "So hard, nearly died")
        addCompleted(exercise, daysAgo: 3, reps: [5, 5, 5], weights: [135], note: "Went up easy peasy")
        addCompleted(exercise, daysAgo: 1, reps: [5, 5, 5], weights: [135])
        program.exercises.append(exercise)

        exercise = make("Heavy Bench", "Bench Press", "Main", weights: "Dual Plates", weight: 145)
        program.exercises.append(exercise)
        
        exercise = make("OHP", "Overhead Press", "Main", weights: "Dual Plates", weight: 80)
        program.exercises.append(exercise)

        exercise = make("Squat", "High bar Squat", "Main", weights: "Dual Plates", weight: 140)
        program.exercises.append(exercise)

        exercise = make("Deadlift", "Deadlift", "Main", weights: "Dual Plates", weight: 230)
        program.exercises.append(exercise)

        exercise = make("Light Face Pulls", "Face Pull", "Light", weights: "Cable Machine")
        program.exercises.append(exercise)

        exercise = make("Face Pulls", "Face Pull", "Accessory", weights: "Cable Machine", weight: 40.0)
        program.exercises.append(exercise)

        exercise = make("Quad Stretch", "Standing Quad Stretch", "Stretch")
        addCompleted(exercise, daysAgo: 5, secs: [10, 10, 10])
        addCompleted(exercise, daysAgo: 3, secs: [20, 20, 20])
        addCompleted(exercise, daysAgo: 1, secs: [20, 20, 20])
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
    addStyles(program)
    addExercises(program)
    addUpper(program)
    addLower(program)
    addActiveRest(program)
    return program
}

//fileprivate func stopgapProgram() -> Program {
//    func addExercises(_ program: Program) {
//        let reps: [VariableReps] = [.variable(3, 10), .variable(3, 10), .variable(3, 10)]
//        let areps: [VariableReps] = [.amrap(3), .amrap(3), .amrap(3)]
//
//        var exercise = make("Split Squat", "Dumbbell Single Leg Split Squat", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 60)
//        program.exercises.append(exercise)
//
//        exercise = make("Floor Press", "Dumbbell Floor Press", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 60)
//        program.exercises.append(exercise)
//
//        exercise = make("Shoulder Press", "Dumbbell Seated Shoulder Press", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 60)
//        program.exercises.append(exercise)
//
//        exercise = make("Deadlift", "Dumbbell Deadlift", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 60)
//        program.exercises.append(exercise)
//
//        exercise = make("Plank", "Plank", secs: [30, 30, 30])
//        program.exercises.append(exercise)
//
//        exercise = make("Row", "Bent Over Dumbbell Row", warmups: [], worksets: reps, weights: "Home Dumbbells", weight: 5, rest: 60)
//        program.exercises.append(exercise)
//        
//        // optional
//        exercise = make("Lunge", "Dumbbell Lunge", warmups: [], worksets: areps, weights: "Home Dumbbells", weight: 5, rest: 60)
//        program.exercises.append(exercise)
//
//        exercise = make("Dips", "Dips", warmups: [], worksets: areps, rest: 60)
//        program.exercises.append(exercise)
//
//        exercise = make("Pull-ups", "Pull-up", warmups: [], worksets: areps, rest: 60)
//        program.exercises.append(exercise)
//    }
//
//    func addA(_ program: Program, _ workout: Workout) {
//        workout.addExercise(name: "Split Squat")
//        workout.addExercise(name: "Lunge", enabled: false)
//        workout.addExercise(name: "Floor Press")
//        workout.addExercise(name: "Deadlift")
//        workout.addExercise(name: "Pull-ups", enabled: false)
//        workout.addExercise(name: "Plank")
//        program.addWorkout(workout)
//    }
//
//    func addB(_ program: Program, _ workout: Workout) {
//        workout.addExercise(name: "Split Squat")
//        workout.addExercise(name: "Lunge", enabled: false)
//        workout.addExercise(name: "Shoulder Press")
//        workout.addExercise(name: "Row")
//        workout.addExercise(name: "Dips", enabled: false)
//        workout.addExercise(name: "Plank")
//        program.addWorkout(workout)
//    }
//
//    // First week is A B A
//    func addA1(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday, .friday]))
//        let workout = Workout("A1", schedule)
//        workout.weeks = 1...1
//        addA(program, workout)
//    }
//
//    func addB1(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.wednesday]))
//        let workout = Workout("B1", schedule)
//        workout.weeks = 1...1
//        addB(program, workout)
//    }
//
//    // Second week is B A B
//    func addA2(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.wednesday]))
//        let workout = Workout("A2", schedule)
//        workout.weeks = 2...2
//        addA(program, workout)
//    }
//
//    func addB2(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday, .friday]))
//        let workout = Workout("B2", schedule)
//        workout.weeks = 2...2
//        addB(program, workout)
//    }
//
//    let program = Program("Dumbbell Stopgap")
//    program.summary = "[Designed](https://thefitness.wiki/reddit-archive/dumbbell-stopgap/) for home workouts with a small set of dummbells (or adjustable dumbbells) though it can also be used at a gym. Note that there are some optional exercises that you can enable using Edit Program on the top right of the main screen."
//    addExercises(program)
//    addA1(program)
//    addB1(program)
//    addA2(program)
//    addB2(program)
//    for w in program.workouts {
//        w.notes = "Start with easy weights. Increase the weight once you can do all three sets of ten. If you get stuck at the same number of reps and weight three times, then drop the weight by two increments and continue. For planks hold them as long as you can."
//    }
//    return program
//}
//
//fileprivate func strongCurves1() -> Program {
//    func addExercises(_ program: Program) {
//        // Workout A 1-4
//        var exercise = make("Glute Bridge", "Glute Bridge", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("One-arm Row", "Kroc Row", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("BW Box Squat", "Body-weight Box Squat", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("DB Bench Press", "Dumbbell Bench Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("DB Romanian Deadlift", "Dumbbell Romanian Deadlift", workstr: "10-20 10-20 10-20", weights: "Dumbbells", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Side Lying Abduction", "Side Lying Abduction", workstr: "15-30", rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Front Plank", "Plank", secs: [20], target: 120)
//        program.exercises.append(exercise)
//
//        exercise = make("Side Plank", "Kneeling Side Plank", secs: [20], target: 60)
//        program.exercises.append(exercise)
//
//        // Workout B 1-4
//        exercise = make("Single-leg Glute Bridge", "Single Leg Glute Bridge", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Lat Pulldown", "Lat Pulldown", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 30, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Step-ups", "Step-ups", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Overhead Press", "Overhead Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 10, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Back Extension", "Back Extension", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Crunches", "Swiss Ball Hip Internal Rotation", workstr: "15-30", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Side Crunch", "Exercise Ball Side Crunch", workstr: "15-30 15-30", rest: 90)
//        program.exercises.append(exercise)
//
//        // Workout C 1-4        
//        exercise = make("Glute March", "Glute March", secs: [60, 60, 60])
//        program.exercises.append(exercise)
//
//        exercise = make("Cable Row", "Seated Cable Row", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 30, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Squat", "Body-weight Squat", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Incline Press", "Dumbbell Incline Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 10, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Single-Leg Romanian Deadlift", "Body-weight Single-Leg Romanian Deadlift", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("X-Band Walk (light)", "X-Band Walk", workstr: "10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("RKC Plank", "RKC Plank", secs: [10], target: 30)
//        program.exercises.append(exercise)
//
//        exercise = make("Cable Wood Chop", "Cable Wood Chop", workstr: "5-10", weights: "Cable Machine", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        // Workout A 5-8
//        exercise = make("Body-weight Hip Thrust", "Body-weight Hip Thrust", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Standing One Arm Cable Row", "Standing One Arm Cable Row", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Step Up + Reverse Lunge", "Body-weight Step Up + Reverse Lunge", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Bench Press", "Bench Press", workstr: "8-12 8-12 8-12", weights: "Dual Plates", weight: 55, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Romanian Deadlift", "Romanian Deadlift", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 65, rest: 90)
//        program.exercises.append(exercise)
//
////        exercise = make("Side Lying Abduction", "Side Lying Abduction", workstr: "15-30 15-30", rest: 90)
//    
//        exercise = make("Feet Elevated Plank", "Plank", secs: [20], target: 60)
//        program.exercises.append(exercise)
//
////        exercise = make("Side Plank", "Kneeling Side Plank", secs: [20], target: 60)
//
//        // Workout B 5-8
////        exercise = make("Single-leg Glute Bridge", "Single Leg Glute Bridge", workstr: "10-20 10-20", rest: 90)
//
//        exercise = make("Negative Chin-ups", "Chin-up", workstr: "3 3 3", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Walking Lunge", "Body-weight Walking Lunge", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
////        exercise = make("Overhead Press", "Overhead Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 10, rest: 90)
//
//        exercise = make("Reverse Hyper", "Reverse Hyperextension", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Clam", "Clam", workstr: "15-30", rest: 90)
//        program.exercises.append(exercise)
//
////        exercise = make("Crunches", "Swiss Ball Hip Internal Rotation", workstr: "15-30", rest: 90)
////        exercise = make("Side Crunch", "Exercise Ball Side Crunch", workstr: "15-30 15-30", rest: 90)
//
//        // Workout C 5-8
//        exercise = make("Hip Thrust (rest pause)", "Hip Thrust (rest pause)", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Inverted Row", "Inverted Row", workstr: "8-12 8-12 8-12", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Goblet Squat", "Goblet Squat", workstr: "10-20 10-20 10-20", weights: "Dumbbells", weight: 30, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Close-Grip Bench Press", "Close-Grip Bench Press", workstr: "8-12 8-12 8-12", weights: "Dual Plates", weight: 45, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Kettlebell Swing", "Kettlebell Two Arm Swing", workstr: "10-20 10-20 10-20", weights: "Kettlebells", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("X-Band Walk (moderate)", "X-Band Walk", workstr: "15-30", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Situp", "Situp", workstr: "15-30", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Band Rotary Hold", "Band Anti-Rotary Hold", secs: [10], target: 20)
//        program.exercises.append(exercise)
//
//        // Workout A 9-12
//        exercise = make("Hip Thrust", "Hip Thrust", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 65, rest: 90)
//        program.exercises.append(exercise)
//        
////        exercise = make("One-arm Row", "Kroc Row", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 10, rest: 90)
//
//        exercise = make("Box Squat", "Box Squat", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 65, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Pushup", "Pushup", workstr: "3-10 3-10 3-10", rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Deadlift", "Deadlift", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 75, rest: 90)
//        program.exercises.append(exercise)
//        
////        exercise = make("Side Lying Abduction", "Side Lying Abduction", workstr: "15-30 15-30", rest: 90)
////        exercise = make("Crunches", "Swiss Ball Hip Internal Rotation", workstr: "15-30", rest: 90)
//
//        exercise = make("Anti-Rotation Press", "Half-kneeling Cable Anti-Rotation Press", workstr: "10-15", weights: "Cable Machine", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        // Workout B 9-12
//        exercise = make("Hip Thrust (shoulders elevated)", "Hip Thrust", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Chin-ups", "Chin-up", workstr: "1-5 1-5 1-5", rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Bulgarian Split Squat", "Body-weight Bulgarian Split Squat", workstr: "10-20 10-20 10-20", rest: 90)
//        program.exercises.append(exercise)
//        
////        exercise = make("Overhead Press", "Overhead Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 10, rest: 90)
//        
//        exercise = make("Good Morning", "Good Morning", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 65, rest: 90)
//        program.exercises.append(exercise)
//        
////        exercise = make("X-Band Walk (moderate)", "X-Band Walk", workstr: "10-20 10-20", rest: 90)
//        exercise = make("Feet Elevated Plank 2", "Plank", secs: [60], target: 120)
//        program.exercises.append(exercise)
//
//        exercise = make("Side Bend", "Dumbbell Side Bend", workstr: "15-30", weights: "Dumbbells", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        // Workout C 9-12  Inverted Row
//        exercise = make("Hip Thrust (pause rep)", "Hip Thrust", workstr: "8-15 8-15 8-15", weights: "Dual Plates", weight: 65, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Dumbbell Incline Row", "Dumbbell Incline Row", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("High bar Squat", "High bar Squat", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 65, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Incline Bench Press", "Incline Bench Press", workstr: "3-10 3-10 3-10", weights: "Dual Plates", weight: 45, rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Back Extension2", "Back Extension", workstr: "10-30 10-30 10-30", rest: 90)
//        program.exercises.append(exercise)
//        
////        exercise = make("Clam", "Clam", workstr: "15-30 15-30", rest: 90)
//        
//        exercise = make("Hanging Leg Raise", "Hanging Leg Raise", workstr: "10-20", rest: 90)
//        program.exercises.append(exercise)
//        
////        exercise = make("Cable Wood Chop", "Cable Wood Chop", workstr: "10-15 10-15", weights: "Cable Machine", weight: 30, rest: 90)
//    }
//    
//    func addA14(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday, .thursday]))
//        let workout = Workout("A14", schedule)
//        workout.weeks = 1...4
//        workout.addExercise(name: "Glute Bridge")
//        workout.addExercise(name: "One-arm Row")
//        workout.addExercise(name: "BW Box Squat")
//        workout.addExercise(name: "DB Bench Press")
//        workout.addExercise(name: "DB Romanian Deadlift")
//        workout.addExercise(name: "Side Lying Abduction")
//        workout.addExercise(name: "Front Plank")
//        workout.addExercise(name: "Side Plank")
//        workout.notes = "To save time you can superset Glute Bridge/One-arm Row and Box Squat/DB Bench Press."
//        program.addWorkout(workout)
//    }
//
//    func addB14(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.tuesday]))
//        let workout = Workout("B14", schedule)
//        workout.weeks = 1...4
//        workout.addExercise(name: "Single-leg Glute Bridge")
//        workout.addExercise(name: "Lat Pulldown")
//        workout.addExercise(name: "Step-ups")
//        workout.addExercise(name: "Overhead Press")
//        workout.addExercise(name: "Back Extension")
//        workout.addExercise(name: "Crunches")
//        workout.addExercise(name: "Side Crunch")
//        workout.notes = "To save time you can superset Glute Bridge/Lat Pulldown and Overhead Press/Back Extension."
//        program.addWorkout(workout)
//    }
//
//    func addC14(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("C14", schedule)
//        workout.weeks = 1...4
//        workout.addExercise(name: "Glute March")
//        workout.addExercise(name: "Cable Row")
//        workout.addExercise(name: "Squat")
//        workout.addExercise(name: "Incline Press")
//        workout.addExercise(name: "Single-Leg Romanian Deadlift")
//        workout.addExercise(name: "X-Band Walk (light)")
//        workout.addExercise(name: "RKC Plank")
//        workout.addExercise(name: "Cable Wood Chop")
//        workout.notes = "To save time you can superset Glute March/Cable Row and Squat/Incline Press."
//        program.addWorkout(workout)
//    }
//
//    func addA58(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday, .thursday]))
//        let workout = Workout("A58", schedule)
//        workout.weeks = 5...8
//        workout.addExercise(name: "Body-weight Hip Thrust")
//        workout.addExercise(name: "Standing One Arm Cable Row")
//        workout.addExercise(name: "Step Up + Reverse Lunge")
//        workout.addExercise(name: "Bench Press")
//        workout.addExercise(name: "Romanian Deadlift")
//        workout.addExercise(name: "Side Lying Abduction")
//        workout.addExercise(name: "Feet Elevated Plank")
//        workout.addExercise(name: "Side Plank")
//        workout.notes = "To save time you can superset Hip Thrust/Cable Row and Step Up/Bench Press."
//        program.addWorkout(workout)
//    }
//
//    func addB58(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.tuesday]))
//        let workout = Workout("B58", schedule)
//        workout.weeks = 5...8
//        workout.addExercise(name: "Single-leg Glute Bridge")
//        workout.addExercise(name: "Negative Chin-ups")
//        workout.addExercise(name: "Walking Lunge")
//        workout.addExercise(name: "Overhead Press")
//        workout.addExercise(name: "Reverse Hyper")
//        workout.addExercise(name: "Clam")
//        workout.addExercise(name: "Crunches")
//        workout.addExercise(name: "Side Crunch")
//        workout.notes = "To save time you can superset Glute Bridge/Chin-ups and Lunge/Overhead Press."
//        program.addWorkout(workout)
//    }
//
//    func addC58(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("C58", schedule)
//        workout.weeks = 5...8
//        workout.addExercise(name: "Hip Thrust (rest pause)")
//        workout.addExercise(name: "Inverted Row")
//        workout.addExercise(name: "Goblet Squat")
//        workout.addExercise(name: "Close-Grip Bench Press")
//        workout.addExercise(name: "Kettlebell Swing")
//        workout.addExercise(name: "X-Band Walk (moderate)")
//        workout.addExercise(name: "Situp")
//        workout.addExercise(name: "Band Rotary Hold")
//        workout.notes = "To save time you can superset Hip Thrust/Row and Goblet Squat/Bench Press."
//        program.addWorkout(workout)
//    }
//
//    func addA912(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday, .thursday]))
//        let workout = Workout("A912", schedule)
//        workout.weeks = 9...42              // 42 so users can keep going for a while if they want
//        workout.addExercise(name: "Hip Thrust")
//        workout.addExercise(name: "One-arm Row")
//        workout.addExercise(name: "Box Squat")
//        workout.addExercise(name: "Pushup")
//        workout.addExercise(name: "Deadlift")
//        workout.addExercise(name: "Side Lying Abduction")
//        workout.addExercise(name: "Crunches")
//        workout.addExercise(name: "Anti-Rotation Press")
//        workout.notes = "To save time you can superset Hip Thrust/Row and Box Squat/Pushup."
//        program.addWorkout(workout)
//    }
//
//    func addB912(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.tuesday]))
//        let workout = Workout("B912", schedule)
//        workout.weeks = 9...42
//        workout.addExercise(name: "Hip Thrust (shoulders elevated)")
//        workout.addExercise(name: "Chin-ups")
//        workout.addExercise(name: "Bulgarian Split Squat")
//        workout.addExercise(name: "Overhead Press")
//        workout.addExercise(name: "Good Morning")
//        workout.addExercise(name: "X-Band Walk (moderate)")
//        workout.addExercise(name: "Feet Elevated Plank 2")
//        workout.addExercise(name: "Side Bend")
//        workout.notes = "To save time you can superset Hip Thrust/Chin-ups and Split Squat/Overhead Press."
//        program.addWorkout(workout)
//    }
//
//    func addC912(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("C912", schedule)
//        workout.weeks = 9...42
//        workout.addExercise(name: "Hip Thrust (pause rep)")
//        workout.addExercise(name: "Dumbbell Incline Row")
//        workout.addExercise(name: "High bar Squat")
//        workout.addExercise(name: "Incline Bench Press")
//        workout.addExercise(name: "Back Extension2")
//        workout.addExercise(name: "Clam")
//        workout.addExercise(name: "Hanging Leg Raise")
//        workout.addExercise(name: "Cable Wood Chop")
//        workout.notes = "To save time you can superset Hip Thrust/Row and Squat/Bench Press."
//        program.addWorkout(workout)
//    }
//
//    let program = Program("Strong Curves beginner")
//    program.summary = "A 12-week four workouts a week [program](https://www.amazon.com/Strong-Curves-Womans-Building-Better/dp/1936608642) designed for women. After the 12 weeks are up you can continue the week 9-12 workouts or switch to the advanced program."
//    addExercises(program)
//    addA14(program)
//    addB14(program)
//    addC14(program)
//
//    addA58(program)
//    addB58(program)
//    addC58(program)
//
//    addA912(program)
//    addB912(program)
//    addC912(program)
//    return program
//}
//
//fileprivate func strongCurves2() -> Program {
//    func addExercises(_ program: Program) {
//        // Workout A 1-4
//        var exercise = make("Glute Bridge", "Glute Bridge", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 85, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("One-arm Row", "Kroc Row", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 30, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Box Squat", "Box Squat", workstr: "5-10 5-10 5-10", weights: "Dual Plates", weight: 65, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("DB Incline Press", "Dumbbell Incline Press", workstr: "8-12 8-12 8-12", weights: "Dumbbells", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Deadlift", "Deadlift", workstr: "5-10 5-10 5-10", weights: "Dual Plates", weight: 85, rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Cable Hip Abduction", "Cable Hip Abduction", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("RKC Plank", "RKC Plank", secs: [60])
//        program.exercises.append(exercise)
//
//        exercise = make("Side Plank", "Kneeling Side Plank", secs: [60, 60])
//        program.exercises.append(exercise)
//
//        // Workout B 1-4
//        exercise = make("Single Leg Hip Thrust", "Body-weight Single Leg Hip Thrust", workstr: "8-20 8-20 8-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Chin-ups", "Chin-up", workstr: "3-5 3-5 3-5", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Step-ups", "Step-ups", workstr: "10 10 10", weights: "Dumbbells", weight: 10, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Overhead Press", "Overhead Press", workstr: "5-10 5-10 5-10", weights: "Dual Plates", weight: 55, rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Prisoner Back Extension", "Back Extension", workstr: "8-12 8-12", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Band Seated Abduction", "Band Seated Abduction", workstr: "10-20", rest: 90)  // book had 20
//        program.exercises.append(exercise)
//
//        exercise = make("Situp", "Situp", workstr: "10-20", rest: 90)  // book had 20
//        program.exercises.append(exercise)
//
//        exercise = make("Side Bend", "Dumbbell Side Bend", workstr: "10-20", weights: "Dumbbells", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        // Workout C 1-4
//        exercise = make("Hip Thrust", "Hip Thrust", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 105, rest: 90) // book had fixed 20 which seems weird
//        program.exercises.append(exercise)
//
//        exercise = make("One Arm Cable Row", "Standing One Arm Cable Row", workstr: "4-8 4-8 4-8", weights: "Cable Machine", weight: 30, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Goblet Squat", "Goblet Squat", workstr: "3-5 3-5 3-5", weights: "Dumbbells", weight: 40, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("DB Bench Press", "Dumbbell Bench Press", workstr: "4-8 4-8 4-8", weights: "Dumbbells", weight: 30, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Pull Through", "Pull Through", workstr: "8-12 8-12 8-12", weights: "Cable Machine", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Side Lying Hip Raise", "Side Lying Hip Raise", workstr: "10", rest: 90)   // book had 10
//        program.exercises.append(exercise)
//
//        exercise = make("Turkish Get-Up", "Turkish Get-Up", workstr: "5", weights: "Kettlebells", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Anti-Rotation Press", "Half-kneeling Cable Anti-Rotation Press", workstr: "8-12", weights: "Cable Machine", weight: 30, rest: 90)
//        program.exercises.append(exercise)
//
//        // Workout A 5-8
////        exercise = make("Hip Thrust", "Hip Thrust", workstr: "3-8 3-8 3-8", weights: "Dual Plates", weight: 105, rest: 90)
//
//        exercise = make("Cable Row", "Seated Cable Row", workstr: "4-8 4-8 4-8", weights: "Cable Machine", weight: 30, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("High bar Squat", "High bar Squat", workstr: "5 5 5", weights: "Dual Plates", weight: 85, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Bench Press", "Bench Press", workstr: "3-8 3-8 3-8", weights: "Dual Plates", weight: 65, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Good Morning", "Good Morning", workstr: "8-12 8-12 8-12", weights: "Dual Plates", weight: 85, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Band Standing Abduction", "Band Standing Abduction", workstr: "10-30", rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Ab Wheel Rollout", "Ab Wheel Rollout", workstr: "8-20", rest: 90)
//        program.exercises.append(exercise)
//
////        exercise = make("Side Bend", "Dumbbell Side Bend", workstr: "10-20", weights: "Dumbbells", weight: 20, rest: 90)
//
//        // Workout B 5-8
//        exercise = make("BW Hip Thrust", "Hip Thrust", workstr: "8-20 8-20 8-20", rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("Pull-up", "Pull-up", workstr: "3-8 3-8 3-8", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Walking Lunge", "Body-weight Walking Lunge", workstr: "5-10 5-10 5-10", rest: 90)
//        program.exercises.append(exercise)
//
////        exercise = make("Overhead Press", "Overhead Press", workstr: "10-20 10-20 10-20", weights: "Dual Plates", weight: 55, rest: 90)   // book had 3x10
//
//        exercise = make("Back Extension", "Back Extension", workstr: "10-20 10-20", weights: "Dumbbells", weight: 10, rest: 90)
//        program.exercises.append(exercise)
//        
////        exercise = make("Band Seated Abduction", "Band Seated Abduction", workstr: "10-30", rest: 90)
//        
//        exercise = make("Hanging Leg Raise", "Hanging Leg Raise", workstr: "8-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Landmines", "Landmine 180's", workstr: "8-12", weights: "Single Plates", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        // Workout C 5-8
//        // TODO this iss a weird one where we'd want a rest with durations. Not sure how best to support
//        // that, maybe ExercisePlan would have sets for duration and sets for rest...
////        exercise = make("Hip Thrust (isohold)", "Hip Thrust (isohold)", secs: [30, 30, 30], target: 60, weights: "Dual Plates", weight: 85)
//
//        exercise = make("Lat Pulldown", "Lat Pulldown", workstr: "4-8 4-8 4-8", weights: "Cable Machine", weight: 40, rest: 90)  // book had 8
//        program.exercises.append(exercise)
//
//        exercise = make("Skater Squat", "Skater Squat", workstr: "8 8 8", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Pushup", "Pushup", workstr: "5-15 5-15 5-15", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Single Leg Romanian Deadlift", "Single Leg Romanian Deadlift", workstr: "8-12 8-12 8-12", weights: "Dual Plates", weight: 65, rest: 90)
//        program.exercises.append(exercise)
//
////        exercise = make("Side Lying Hip Raise", "Side Lying Hip Raise", workstr: "10-30 10-30", rest: 90)
////        exercise = make("Situp", "Situp", workstr: "10-20", rest: 90)
////        exercise = make("Side Bend", "Dumbbell Side Bend", workstr: "10-20 10-20", weights: "Dumbbells", weight: 20, rest: 90)
//
//        // Workout A 9-12
//        exercise = make("Hip Thrust (rest pause)", "Hip Thrust (rest pause)", workstr: "5-10 5-10 5-10", weights: "Dual Plates", weight: 105, rest: 90) // book had fixed 10 which seems weird
//        program.exercises.append(exercise)
//        
//        exercise = make("Inverted Row", "Inverted Row", workstr: "6-12 6-12 6-12", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Zercher Squat", "Zercher Squat", workstr: "5-10 5-10 5-10", weights: "Dual Plates", weight: 85, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Pushup (feet elevated)", "Pushup", workstr: "5-20 5-20 5-20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Sumo Deadlift", "Sumo Deadlift", workstr: "6-12 6-12 6-12", weights: "Dual Plates", weight: 105, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("X-Band Walk", "X-Band Walk", workstr: "20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Crunches", "Swiss Ball Hip Internal Rotation", workstr: "20", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Band Rotary Hold", "Band Anti-Rotary Hold", secs: [15, 15])
//        program.exercises.append(exercise)
//
//        // Workout B 9-12
//        exercise = make("Hip Thrust (constant tension)", "Hip Thrust (constant tension)", workstr: "20-30 20-30 20-30", weights: "Dual Plates", weight: 85, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Weighted Pull-up", "Pull-up", workstr: "1-3 1-3 1-3", weights: "Dumbbells", weight: 5, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Bulgarian Split Squat", "Dumbbell Single Leg Split Squat", workstr: "5-10 5-10 5-10", weights: "Dumbbells", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Incline Press", "Incline Bench Press", workstr: "6-10 6-10 6-10", weights: "Dual Plates", weight: 55, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Gliding Leg Curl", "Gliding Leg Curl", workstr: "6-15 6-15", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Cable Hip Rotation", "Cable Hip Rotation", workstr: "8-15", weights: "Cable Machine", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Body Saw", "Body Saw", workstr: "8-15", rest: 90)
//        program.exercises.append(exercise)
//
//        exercise = make("Cable Anti-Rotation Press", "Half-kneeling Cable Anti-Rotation Press", workstr: "8-12", weights: "Cable Machine", weight: 20, rest: 90)
//        program.exercises.append(exercise)
//
//        // Workout C 9-12
////        exercise = make("Hip Thrust", "Hip Thrust", workstr: "3-8 3-8 3-8", weights: "Dual Plates", weight: 105, rest: 90) // book had fixed 20 which seems weird
//
//        exercise = make("Chest Supported Row", "Chest Supported Row", workstr: "6-12 6-12 6-12", weights: "Dumbbells", weight: 15, rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("DB Lunge", "Dumbbell Lunge", workstr: "8-15 8-15 8-15", weights: "Dumbbells", weight: 10, rest: 90)
//        program.exercises.append(exercise)
//        
//        exercise = make("DB Shoulder Press", "Dumbbell Shoulder Press", workstr: "8-15 8-15 8-15", weights: "Dumbbells", weight: 10, rest: 90)
//        program.exercises.append(exercise)
//
////        exercise = make("Prisoner Back Extension", "Back Extension", workstr: "8-15 8-15 8-15", rest: 90)
////        exercise = make("Side Lying Hip Raise", "Side Lying Hip Raise", workstr: "10-30 10-30", rest: 90)
////        exercise = make("Hanging Leg Raise", "Hanging Leg Raise", workstr: "8-20", rest: 90)
////        exercise = make("Landmines", "Landmine 180's", workstr: "8-12 8-12", weights: "Single Plates", weight: 20, rest: 90)
//    }
//    
//    func addA14(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday, .thursday]))
//        let workout = Workout("A14", schedule)
//        workout.weeks = 1...4
//        workout.addExercise(name: "Glute Bridge")
//        workout.addExercise(name: "One-arm Row")
//        workout.addExercise(name: "Box Squat")
//        workout.addExercise(name: "DB Incline Press")
//        workout.addExercise(name: "Deadlift")
//        workout.addExercise(name: "Cable Hip Abduction")
//        workout.addExercise(name: "RKC Plank")
//        workout.addExercise(name: "Side Plank")
//        workout.notes = "To save time you can superset Glute Bridge/Row and Squat/Incline Press."
//        program.addWorkout(workout)
//    }
//
//    func addB14(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.tuesday]))
//        let workout = Workout("B14", schedule)
//        workout.weeks = 1...4
//        workout.addExercise(name: "Single Leg Hip Thrust")
//        workout.addExercise(name: "Chin-ups")
//        workout.addExercise(name: "Step-ups")
//        workout.addExercise(name: "Overhead Press")
//        workout.addExercise(name: "Prisoner Back Extension")
//        workout.addExercise(name: "Band Seated Abduction")
//        workout.addExercise(name: "Situp")
//        workout.addExercise(name: "Side Bend")
//        workout.notes = "To save time you can superset Glute Bridge/Lat Pulldown and Overhead Press/Back Extension."
//        program.addWorkout(workout)
//    }
//
//    func addC14(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("C14", schedule)
//        workout.weeks = 1...4
//        workout.addExercise(name: "Hip Thrust")
//        workout.addExercise(name: "One Arm Cable Row")
//        workout.addExercise(name: "Goblet Squat")
//        workout.addExercise(name: "DB Bench Press")
//        workout.addExercise(name: "Pull Through")
//        workout.addExercise(name: "Side Lying Hip Raise")
//        workout.addExercise(name: "Turkish Get-Up")
//        workout.addExercise(name: "Anti-Rotation Press")
//        workout.notes = "To save time you can superset Hip Thrust/Row and Goblet Squat/Bench Press."
//        program.addWorkout(workout)
//    }
//
//    func addA58(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday, .thursday]))
//        let workout = Workout("A58", schedule)
//        workout.weeks = 5...8
//        workout.addExercise(name: "Hip Thrust")
//        workout.addExercise(name: "Cable Row")
//        workout.addExercise(name: "High bar Squat")
//        workout.addExercise(name: "Bench Press")
//        workout.addExercise(name: "Good Morning")
//        workout.addExercise(name: "Band Standing Abduction")
//        workout.addExercise(name: "Ab Wheel Rollout")
//        workout.addExercise(name: "Side Bend")
//        workout.notes = "To save time you can superset Hip Thrust/Row and Squat/Bench Press."
//        program.addWorkout(workout)
//    }
//
//    func addB58(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.tuesday]))
//        let workout = Workout("B58", schedule)
//        workout.weeks = 5...8
//        workout.addExercise(name: "BW Hip Thrust")
//        workout.addExercise(name: "Pull-up")
//        workout.addExercise(name: "Walking Lunge")
//        workout.addExercise(name: "Overhead Press")
//        workout.addExercise(name: "Back Extension")
//        workout.addExercise(name: "Band Seated Abduction")
//        workout.addExercise(name: "Hanging Leg Raise")
//        workout.addExercise(name: "Landmines")
//        workout.notes = "To save time you can superset Hip Thrust/Pull-up and Lunge/Overhead Press."
//        program.addWorkout(workout)
//    }
//
//    func addC58(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("C58", schedule)
//        workout.weeks = 5...8
//        workout.addExercise(name: "Hip Thrust (rest pause)")
//        workout.addExercise(name: "Lat Pulldown")
//        workout.addExercise(name: "Skater Squat")
//        workout.addExercise(name: "Pushup")
//        workout.addExercise(name: "Single Leg Romanian Deadlift")
//        workout.addExercise(name: "Side Lying Hip Raise")
//        workout.addExercise(name: "Situp")
//        workout.addExercise(name: "Side Bend")
//        workout.notes = "To save time you can superset Hip Thrust/Lat Pulldown and Squat/Pushup."
//        program.addWorkout(workout)
//    }
//
//    func addA912(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.monday, .thursday]))
//        let workout = Workout("A912", schedule)
//        workout.weeks = 9...42              // 42 so users can keep going for a while if they want
//        workout.addExercise(name: "Hip Thrust (rest pause)")
//        workout.addExercise(name: "Inverted Row")
//        workout.addExercise(name: "Zercher Squat")
//        workout.addExercise(name: "Pushup (feet elevated)")
//        workout.addExercise(name: "Sumo Deadlift")
//        workout.addExercise(name: "X-Band Walk")
//        workout.addExercise(name: "Crunches")
//        workout.addExercise(name: "Band Rotary Hold")
//        workout.notes = "To save time you can superset Hip Thrust/Row and Squat/Pushup."
//        program.addWorkout(workout)
//    }
//
//    func addB912(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.tuesday]))
//        let workout = Workout("B912", schedule)
//        workout.weeks = 9...42
//        workout.addExercise(name: "Hip Thrust (constant tension)")
//        workout.addExercise(name: "Weighted Pull-up")
//        workout.addExercise(name: "Bulgarian Split Squat")
//        workout.addExercise(name: "Incline Press")
//        workout.addExercise(name: "Gliding Leg Curl")
//        workout.addExercise(name: "Cable Hip Rotation")
//        workout.addExercise(name: "Body Saw")
//        workout.addExercise(name: "Cable Anti-Rotation Press")
//        workout.notes = "To save time you can superset Hip Thrust/Pull-up and Squat/Incline Press."
//        program.addWorkout(workout)
//    }
//
//    func addC912(_ program: Program) {
//        let schedule = Schedule.days(Weekdays([.friday]))
//        let workout = Workout("C912", schedule)
//        workout.weeks = 9...42
//        workout.addExercise(name: "Hip Thrust")
//        workout.addExercise(name: "Chest Supported Row")
//        workout.addExercise(name: "DB Lunge")
//        workout.addExercise(name: "DB Shoulder Press")
//        workout.addExercise(name: "Prisoner Back Extension")
//        workout.addExercise(name: "Side Lying Hip Raise")
//        workout.addExercise(name: "Hanging Leg Raise")
//        workout.addExercise(name: "Landmines")
//        workout.notes = "To save time you can superset Hip Thrust/Row and Lunge/Shoulder Press."
//        program.addWorkout(workout)
//    }
//
//    let program = Program("Strong Curves advanced")
//    program.summary = "A 12-week four workouts a week [program](https://www.amazon.com/Strong-Curves-Womans-Building-Better/dp/1936608642) designed for women. After the 12 weeks are up you can continue the week 9-12 workouts or switch to the advanced program."
//    addExercises(program)
//    addA14(program)
//    addB14(program)
//    addC14(program)
//
//    addA58(program)
//    addB58(program)
//    addC58(program)
//
//    addA912(program)
//    addB912(program)
//    addC912(program)
//    return program
//}

// Public for unit tests
func make(_ name: String, _ formalName: String, _ styleName: String, weights: String? = nil, weight: Float? = nil) -> Exercise {
    if let n = weights {
        return Exercise(name: name, formalName: formalName, styleName: styleName, weights: n, weight: weight)
    } else {
        return Exercise(name: name, formalName: formalName, styleName: styleName, weight: weight)
    }
}

// Public for unit tests
func addCompleted(_ exercise: Exercise, daysAgo: Int, reps: [Int], weights: [Float]? = nil, note: String? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let c = Completed(reps: reps, weights: weights, units: .Imperial, completed: d!)
    c.note = note
    exercise.history.append(c)
}

// Public for unit tests
func addCompleted(_ exercise: Exercise, daysAgo: Int, secs: [Int], weights: [Float]? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let c = Completed(secs: secs, weights: weights, units: .Imperial, completed: d!)
    exercise.history.append(c)
}

fileprivate func doubleStyle(warmup: String, workset: String, backoff: String? = nil, rest: String) -> Style {
    if let i = DoubleProgressionInfo(warmup: warmup, workset: workset, backoff: backoff, rest: rest) {
        return .double_progression(i)
    } else {
        fatalError("bad args")
    }
}

fileprivate func durationsStyle(secs: String, targetSecs: String) -> Style {
    if let i = DurationsInfo(secs: secs, targetSecs: targetSecs) {
        return .durations(i)
    } else {
        fatalError("bad args")
    }
}

fileprivate func percentStyle(percent: Float, rest: String) -> Style {
    if let i = PercentInfo(percent: percent, rest: rest) {
        return .percent(i)
    } else {
        fatalError("bad args")
    }
}
