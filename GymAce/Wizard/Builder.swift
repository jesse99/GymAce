class Builder {
    fileprivate let wizard: Wizard
    
    init(_ wizard: Wizard) {
        self.wizard = wizard
    }
    
    /// The name of the program. A suffix may be appended by the wizard to make the name unique.
    var name: String {fatalError("override this")}
    
    /// The schedules supported by the program. The user will pick one of these before the program is populated.
    var schedules: [Wizard.Schedule] {fatalError("override this")}
    
    func build(_ program: Program) {
        fatalError("override this")
    }
    
    fileprivate func appendExercises(_ program: Program, _ exercises: [Exercise]) {
        for exercise in exercises {
            if program.findExercise(exercise.name) == nil {
                program.exercises.append(exercise)
            }
        }
    }
}

class BaseBasic: Builder {
    fileprivate var workout1Exercises: [String] = []
    fileprivate var workout2Exercises: [String] = []
    fileprivate var workout1Name: String = "Squat"
    fileprivate var workout2Name: String = "Deadlift"
    fileprivate var disabled: [String] = []

    override init(_ wizard: Wizard) {
        super.init(wizard)
    }
    
    override var name: String {return "Basic"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(2), .weekly(3), .weekly(4), .cycle(4), .cycle(6)]}

    fileprivate func scheduleWorkouts(_ program: Program) {
        switch wizard.schedule {
        case .weekly(let days) where days == 2:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout(workout1Name, schedule)
            addWorkout1Exercises(workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout(workout2Name, schedule)
            addWorkout2Exercises(workout)
            program.addWorkout(workout)
        case .weekly(let days) where days == 3:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("\(workout1Name) 1a", schedule)
            addWorkout1Exercises(workout)
            workout.weeks = 1...1
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("\(workout2Name) 1", schedule)
            addWorkout2Exercises(workout)
            workout.weeks = 1...1
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("\(workout1Name) 1b", schedule)
            addWorkout1Exercises(workout)
            workout.weeks = 1...1
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.monday]))
            workout = Workout("\(workout2Name) 2a", schedule)
            addWorkout2Exercises(workout)
            workout.weeks = 2...2
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("\(workout1Name) 2", schedule)
            addWorkout1Exercises(workout)
            workout.weeks = 2...2
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("\(workout2Name) 2b", schedule)
            addWorkout2Exercises(workout)
            workout.weeks = 2...2
            program.addWorkout(workout)
        case .weekly(let days) where days == 4:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("\(workout1Name) 1", schedule)
            addWorkout1Exercises(workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.tuesday]))
            workout = Workout("\(workout2Name) 1", schedule)
            addWorkout2Exercises(workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("\(workout1Name) 2", schedule)
            addWorkout1Exercises(workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("\(workout2Name) 2", schedule)
            addWorkout2Exercises(workout)
            program.addWorkout(workout)
        case .cycle(let days) where days == 4:
            let schedule = Schedule.cyclic
            var workout = Workout(workout1Name, schedule)
            addWorkout1Exercises(workout)
            program.addWorkout(workout)

            workout = Workout("Rest 1", schedule)
            program.addWorkout(workout)

            workout = Workout(workout2Name, schedule)
            addWorkout2Exercises(workout)
            program.addWorkout(workout)

            workout = Workout("Rest 2", schedule)
            program.addWorkout(workout)
        case .cycle(let days) where days == 6:
            let schedule = Schedule.cyclic
            var workout = Workout(workout1Name, schedule)
            addWorkout1Exercises(workout)
            program.addWorkout(workout)

            workout = Workout("Rest 1a", schedule)
            program.addWorkout(workout)
            workout = Workout("Rest 1b", schedule)
            program.addWorkout(workout)

            workout = Workout(workout2Name, schedule)
            addWorkout2Exercises(workout)
            program.addWorkout(workout)

            workout = Workout("Rest 2a", schedule)
            program.addWorkout(workout)
            workout = Workout("Rest 2b", schedule)
            program.addWorkout(workout)
        default:
            fatalError("\(wizard.schedule) shouldn't have happened")
        }
    }
    
    fileprivate func appendWorkout1Exercises(_ program: Program, _ exercises: [Exercise]) {
        appendExercises(program, exercises)
        workout1Exercises.append(contentsOf: exercises.map {$0.name})
    }

    fileprivate func appendWorkout2Exercises(_ program: Program, _ exercises: [Exercise]) {
        appendExercises(program, exercises)
        workout2Exercises.append(contentsOf: exercises.map {$0.name})
    }

    fileprivate func addWorkout1Exercises(_ workout: Workout) {
        for name in workout1Exercises {
            let enabled = !disabled.contains(where: {$0 == name})
            workout.addExercise(name: name, enabled: enabled)
        }
    }
    
    fileprivate func addWorkout2Exercises(_ workout: Workout) {
        for name in workout2Exercises {
            let enabled = !disabled.contains(where: {$0 == name})
            workout.addExercise(name: name, enabled: enabled)
        }
    }
}

final class BasicBarbellBuilder: BaseBasic {
    override func build(_ program: Program) {
        workout1Exercises = []
        workout2Exercises = []
        
        program.summary = "A simple [program](https://thefitness.wiki/routines/r-fitness-basic-beginner-routine) for beginners. It's meant to be run for about three months after which you should switch to an intermediate program. For the last sets do as many reps as you can but try to stop when you have 1-2 reps left."
    
        switch wizard.goal {
        case .strength:
            program.styles["Primary"] =   amrapStyle(warmup: "5/0 5/60 3/80 1/90", workset: "5 5 5", rest: "2m")
            program.styles["Secondary"] = amrapStyle(warmup: "5/60 3/80 1/90", workset: "5 5 5", rest: "2m")
            program.styles["Tertiary"] =  variableStyle(warmup: "", workset: "4-8 4-8 4-8", rest: "2m")
        case .glute, .hypertrophy:
            program.styles["Primary"] =   amrapStyle(warmup: "5/0 5/60 3/80 1/90", workset: "8 8 8", rest: "90s")
            program.styles["Secondary"] = amrapStyle(warmup: "5/60 3/80 1/90", workset: "8 8 8", rest: "90s")
            program.styles["Tertiary"] =  variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        case .conditioning:
            fatalError("should be complex")
        }

        if case .glute = wizard.goal {
            appendWorkout1Exercises(program, [
                make("Squat", "High bar Squat", "Primary", weights: "Dual Plates", weight: 85),
                make("Bench Press", "Bench Press", "Primary", weights: "Dual Plates", weight: 65),
                make("Hip Thrust", "Hip Thrust", "Secondary", weights: "Dual Plates", weight: 85),
                make("Row", "Pendlay Row", "Secondary", weights: "Dual Plates", weight: 65),
            ])
            appendWorkout2Exercises(program, [
                make("Deadlift", "Deadlift", "Secondary", weights: "Dual Plates", weight: 95),
                make("OHP", "Overhead Press", "Primary", weights: "Dual Plates", weight: 55),
            ])
            if wizard.machines {
                appendWorkout2Exercises(program, [
                    make("Cable Crunch", "Cable Crunch", "Tertiary", weights: "Cable Machine", weight: 20),
                    make("Lat Pulldown", "Lat Pulldown", "Tertiary", weights: "Cable Machine", weight: 20),
                ])
                disabled.append(contentsOf: ["Row", "Lat Pulldown"])
            } else {
                appendWorkout2Exercises(program, [
                    make("Landmines", "Landmine 180's", "Tertiary", weights: "Dual Plates", weight: 10),
                    make("Chin Ups", "Chin-up", "Tertiary", weights: "Single Plates", weight: 0),
                ])
                disabled.append(contentsOf: ["Row", "Chin Ups"])
            }
        } else {
            appendWorkout1Exercises(program, [
                make("Row", "Pendlay Row", "Secondary", weights: "Dual Plates", weight: 65),
                make("Bench Press", "Bench Press", "Primary", weights: "Dual Plates", weight: 65),
                make("Squat", "High bar Squat", "Primary", weights: "Dual Plates", weight: 85),
                make("Curls", "Barbell Curl", "Tertiary", weights: "Dual Plates", weight: 5),
            ])
            appendWorkout2Exercises(program, [
                make("Chin Ups", "Chin-up", "Tertiary", weights: "Single Plates", weight: 0),
                make("OHP", "Overhead Press", "Primary", weights: "Dual Plates", weight: 55),
                make("Deadlift", "Deadlift", "Secondary", weights: "Dual Plates", weight: 95),
            ])
            if wizard.machines {
                appendWorkout2Exercises(program, [
                    make("Cable Crunch", "Cable Crunch", "Tertiary", weights: "Cable Machine", weight: 20),
                ])
                disabled.append(contentsOf: ["Curls", "Cable Crunch"])
            } else {
                appendWorkout2Exercises(program, [
                    make("Landmines", "Landmine 180's", "Tertiary", weights: "Dual Plates", weight: 10),
                ])
                disabled.append(contentsOf: ["Curls", "Landmines"])
            }
        }
        
        scheduleWorkouts(program)
    }
}

final class BasicSmithBuilder: BaseBasic {
    override func build(_ program: Program) {
        workout1Exercises = []
        workout2Exercises = []
        
        program.summary = "A simple [program](https://thefitness.wiki/routines/r-fitness-basic-beginner-routine) for beginners. It's meant to be run for about three months after which you should switch to an intermediate program. For the last sets do as many reps as you can but try to stop when you have 1-2 reps left."
    
        switch wizard.goal {
        case .strength:
            program.styles["Primary"] =   amrapStyle(warmup: "5/60 3/80 1/90", workset: "5 5 5", rest: "2m")
            program.styles["Tertiary"] =  variableStyle(warmup: "", workset: "4-8 4-8 4-8", rest: "2m")
        case .glute, .hypertrophy:
            program.styles["Primary"] =   amrapStyle(warmup: "5/60 3/80 1/90", workset: "8 8 8", rest: "90s")
            program.styles["Tertiary"] =  variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        case .conditioning:
            fatalError("should be complex")
        }

        if case .glute = wizard.goal {
            if wizard.machines {
                appendWorkout1Exercises(program, [
                    make("Squat", "Smith Machine Squat", "Primary", weights: "Dual Plates", weight: 35),
                    make("Bench Press", "Smith Machine Bench", "Primary", weights: "Dual Plates", weight: 20),
                    make("Hip Thrust", "Hip Thrust", "Primary", weights: "Dual Plates", weight: 85),
                    make("Hip Abduction", "Cable Hip Abduction", "Tertiary", weights: "Cable Machine", weight: 10),
                ])
                appendWorkout2Exercises(program, [
                    make("Deadlift", "Smith Machine Deadlift", "Primary", weights: "Dual Plates", weight: 40),
                    make("Lat Pulldown", "Lat Pulldown", "Tertiary", weights: "Cable Machine", weight: 20),
                    make("Cable Kickback", "One-Legged Cable Kickback", "Tertiary", weights: "Cable Machine", weight: 20),
                    make("Crunches", "Cable Crunch", "Tertiary", weights: "Cable Machine", weight: 10),
                ])
                disabled.append(contentsOf: ["Hip Abduction", "Crunches"])
            } else if wizard.numDumbbells > 5 {
                appendWorkout1Exercises(program, [
                    make("Squat", "Smith Machine Squat", "Primary", weights: "Dual Plates", weight: 35),
                    make("Bench Press", "Smith Machine Bench", "Primary", weights: "Dual Plates", weight: 20),
                    make("Hip Thrust", "Hip Thrust", "Primary", weights: "Dual Plates", weight: 85),
                    make("Hanging Leg Raises", "Hanging Leg Raise", "Secondary"),
                ])
                appendWorkout2Exercises(program, [
                    make("Deadlift", "Smith Machine Deadlift", "Primary", weights: "Dual Plates", weight: 40),
                    make("DB Rows", "Kroc Row", "Primary", weights: "Dumbbells", weight: 30),
                    make("Step-ups", "Step-ups", "Secondary", weights: "Dumbbells", weight: 10),
                ])
                disabled.append(contentsOf: ["Hanging Leg Raises"])
            } else {
                appendWorkout1Exercises(program, [
                    make("Squat", "Smith Machine Squat", "Primary", weights: "Dual Plates", weight: 35),
                    make("Bench Press", "Smith Machine Bench", "Primary", weights: "Dual Plates", weight: 20),
                    make("Hip Thrust", "Hip Thrust", "Primary", weights: "Dual Plates", weight: 85),
                ])
                appendWorkout2Exercises(program, [
                    make("Deadlift", "Smith Machine Deadlift", "Primary", weights: "Dual Plates", weight: 40),
                    make("OHP", "Seated Smith Machine Press", "Primary", weights: "Dual Plates", weight: 20),
                    make("Hanging Leg Raises", "Hanging Leg Raise", "Secondary"),
                ])
            }
        } else {
            if wizard.machines {
                appendWorkout1Exercises(program, [
                    make("Row", "Seated Cable Row", "Primary", weights: "Cable Machine", weight: 25),   // Hip Thrust
                    make("Bench Press", "Smith Machine Bench", "Primary", weights: "Dual Plates", weight: 20),
                    make("Squat", "Smith Machine Squat", "Primary", weights: "Dual Plates", weight: 35),
                    make("Curls", "Cable Hammer Curls", "Tertiary", weights: "Cable Machine", weight: 10),
                ])
                appendWorkout2Exercises(program, [
                    make("Chin Ups", "Chin-up", "Tertiary", weights: "Single Plates", weight: 0),   // lat pulldown
                    make("OHP", "Seated Smith Machine Press", "Primary", weights: "Dual Plates", weight: 20),
                    make("Deadlift", "Smith Machine Deadlift", "Primary", weights: "Dual Plates", weight: 40),
                    make("Crunches", "Cable Crunch", "Tertiary", weights: "Cable Machine", weight: 20),
                ])
                disabled.append(contentsOf: ["Curls", "Crunches"])
            } else if wizard.numDumbbells > 5 {
                appendWorkout1Exercises(program, [
                    make("Bench Press", "Smith Machine Bench", "Primary", weights: "Dual Plates", weight: 20),
                    make("DB Rows", "Kroc Row", "Primary", weights: "Dumbbells", weight: 30),
                    make("Squat", "Smith Machine Squat", "Primary", weights: "Dual Plates", weight: 35),
                    make("Curls", "Concentration Curls", "Tertiary", weights: "Dumbbells", weight: 10),
                ])
                appendWorkout2Exercises(program, [
                    make("OHP", "Seated Smith Machine Press", "Primary", weights: "Dual Plates", weight: 20),
                    make("Chin Ups", "Chin-up", "Tertiary", weights: "Single Plates", weight: 0),
                    make("Deadlift", "Smith Machine Deadlift", "Primary", weights: "Dual Plates", weight: 40),
                    make("Flyes", "Dumbbell Flyes", "Tertiary", weights: "Dumbbells", weight: 10),
                ])
                disabled.append(contentsOf: ["Curls", "Flyes"])
            } else {
                appendWorkout1Exercises(program, [
                    make("Row", "Seated Cable Row", "Primary", weights: "Cable Machine", weight: 25),
                    make("Bench Press", "Smith Machine Bench", "Primary", weights: "Dual Plates", weight: 20),
                    make("Squat", "Smith Machine Squat", "Primary", weights: "Dual Plates", weight: 35),
                ])
                appendWorkout2Exercises(program, [
                    make("Chin Ups", "Chin-up", "Tertiary", weights: "Single Plates", weight: 0),
                    make("OHP", "Seated Smith Machine Press", "Primary", weights: "Dual Plates", weight: 20),
                    make("Deadlift", "Smith Machine Deadlift", "Primary", weights: "Dual Plates", weight: 40),
                ])
            }
        }

        scheduleWorkouts(program)
    }
}

/// Used for strength and glutes
final class BasicStopgapDBBuilder: BaseBasic {
    override init(_ wizard: Wizard) {
        super.init(wizard)
        workout1Name = "A"
        workout2Name = "B"
    }
    
    override func build(_ program: Program) {
        workout1Exercises = []
        workout2Exercises = []
        
        program.summary = "[Designed](https://thefitness.wiki/reddit-archive/dumbbell-stopgap/) for home workouts with a small set of dummbells (or adjustable dumbbells) though it can also be used at a gym."
    
        program.styles["Primary"] =   variableStyle(warmup: "5/60 3/80 1/90", workset: "5-10 5-10 5-10", rest: "60s")
        program.styles["Secondary"] = variableStyle(warmup: "", workset: "5-10 5-10 5-10", rest: "60s")
        program.styles["Durations"] = durationsStyle(secs: "30 30 30", targetSecs: "")

        appendWorkout1Exercises(program, [
            make("Split Squat", "Dumbbell Single Leg Split Squat", "Primary", weights: "Dumbbells", weight: 15),
            make("Bench Press", "Dumbbell Bench Press", "Primary", weights: "Dumbbells", weight: 20),
            make("Deadlift", "Dumbbell Deadlift", "Primary", weights: "Dumbbells", weight: 20),
            make("Plank", "Plank", "Durations"),
        ])
        if case .glute = wizard.goal {
            appendWorkout2Exercises(program, [
                make("Split Squat", "Dumbbell Single Leg Split Squat", "Primary", weights: "Dumbbells", weight: 15),
                make("OHP", "Dumbbell Shoulder Press", "Primary", weights: "Dumbbells", weight: 10),
                make("Step-ups", "Step-ups", "Secondary", weights: "Dumbbells", weight: 10),
                make("Plank", "Plank", "Durations"),
            ])
        } else {
            appendWorkout2Exercises(program, [
                make("Split Squat", "Dumbbell Single Leg Split Squat", "Primary", weights: "Dumbbells", weight: 15),
                make("OHP", "Dumbbell Shoulder Press", "Primary", weights: "Dumbbells", weight: 10),
                make("Row", "Bent Over Dumbbell Row", "Secondary", weights: "Dumbbells", weight: 20),
                make("Plank", "Plank", "Durations"),
            ])
        }

        scheduleWorkouts(program)
    }
}

/// Used for hypertrophy
final class BasicPPLDBBuilder: Builder {
    private var pushExercises: [String] = []
    private var pullExercises: [String] = []
    private var legExercises: [String] = []
        
    override var name: String {return "PPL"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(3), .weekly(6), .cycle(4), .cycle(5)]}

    override func build(_ program: Program) {
        pushExercises = []
        pullExercises = []
        legExercises = []
        
        program.summary = "A Push/Pull/Legs beginner [program](https://thefitness.wiki/reddit-archive/dumbbell-stopgap-ppl/) that requires minimal equipment."
        
        program.styles["Primary"] =   variableStyle(warmup: "5/60 3/80 1/90", workset: "6-12 6-12 6-12", rest: "90s")
        program.styles["Secondary"] = variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        
        appendPushExercises(program, [
            make("Chest Press", "Dumbbell Bench Press", "Primary", weights: "Dumbbells", weight: 25),
            make("Incline Fly", "Dumbbell Incline Flyes", "Secondary", weights: "Dumbbells", weight: 10),
            make("Arnold Press", "Arnold Press", "Secondary", weights: "Dumbbells", weight: 20),
            make("Overhead Tricep Extension", "Standing Triceps Press", "Secondary", weights: "Dumbbells", weight: 15),
        ])
        appendPullExercises(program, [
            make("Pull-ups", "Pull-up", "Secondary", weights: "Dumbbells", weight: 0),
            make("Bent-over Row", "Bent Over Dumbbell Row", "Secondary", weights: "Dumbbells", weight: 20),
            make("Reverse Fly", "Reverse Flyes", "Secondary", weights: "Dumbbells", weight: 10),
            make("Shrug", "Dumbbell Shrug", "Secondary", weights: "Dumbbells", weight: 30),
            make("Bicep Curl", "Concentration Curls", "Secondary", weights: "Dumbbells", weight: 10),
            make("Hanging Leg Raises", "Hanging Leg Raise", "Secondary"),   // TODO supposed to be added to the end of every other workout
        ])
        appendLegExercises(program, [
            make("Goblet Squat", "Goblet Squat", "Primary", weights: "Dumbbells", weight: 30),
            make("Lunge", "Dumbbell Lunge", "Secondary", weights: "Dumbbells", weight: 20),
            make("Deadlift", "Single Leg Dumbbell Deadlift", "Secondary", weights: "Dumbbells", weight: 30),
            make("Calf Raise", "One-Leg DB Calf Raises", "Secondary", weights: "Dumbbells", weight: 40),
        ])
        
        scheduleWorkouts(program)
    }
    
    private func scheduleWorkouts(_ program: Program) {
        switch wizard.schedule {
        case .weekly(let days) where days == 3:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Push", schedule)
            addPushExercises(workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("Pull", schedule)
            addPullExercises(workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Legs", schedule)
            addLegExercises(workout)
            program.addWorkout(workout)
        case .weekly(let days) where days == 6:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Push 1", schedule)
            addPushExercises(workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.tuesday]))
            workout = Workout("Pull 1", schedule)
            addPullExercises(workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("Legs 1", schedule)
            addLegExercises(workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("Push 2", schedule)
            addPushExercises(workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Pull 2", schedule)
            addPullExercises(workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.saturday]))
            workout = Workout("Legs 2", schedule)
            addLegExercises(workout)
            program.addWorkout(workout)
        case .cycle(let days) where days == 4:
            let schedule = Schedule.cyclic
            var workout = Workout("Push", schedule)
            addPushExercises(workout)
            program.addWorkout(workout)
            
            workout = Workout("Pull", schedule)
            addPullExercises(workout)
            program.addWorkout(workout)
            
            workout = Workout("Legs", schedule)
            addLegExercises(workout)
            program.addWorkout(workout)
            
            workout = Workout("Rest", schedule)
            program.addWorkout(workout)
        case .cycle(let days) where days == 5:
            let schedule = Schedule.cyclic
            var workout = Workout("Push", schedule)
            addPushExercises(workout)
            program.addWorkout(workout)
            
            workout = Workout("Pull", schedule)
            addPullExercises(workout)
            program.addWorkout(workout)
            
            workout = Workout("Legs", schedule)
            addLegExercises(workout)
            program.addWorkout(workout)
            
            workout = Workout("Rest 1", schedule)
            program.addWorkout(workout)
            workout = Workout("Rest 2", schedule)
            program.addWorkout(workout)
        default:
            fatalError("\(wizard.schedule) shouldn't have happened")
        }
    }
    
    private func appendPushExercises(_ program: Program, _ exercises: [Exercise]) {
        appendExercises(program, exercises)
        pushExercises.append(contentsOf: exercises.map {$0.name})
    }
    
    private func appendPullExercises(_ program: Program, _ exercises: [Exercise]) {
        appendExercises(program, exercises)
        pullExercises.append(contentsOf: exercises.map {$0.name})
    }
    
    private func appendLegExercises(_ program: Program, _ exercises: [Exercise]) {
        appendExercises(program, exercises)
        legExercises.append(contentsOf: exercises.map {$0.name})
    }
    
    private func addPushExercises(_ workout: Workout) {
        for name in pushExercises {
            workout.addExercise(name: name)
        }
    }
    
    private func addPullExercises(_ workout: Workout) {
        for name in pullExercises {
            workout.addExercise(name: name)
        }
    }
    
    private func addLegExercises(_ workout: Workout) {
        for name in legExercises {
            workout.addExercise(name: name)
        }
    }
}

final class BasicMachineBuilder: BaseBasic {
    override init(_ wizard: Wizard) {
        super.init(wizard)
        workout1Name = "Leg Press"
        workout2Name = "Pull Through"
    }
    
    override func build(_ program: Program) {
        workout1Exercises = []
        workout2Exercises = []
        
        program.summary = "Beginner machine centric program."
    
        program.styles["Primary"] =   variableStyle(warmup: "5/60 3/80 1/90", workset: "5-10 5-10 5-10", rest: "2m")
        program.styles["Secondary"] = variableStyle(warmup: "", workset: "5-10 5-10 5-10", rest: "2m")

        // This is used if there is no other apparatus so all these exercises should be restricted to machines.
        if case .glute = wizard.goal {
            appendWorkout1Exercises(program, [
                make("Leg Press", "Leg Press", "Primary", weights: "Dual Plates", weight: 35),
                make("Chest Press", "Chest Press machine", "Primary", weights: "Dual Plates", weight: 20),
                make("Leg Curl", "Seated Leg Curl", "Secondary", weights: "Cable Machine", weight: 20),
                make("Hip Abduction", "Cable Hip Abduction", "Secondary", weights: "Cable Machine", weight: 10),
            ])
            appendWorkout2Exercises(program, [
                make("Pull-Through", "Pull Through", "Primary", weights: "Cable Machine", weight: 15),
                make("Shoulder Press", "Machine Shoulder Press", "Primary", weights: "Dual Plates", weight: 10),
                make("Cable Kickback", "One-Legged Cable Kickback", "Secondary", weights: "Cable Machine", weight: 20),
                make("Seated Row", "Seated Cable Row", "Secondary", weights: "Cable Machine", weight: 20),
            ])
            disabled.append(contentsOf: ["Hip Abduction", "Seated Row"])
        } else {
            appendWorkout1Exercises(program, [
                make("Leg Press", "Leg Press", "Primary", weights: "Dual Plates", weight: 35),
                make("Chest Press", "Chest Press machine", "Primary", weights: "Dual Plates", weight: 20),
                make("Seated Row", "Seated Cable Row", "Secondary", weights: "Cable Machine", weight: 20),
                make("Curls", "Cable Hammer Curls", "Secondary", weights: "Cable Machine", weight: 10),
            ])
            appendWorkout2Exercises(program, [
                make("Pull-Through", "Pull Through", "Primary", weights: "Cable Machine", weight: 15),
                make("Shoulder Press", "Machine Shoulder Press", "Primary", weights: "Dual Plates", weight: 10),
                make("Chin Ups", "Chin-up", "Secondary", weights: "Dumbbells", weight: 0),
                make("Crunches", "Cable Crunch", "Secondary", weights: "Cable Machine", weight: 20),
            ])
            disabled.append(contentsOf: ["Curls", "Crunches"])
        }

        scheduleWorkouts(program)
    }
}

final class ComplexBuilder: Builder {
    override var name: String {return "Complex"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(1), .weekly(2), .weekly(3), .cycle(2), .cycle(3)]}

    override func build(_ program: Program) {
        program.summary = "[Complexes](https://lipsticklifters.com/articles/dumbbell-complex/) are a blend between cardio and weight lifting. The idea is that you peform a set of exercises with a fixed weight without resting or setting the weight down, do a short rest, and repeat. Unless you are in great shape this will quickly get intense so start with a weight much lighter than what you can do for one of the exercises."
    
        // Styles
        program.styles["Complex"] = manualStyle(warmup: "", workset: "1 1 1", rest: "90s")

        // Exercises
        let exercise = if case .beginner = wizard.fitness {
            make("Complex", "Complex - beginner", "Complex", weights: "Dumbbells", weight: 5)
        } else {
            make("Complex", "Complex - intermediate", "Complex", weights: "Dumbbells", weight: 10)
        }
        program.exercises.append(exercise)
    
        switch wizard.schedule {
        case .weekly(let days) where days == 1:
            let schedule = Schedule.days(Weekdays([.monday]))
            let workout = Workout("Complex", schedule)
            workout.addExercise(name: "Complex")
            program.addWorkout(workout)
        case .weekly(let days) where days == 2:
            let schedule = Schedule.days(Weekdays([.monday, .thursday]))
            let workout = Workout("Complex", schedule)
            workout.addExercise(name: "Complex")
            program.addWorkout(workout)
        case .weekly(let days) where days == 3:
            let schedule = Schedule.days(Weekdays([.monday, .wednesday, .friday]))
            let workout = Workout("Complex", schedule)
            workout.addExercise(name: "Complex")
            program.addWorkout(workout)
        case .cycle(let days) where days == 2:
            let schedule = Schedule.cyclic
            var workout = Workout("Complex", schedule)
            workout.addExercise(name: "Complex")
            program.addWorkout(workout)

            workout = Workout("Rest", schedule)
            program.addWorkout(workout)
        case .cycle(let days) where days == 3:
            let schedule = Schedule.cyclic
            var workout = Workout("Complex", schedule)
            workout.addExercise(name: "Complex")
            program.addWorkout(workout)

            workout = Workout("Rest 1", schedule)
            program.addWorkout(workout)
            workout = Workout("Rest 2", schedule)
            program.addWorkout(workout)
        default:
            fatalError("\(wizard.schedule) shouldn't have happened")
        }
    }
}

// TODO for bodyweight use
// https://www.reddit.com/r/bodyweightfitness/wiki/index/?utm_source=reddit&utm_medium=usertext&utm_name=bodyweightfitness&utm_content=t5_2tf0a
// may want to add a Progression style

// TODO get rid of this once we handle all the cases
final class StubBuilder: Builder {
    override var name: String {return "Not implemented"}
    
    override var schedules: [Wizard.Schedule] {return []}

    override func build(_ program: Program) {
        program.summary = "Place holder until we can handle this case."
        let workout = Workout("Workout", Schedule.days(Weekdays([.monday])))
        program.addWorkout(workout)
    }
}
