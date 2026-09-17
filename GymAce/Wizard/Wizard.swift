/// Used to generate a new program according to user input.
final class Wizard {
    enum Goal {
        case strength
        case hypertrophy
        case glute
        case conditioning
    }
    
    enum Fitness {
        case beginner
        case intermediate
        case advanced
    }
    
    var goal: Goal              // these affect the program type, eg basic or gzcl
    var fitness: Fitness
    
    var barbells: Bool          // for the most part these just affect exercise selection
    var numDumbbells: Int       // but if all they have are one or two dumbbells then we'll just use a complex
    var machines: Bool
    var smith: Bool
    
    var age: Int                // can affect volume
    var numWorkouts: Int        // per week
    let model: Model
    
    init(_ model: Model) {
        self.model = model
        self.age = 20
        self.barbells = true
        self.numDumbbells = 10  // exact number doesn't really matter, just whether they have only a few or quite a lot
        self.machines = true
        self.smith = true
        self.goal = .strength
        self.fitness = .beginner
        self.numWorkouts = 3
    }
    
    func generate() {
        var program: Program
        if barbells || numDumbbells > 5 || machines {
            // User has equipment, so we can generate a program with weights.
            switch fitness {
            case .beginner:
                switch goal {
                case .strength, .hypertrophy, .glute:
                    program = makeBasic()
                case .conditioning:
                    if numDumbbells > 0 {
                        program = makeComplex()
                    } else {
                        program = makeStub()   // TODO use one of A8, B8, or F8?
                    }
                }
            case .intermediate, .advanced:  // TODO for now we handle advanced like intermediate
                switch goal {
                case .strength:
                    program = makeStub()   // TODO gzcl style, may want to allow them to select between different base routines
                case .hypertrophy:
                    program = makeStub()   // TODO ppl style? or boring but big? or PHAT? may want to allow them to select between different base routines
                case .glute:
                    program = makeStub()   // TODO gzcl style (tweak exercises)
                case .conditioning:
                    program = makeComplex()
                }
            }
        } else if numDumbbells > 0 {
            // User has only a few dumbbells, so we will generate a complex program.
            program = makeComplex()
        } else {
            // User has no equipment, so we will generate a bodyweight program.
            program = makeBW()
        }
        if !program.valid(model) {      // TODO this should probably check links
            fatalError("bad program")   // TODO handle this better, e.g. show an error message
        }
        model.programs.append(program)
        model.activeProgram = program.name
    }
    
    // TODO might be better to have multiple versions of this
    //      starting to get messy, especially after adding glute workouts
    //      maybe basic, basicMachine, and basicGlute
    //      maybe the way to do this is to have fields for closures that
    //         create the program, add styles, add exercise, etc
    //         then a driver just invokes those to build the full program
    private func makeBasic() -> Program {
        func addSquatExercises(_ workout: Workout) {
            if barbells || numDumbbells > 0 || smith {
                workout.addExercise(name: "Row")
                workout.addExercise(name: "Bench Press")
                workout.addExercise(name: "Squat")
            } else {
                workout.addExercise(name: "Seated Row")
                workout.addExercise(name: "Chest Press")
                workout.addExercise(name: "Leg Press")
            }
        }
        
        func addDeadExercises(_ workout: Workout) {
            if barbells || numDumbbells > 0 || smith {
                workout.addExercise(name: "Chin Ups")
                workout.addExercise(name: "OHP")
                workout.addExercise(name: "Deadlift")
            } else {
                workout.addExercise(name: "Chin Ups")
                workout.addExercise(name: "Shoulder Press")
                workout.addExercise(name: "Pull-Through")
            }
        }
        
        let name = findName(hasName, prefix: "Basic")
        let program = Program(name)
        program.summary = "A simple [program](https://thefitness.wiki/routines/r-fitness-basic-beginner-routine) for beginners. It's meant to be run for about three months after which you should switch to an intermediate program. For the last sets do as many reps as you can but try to stop when you have 1-2 reps left."
    
        if barbells {
            if case .hypertrophy = goal {
                program.styles["Primary"] =   amrapStyle(warmup: "5/0 5/60 3/80 1/90", workset: "8 8 8", rest: "2m")
                program.styles["Secondary"] = amrapStyle(warmup: "5/60 3/80 1/90", workset: "8 8 8", rest: "2m")
                program.styles["Tertiary"] =  variableStyle(warmup: "", workset: "4-8 4-8 4-8", rest: "2m")
            } else {
                program.styles["Primary"] =   amrapStyle(warmup: "5/0 5/60 3/80 1/90", workset: "5 5 5", rest: "2m")
                program.styles["Secondary"] = amrapStyle(warmup: "5/60 3/80 1/90", workset: "5 5 5", rest: "2m")
                program.styles["Tertiary"] =  variableStyle(warmup: "", workset: "4-8 4-8 4-8", rest: "2m")
            }

            // TODO tweak exercises for glute? maybe swap out row and ohp, also chins to lat pulldown
            var exercise = make("Row", "Pendlay Row", "Secondary", weights: "Dual Plates", weight: 65)
            program.exercises.append(exercise)
            
            exercise = make("Bench Press", "Bench Press", "Primary", weights: "Dual Plates", weight: 65)
            program.exercises.append(exercise)
            
            exercise = make("Squat", "High bar Squat", "Primary", weights: "Dual Plates", weight: 85)
            program.exercises.append(exercise)
            
            exercise = make("OHP", "Overhead Press", "Primary", weights: "Dual Plates", weight: 55)
            program.exercises.append(exercise)
            
            exercise = make("Deadlift", "Deadlift", "Secondary", weights: "Dual Plates", weight: 95)
            program.exercises.append(exercise)
            
            exercise = make("Chin Ups", "Chin-up", "Tertiary", weights: "Single Plates", weight: 0)
            program.exercises.append(exercise)

        } else if numDumbbells > 0 {
            program.styles["Primary"] = variableStyle(warmup: "5/60 3/80 1/90", workset: "4-8 4-8 4-8", rest: "2m") // TODO reduce warmups?
            program.styles["Tertiary"] =  variableStyle(warmup: "", workset: "4-8 4-8 4-8", rest: "2m")

            var exercise = make("Row", "Kroc Row", "Primary", weights: "Dumbbells", weight: 25)
            program.exercises.append(exercise)
            
            exercise = make("Bench Press", "Dumbbell Bench Press", "Primary", weights: "Dumbbells", weight: 20)
            program.exercises.append(exercise)
            
            exercise = make("Squat", "Dumbbell Single Leg Split Squat", "Primary", weights: "Dumbbells", weight: 10)
            program.exercises.append(exercise)
            
            exercise = make("OHP", "Dumbbell Shoulder Press", "Primary", weights: "Dumbbells", weight: 10)
            program.exercises.append(exercise)
            
            exercise = make("Deadlift", "Dumbbell Deadlift", "Primary", weights: "Dumbbells", weight: 40)
            program.exercises.append(exercise)
            
            exercise = make("Chin Ups", "Chin-up", "Tertiary", weights: "Dumbbells", weight: 0)
            program.exercises.append(exercise)

        } else if smith {
            program.styles["Primary"] = variableStyle(warmup: "5/60 3/80 1/90", workset: "4-8 4-8 4-8", rest: "2m")
            program.styles["Tertiary"] =  variableStyle(warmup: "", workset: "4-8 4-8 4-8", rest: "2m")

            var exercise = make("Row", "Seated Cable Row", "Primary", weights: "Cable Machine", weight: 25)
            program.exercises.append(exercise)
            
            exercise = make("Bench Press", "Smith Machine Bench", "Primary", weights: "Dual Plates", weight: 20)
            program.exercises.append(exercise)
            
            exercise = make("Squat", "Smith Machine Squat", "Primary", weights: "Dual Plates", weight: 35)
            program.exercises.append(exercise)
            
            exercise = make("OHP", "Seated Smith Machine Press", "Primary", weights: "Dual Plates", weight: 20)
            program.exercises.append(exercise)
            
            exercise = make("Deadlift", "Smith Machine Deadlift", "Primary", weights: "Dual Plates", weight: 40) 
            program.exercises.append(exercise)
            
            exercise = make("Chin Ups", "Chin-up", "Tertiary")
            program.exercises.append(exercise)
            
        } else {    // TODO verify links in notes
            program.styles["Primary"] = variableStyle(warmup: "5/60 3/80 1/90", workset: "4-8 4-8 4-8", rest: "2m")  // TODO reduce warmups?
            program.styles["Tertiary"] =  variableStyle(warmup: "", workset: "4-8 4-8 4-8", rest: "2m")

            var exercise = make("Seated Row", "Seated Cable Row", "Primary", weights: "Cable Machine", weight: 25)
            program.exercises.append(exercise)

            exercise = make("Chest Press", "Chest Press machine", "Primary", weights: "Dual Plates", weight: 20)
            program.exercises.append(exercise)

            exercise = make("Leg Press", "Leg Press", "Primary", weights: "Dual Plates", weight: 25)
            program.exercises.append(exercise)
            
            exercise = make("Shoulder Press", "Shoulder Press Machine", "Primary", weights: "Dual Plates", weight: 15)
            program.exercises.append(exercise)

            exercise = make("Pull-Through", "Pull Through", "Primary", weights: "Cable Machine", weight: 20)
            program.exercises.append(exercise)

            exercise = make("Chin Ups", "Chin-up", "Tertiary")
            program.exercises.append(exercise)
        }

        if numWorkouts == 2 {    // UI restricts numWorkouts to 2, 3, or 4 for basic
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Squat", schedule)
            addSquatExercises(workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("Deadlift", schedule)
            addDeadExercises(workout)
            program.addWorkout(workout)
            
        } else if numWorkouts == 3 {
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Squat 1a", schedule)
            addSquatExercises(workout)
            workout.weeks = 1...1
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("Deadlift 1", schedule)
            addDeadExercises(workout)
            workout.weeks = 1...1
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Squat 1b", schedule)
            addSquatExercises(workout)
            workout.weeks = 1...1
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.monday]))
            workout = Workout("Deadlift 2a", schedule)
            addDeadExercises(workout)
            workout.weeks = 2...2
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("Squat 2", schedule)
            addSquatExercises(workout)
            workout.weeks = 2...2
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Deadlift 2b", schedule)
            addDeadExercises(workout)
            workout.weeks = 2...2
            program.addWorkout(workout)
            
        } else {
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Squat 1", schedule)
            addSquatExercises(workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.tuesday]))
            workout = Workout("Deadlift 1", schedule)
            addDeadExercises(workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("Squat 2", schedule)
            addSquatExercises(workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Deadlift 2", schedule)
            addDeadExercises(workout)
            program.addWorkout(workout)
        }
                
        model.addMissingWeightsets()
    
        return program
    }
        
    private func makeBW() -> Program {
        let name = findName(hasName, prefix: "Bodyweight")
        let program = Program(name)
        // TODO use
        // https://www.reddit.com/r/bodyweightfitness/wiki/index/?utm_source=reddit&utm_medium=usertext&utm_name=bodyweightfitness&utm_content=t5_2tf0a
        // may want to add a Progression style
        return program
    }
        
    private func makeComplex() -> Program {
        let name = findName(hasName, prefix: "Complex")
        let program = Program(name)
        program.summary = "[Complexes](https://lipsticklifters.com/articles/dumbbell-complex/) are a blend between cardio and weight lifting. The idea is that you peform a set of exercises with a fixed weight without resting or setting the weight down, do a short rest, and repeat. Unless you are in great shape this will quickly get intense so start with a weight much lighter than what you can do for one of the exercises."
    
        program.styles["Complex"] = manualStyle(warmup: "", workset: "1 1 1", rest: "90s")  

        let exercise = if case .beginner = fitness {
            make("Complex", "Complex - beginner", "Complex", weights: "Dumbbells", weight: 5)
        } else {
            make("Complex", "Complex - intermediate", "Complex", weights: "Dumbbells", weight: 10)
        }
        program.exercises.append(exercise)
    
        // TODO would be nice to support cycle, eg every other day
        let schedule = if numWorkouts == 1 {    // UI restricts numWorkouts to 1, 2, or 3 for complexes
            Schedule.days(Weekdays([.monday]))
        } else if numWorkouts == 2 {
            Schedule.days(Weekdays([.monday, .thursday]))
        } else {
            Schedule.days(Weekdays([.monday, .wednesday, .friday]))
        }
        let workout = Workout("Complex", schedule)
        workout.addExercise(name: "Complex")
        program.addWorkout(workout)
        
        model.addMissingWeightsets()
    
        return program
    }
        
    // TODO get rid of this once we handle all the cases
    private func makeStub() -> Program {
        let name = findName(hasName, prefix: "Stub")
        let program = Program(name)
        return program
    }
        
    private func hasName(_ name: String) -> Bool {
        return model.programs.contains(where: {$0.name == name})
    }
}
