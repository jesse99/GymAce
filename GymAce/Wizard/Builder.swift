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
    
    fileprivate func addExercise(_ program: Program, _ workout: Workout, _ exercise: Exercise, enabled: Bool = true) {
        if exercise.name.lowercased().contains("db ") || exercise.name.lowercased().contains("dumbbell") {
            assert(exercise.weightSet! == "Dumbbells")
        } else if exercise.name.lowercased().contains("smith ") {
            assert(exercise.weightSet! == "Smith Machine")
        } else if exercise.name.lowercased().contains("machine ") {
            assert(exercise.weightSet! == "Dual Plates Machine")
        }

        if program.findExercise(exercise.name) == nil {
            program.exercises.append(exercise)
        }
        workout.addExercise(name: exercise.name, enabled: enabled)
    }
    
    fileprivate func addGroup(_ program: Program, _ workout: Workout, _ inExercises: (String, [Exercise]), enabled: Bool = true) {
        let group = inExercises.0
        let exercises = inExercises.1
        for (i, e) in exercises.enumerated() {
            assert(exercises.count(where: {$0.name == e.name}) == 1)    // names in a group must be unique
            addExercise(program, workout, e, enabled: enabled && i == 0)
            workout.entries.last!.group = group
        }
    }

    fileprivate func initGroups(_ program: Program) {
        var groups: [String: [String]] = [:]
        
        for w in program.workouts {
            for e in w.entries {
                if let group = e.group {
                    var a = groups[group, default: []]
                    if !a.contains(e.name) {
                        a.append(e.name)
                        groups[group] = a
                    }
                }
            }
        }
        
        if !groups.isEmpty {
            program.groups = groups
        } else {
            program.groups = nil
        }
    }
        
    fileprivate func makeSquat(_ primary: String) -> (String, [Exercise]) {
        let exercises = if !wizard.male {
            [make("High Bar Squat", "High bar Squat", "Primary", weights: "Dual Plates", weight: 45 + 2*10),
             make("Low Bar Squat", "Low bar Squat", "Primary", weights: "Dual Plates", weight: 45 + 2*10),
             make("Front Squat", "Front Squat", "Primary", weights: "Dual Plates", weight: 45 + 2*10),
             make("Smith Squat", "Smith Machine Squat", "Primary", weights: "Smith Machine", weight: 2*20),
             make("Split Squat", "DB Split Squat", "Primary", weights: "Dumbbells", weight: 10),
             make("Goblet Squat", "DB Goblet Squat", "Primary", weights: "Dumbbells", weight: 30),
             make("Leg Press", "Leg Press", "Primary", weights: "Dual Plates Machine", weight: 2*30)]
        } else {
            [make("High Bar Squat", "High bar Squat", "Primary", weights: "Dual Plates", weight: 45 + 2*20),
             make("Low Bar Squat", "Low bar Squat", "Primary", weights: "Dual Plates", weight: 45 + 2*20),
             make("Front Squat", "Front Squat", "Primary", weights: "Dual Plates", weight: 45 + 2*20),
             make("Smith Squat", "Smith Machine Squat", "Primary", weights: "Smith Machine", weight: 2*25),
             make("Split Squat", "DB Split Squat", "Primary", weights: "Dumbbells", weight: 20),
             make("Goblet Squat", "DB Goblet Squat", "Primary", weights: "Dumbbells", weight: 40),
             make("Leg Press", "Leg Press", "Primary", weights: "Dual Plates", weight: 2*45)]
        }
        assert(exercises.contains(where: {$0.name == primary}))
        return ("Squat", exercises.sorted(by: {$0.name == primary || $0.name < $1.name}))
    }
    
    fileprivate func makeDeadlift(_ primary: String) -> (String, [Exercise]) {
        let exercises = if !wizard.male {[
            make("American Deadlift", "Deadlift", "Secondary", weights: "Dual Plates", weight: 45 + 2*25),
            make("Romanian Deadlift", "Romanian Deadlift", "Secondary", weights: "Dual Plates", weight: 45 + 2*25),
            make("Stiff-Legged Deadlift", "Stiff-Legged Deadlift", "Secondary", weights: "Dual Plates", weight: 45 + 2*25),
            make("Sumo Deadlift", "Sumo Deadlift", "Secondary", weights: "Dual Plates", weight: 45 + 2*25),
            make("Trap Bar Deadlift", "Trap Bar Deadlift", "Secondary", weights: "Dual Plates", weight: 45 + 2*25),
            make("Dumbbell Deadlift", "Dumbbell Deadlift", "Secondary", weights: "Dumbbells", weight: 25),
            make("Dumbbell Romanian Deadlift", "Dumbbell Romanian Deadlift", "Secondary", weights: "Dumbbells", weight: 25),
            make("Single Leg Dumbbell Deadlift", "Single Leg Dumbbell Deadlift", "Secondary", weights: "Dumbbells", weight: 20),
            make("Cable Pull Through", "Cable Pull Through", "Tertiary", weights: "Cable Machine", weight: 20),
            make("Smith Deadlift", "Smith Machine Deadlift", "Secondary", weights: "Smith Machine", weight: 2*30),
            make("Smith Romanian Deadlift", "Smith Machine Romanian Deadlift", "Secondary", weights: "Smith Machine", weight: 2*30),
            make("Back Extension", "Back Extension", "Tertiary", weights: "Single Plates", weight: 0),
        ]} else {[
            make("American Deadlift", "Deadlift", "Secondary", weights: "Dual Plates", weight: 45 + 2*45),
            make("Romanian Deadlift", "Romanian Deadlift", "Secondary", weights: "Dual Plates", weight: 45 + 2*45),
            make("Stiff-Legged Deadlift", "Stiff-Legged Deadlift", "Secondary", weights: "Dual Plates", weight: 45 + 2*45),
            make("Sumo Deadlift", "Sumo Deadlift", "Secondary", weights: "Dual Plates", weight: 45 + 2*45),
            make("Trap Bar Deadlift", "Trap Bar Deadlift", "Secondary", weights: "Dual Plates", weight: 45 + 2*45),
            make("Dumbbell Deadlift", "Dumbbell Deadlift", "Secondary", weights: "Dumbbells", weight: 40),
            make("Dumbbell Romanian Deadlift", "Dumbbell Romanian Deadlift", "Secondary", weights: "Dumbbells", weight: 40),
            make("Single Leg Dumbbell Deadlift", "Single Leg Dumbbell Deadlift", "Secondary", weights: "Dumbbells", weight: 25),
            make("Cable Pull Through", "Cable Pull Through", "Tertiary", weights: "Cable Machine", weight: 25),
            make("Smith Deadlift", "Smith Machine Deadlift", "Secondary", weights: "Smith Machine", weight: 2*45),
            make("Smith Romanian Deadlift", "Smith Machine Romanian Deadlift", "Secondary", weights: "Smith Machine", weight: 2*45),
            make("Back Extension", "Back Extension", "Tertiary", weights: "Single Plates", weight: 10),
        ]}
        assert(exercises.contains(where: {$0.name == primary}))
        return ("Deadlift", exercises.sorted(by: {$0.name == primary || $0.name < $1.name}))
    }
    
    fileprivate func makeBench(_ primary: String) -> (String, [Exercise]) {
        let exercises = if !wizard.male {[
            make("Bench Press", "Incline Bench Press", "Primary", weights: "Dual Plates", weight: 45 + 2*5),
            make("Incline Bench Press", "Incline Bench Press", "Primary", weights: "Dual Plates", weight: 45 + 2*5),
            make("Dumbbell Bench Press", "Dumbbell Bench Press", "Secondary", weights: "Dumbbells", weight: 15),
            make("Dumbbell Incline Press", "Dumbbell Incline Press", "Secondary", weights: "Dumbbells", weight: 10),
            make("Chest Press Machine", "Chest Press Machine", "Secondary", weights: "Dual Plates Machine", weight: 2*20),
            make("Smith Bench", "Smith Machine Bench", "Secondary", weights: "Smith Machine", weight: 2*15),
            make("Dumbbell Flyes", "Dumbbell Flyes", "Tertiary", weights: "Dumbbells", weight: 5),
        ]} else {[
            make("Bench Press", "Incline Bench Press", "Primary", weights: "Dual Plates", weight: 45 + 2*10),
            make("Incline Bench Press", "Incline Bench Press", "Primary", weights: "Dual Plates", weight: 45 + 2*10),
            make("Dumbbell Bench Press", "Dumbbell Bench Press", "Secondary", weights: "Dumbbells", weight: 25),
            make("Dumbbell Incline Press", "Dumbbell Incline Press", "Secondary", weights: "Dumbbells", weight: 30),
            make("Chest Press Machine", "Chest Press Machine", "Secondary", weights: "Dual Plates Machine", weight: 2*30),
            make("Smith Bench", "Smith Machine Bench", "Secondary", weights: "Smith Machine", weight: 2*20),
            make("Dumbbell Flyes", "Dumbbell Flyes", "Tertiary", weights: "Dumbbells", weight: 5),
        ]}
        assert(exercises.contains(where: {$0.name == primary}))
        return ("Bench", exercises.sorted(by: {$0.name == primary || $0.name < $1.name}))
    }
    
    fileprivate func makeOHP(_ primary: String) -> (String, [Exercise]) {   //
        let exercises = if !wizard.male {[
            make("Overhead Press", "Overhead Press", "Primary", weights: "Dual Plates", weight: 45 + 2*0),
            make("Dumbbell Shoulder Press", "Dumbbell Shoulder Press", "Secondary", weights: "Dumbbells", weight: 10),
            make("Machine Shoulder Press", "Machine Shoulder Press", "Secondary", weights: "Dual Plates Machine", weight: 2*10),
            make("Dumbbell Arnold Press", "Dumbbell Arnold Press", "Secondary", weights: "Dumbbells", weight: 5),
            make("Seated Smith Press", "Seated Smith Machine Press", "Secondary", weights: "Smith Machine", weight: 2*10),
            make("Landmine Press", "Landmine Press", "Secondary", weights: "Single Plates", weight: 10),
        ]} else {[
            make("Overhead Press", "Overhead Press", "Primary", weights: "Dual Plates", weight: 45 + 2*10),
            make("Dumbbell Shoulder Press", "Dumbbell Shoulder Press", "Secondary", weights: "Dumbbells", weight: 20),
            make("Machine Shoulder Press", "Machine Shoulder Press", "Secondary", weights: "Dual Plates Machine", weight: 2*20),
            make("Dumbbell Arnold Press", "Dumbbell Arnold Press", "Secondary", weights: "Dumbbells", weight: 15),
            make("Seated Smith Press", "Seated Smith Machine Press", "Secondary", weights: "Smith Machine", weight: 2*20),
            make("Landmine Press", "Landmine Press", "Secondary", weights: "Single Plates", weight: 20),
        ]}
        assert(exercises.contains(where: {$0.name == primary}))
        return ("OHP", exercises.sorted(by: {$0.name == primary || $0.name < $1.name}))
    }
    
    fileprivate func makeRow(_ primary: String) -> (String, [Exercise]) {
        let exercises = if !wizard.male {[
            make("Pendlay Row", "Pendlay Row", "Secondary", weights: "Dual Plates", weight: 45 + 2*5),
            make("Chest Supported Row", "Chest Supported Row", "Secondary", weights: "Dumbbells", weight: 15),
            make("Kroc Row", "Kroc Row", "Primary", weights: "Dumbbells", weight: 20),
            make("Bent Over Dumbbell Row", "Bent Over Dumbbell Row", "Secondary", weights: "Dumbbells", weight: 20),
            make("Seated Cable Row", "Seated Cable Row", "Secondary", weights: "Cable Machine", weight: 25),
            make("Standing One Arm Cable Row", "Standing One Arm Cable Row", "Secondary", weights: "Cable Machine", weight: 15),
            make("Smith Bent-Over Row", "Smith Machine Bent-Over Row", "Secondary", weights: "Smith Machine", weight: 2*10),
            make("T-Bar Row", "T-Bar Row", "Secondary", weights: "Single Plates", weight: 25),
        ]} else {[
            make("Pendlay Row", "Pendlay Row", "Secondary", weights: "Dual Plates", weight: 45 + 2*20),
            make("Chest Supported Row", "Chest Supported Row", "Secondary", weights: "Dumbbells", weight: 25),
            make("Kroc Row", "Kroc Row", "Secondary", weights: "Dumbbells", weight: 30),
            make("Bent Over Dumbbell Row", "Bent Over Dumbbell Row", "Secondary", weights: "Dumbbells", weight: 25),
            make("Seated Cable Row", "Seated Cable Row", "Secondary", weights: "Cable Machine", weight: 40),
            make("Standing One Arm Cable Row", "Standing One Arm Cable Row", "Secondary", weights: "Cable Machine", weight: 20),
            make("Smith Bent-Over Row", "Smith Machine Bent-Over Row", "Secondary", weights: "Smith Machine", weight: 2*20),
            make("T-Bar Row", "T-Bar Row", "Secondary", weights: "Single Plates", weight: 30),
        ]}
        assert(exercises.contains(where: {$0.name == primary}))
        return ("Row", exercises.sorted(by: {$0.name == primary || $0.name < $1.name}))
    }

    fileprivate func makeAbs(_ primary: String) -> (String, [Exercise]) {
        let exercises = if !wizard.male {[
            make("Cable Crunch", "Cable Crunch", "Tertiary", weights: "Cable Machine", weight: 10),
            make("Ab Wheel Rollout", "Ab Wheel Rollout", "Tertiary", weights: "Single Plates", weight: 0),  // variable style so need a weight...
            make("Plank", "Plank", "Plank"),
            make("Decline Situp", "Decline Situp", "Tertiary", weights: "Single Plates", weight: 0),
            make("Hanging Leg Raise", "Hanging Leg Raise", "Tertiary", weights: "Single Plates", weight: 0),
            make("Landmines", "Landmine 180's", "Tertiary", weights: "Single Plates", weight: 10),
        ]} else {[
            make("Cable Crunch", "Cable Crunch", "Tertiary", weights: "Cable Machine", weight: 15),
            make("Ab Wheel Rollout", "Ab Wheel Rollout", "Tertiary", weights: "Single Plates", weight: 0),
            make("Plank", "Plank", "Plank"),
            make("Decline Situp", "Decline Situp", "Tertiary", weights: "Single Plates", weight: 0),
            make("Hanging Leg Raise", "Hanging Leg Raise", "Tertiary", weights: "Single Plates", weight: 0),
            make("Landmine 180's", "Landmine 180's", "Tertiary", weights: "Single Plates", weight: 20),
        ]}
        assert(exercises.contains(where: {$0.name == primary}))
        return ("Abs", exercises.sorted(by: {$0.name == primary || $0.name < $1.name}))
    }

    fileprivate func makePullup(_ primary: String) -> (String, [Exercise]) {
        let exercises = if !wizard.male {[
            make("Chin-up", "Chin-up", "Tertiary", weights: "Single Plates", weight: 0),
            make("Pull-up", "Pull-up", "Tertiary", weights: "Single Plates", weight: 0),
            make("Lat Pulldown", "Lat Pulldown", "Tertiary", weights: "Cable Machine", weight: 20),
        ]} else {[
            make("Chin-up", "Chin-up", "Tertiary", weights: "Single Plates", weight: 0),
            make("Pull-up", "Pull-up", "Tertiary", weights: "Single Plates", weight: 0),
            make("Lat Pulldown", "Lat Pulldown", "Tertiary", weights: "Cable Machine", weight: 40),
        ]}
        assert(exercises.contains(where: {$0.name == primary}))
        return ("Pullup", exercises.sorted(by: {$0.name == primary || $0.name < $1.name}))
    }

    fileprivate func makeCurl(_ primary: String) -> (String, [Exercise]) {
        let exercises = if !wizard.male {[
            make("Barbell Curl", "Barbell Curl", "Tertiary", weights: "Dual Plates", weight: 0),
            make("Concentration Curls", "Concentration Curls", "Tertiary", weights: "Dumbbells", weight: 10),
            make("Cable Hammer Curls", "Cable Hammer Curls", "Tertiary", weights: "Cable Machine", weight: 10),
        ]} else {[
            make("Barbell Curl", "Barbell Curl", "Tertiary", weights: "Dual Plates", weight: 5),
            make("Concentration Curls", "Concentration Curls", "Tertiary", weights: "Dumbbells", weight: 20),
            make("Cable Hammer Curls", "Cable Hammer Curls", "Tertiary", weights: "Cable Machine", weight: 20),
        ]}
        assert(exercises.contains(where: {$0.name == primary}))
        return ("Curl", exercises.sorted(by: {$0.name == primary || $0.name < $1.name}))
    }
}

class BaseBasic: Builder {
    fileprivate var workout1Name: String = "Squat"
    fileprivate var workout2Name: String = "Deadlift"

    override init(_ wizard: Wizard) {
        super.init(wizard)
    }
    
    override var name: String {return "Basic"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(2), .weekly(3), .weekly(4), .cycle(4), .cycle(6)]}

    override func build(_ program: Program) {
        setup(program)
        scheduleWorkouts(program)
        initGroups(program)
    }
    
    func setup(_ program: Program) {
        fatalError("override this")
    }

    func buildWorkout1(_ p: Program, _ w: Workout) {
        fatalError("override this")
    }
    
    func buildWorkout2(_ p: Program, _ w: Workout) {
        fatalError("override this")
    }

    fileprivate func scheduleWorkouts(_ program: Program) {
        switch wizard.schedule {
        case .weekly(let days) where days == 2:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout(workout1Name, schedule)
            buildWorkout1(program, workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout(workout2Name, schedule)
            buildWorkout2(program, workout)
            program.addWorkout(workout)
        case .weekly(let days) where days == 3:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("\(workout1Name) 1a", schedule)
            buildWorkout1(program, workout)
            workout.weeks = 1...1
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("\(workout2Name) 1", schedule)
            buildWorkout2(program, workout)
            workout.weeks = 1...1
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("\(workout1Name) 1b", schedule)
            buildWorkout1(program, workout)
            workout.weeks = 1...1
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.monday]))
            workout = Workout("\(workout2Name) 2a", schedule)
            buildWorkout2(program, workout)
            workout.weeks = 2...2
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("\(workout1Name) 2", schedule)
            buildWorkout1(program, workout)
            workout.weeks = 2...2
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("\(workout2Name) 2b", schedule)
            buildWorkout2(program, workout)
            workout.weeks = 2...2
            program.addWorkout(workout)
        case .weekly(let days) where days == 4:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("\(workout1Name) 1", schedule)
            buildWorkout1(program, workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.tuesday]))
            workout = Workout("\(workout2Name) 1", schedule)
            buildWorkout2(program, workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("\(workout1Name) 2", schedule)
            buildWorkout1(program, workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("\(workout2Name) 2", schedule)
            buildWorkout2(program, workout)
            program.addWorkout(workout)
        case .cycle(let days) where days == 4:
            let schedule = Schedule.cyclic
            var workout = Workout(workout1Name, schedule)
            buildWorkout1(program, workout)
            program.addWorkout(workout)

            workout = Workout("Rest 1", schedule)
            program.addWorkout(workout)

            workout = Workout(workout2Name, schedule)
            buildWorkout2(program, workout)
            program.addWorkout(workout)

            workout = Workout("Rest 2", schedule)
            program.addWorkout(workout)
        case .cycle(let days) where days == 6:
            let schedule = Schedule.cyclic
            var workout = Workout(workout1Name, schedule)
            buildWorkout1(program, workout)
            program.addWorkout(workout)

            workout = Workout("Rest 1a", schedule)
            program.addWorkout(workout)
            workout = Workout("Rest 1b", schedule)
            program.addWorkout(workout)

            workout = Workout(workout2Name, schedule)
            buildWorkout2(program, workout)
            program.addWorkout(workout)

            workout = Workout("Rest 2a", schedule)
            program.addWorkout(workout)
            workout = Workout("Rest 2b", schedule)
            program.addWorkout(workout)
        default:
            fatalError("\(wizard.schedule) shouldn't have happened")
        }
    }
}

final class BasicBarbellBuilder: BaseBasic {
    override func setup(_ program: Program) {
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
        program.styles["Plank"]     = durationsStyle(secs: "30 30 30", targetSecs: "")
    }

    override func buildWorkout1(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeSquat("High Bar Squat"))
        addGroup(p, w, makeBench("Bench Press"))
        if case .glute = wizard.goal {
            addExercise(p, w, make("Hip Thrust", "Hip Thrust", "Secondary", weights: "Dual Plates", weight: 85))
            addGroup(p, w, makeRow("Pendlay Row"), enabled: false)
        } else {
            addGroup(p, w, makeRow("Pendlay Row"))
            addGroup(p, w, makeCurl("Barbell Curl"), enabled: false)
        }
    }
    
    override func buildWorkout2(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeDeadlift("American Deadlift"))
        addGroup(p, w, makeOHP("Overhead Press"))
        if case .glute = wizard.goal {
            if wizard.machines {
                addGroup(p, w, makeAbs("Cable Crunch"))
                addGroup(p, w, makePullup("Lat Pulldown"), enabled: false)
            } else {
                addGroup(p, w, makeAbs("Landmine 180's"))
                addGroup(p, w, makePullup("Chin-up"), enabled: false)
            }
        } else {
            addGroup(p, w, makePullup("Chin-up"))
            if wizard.machines {
                addGroup(p, w, makeAbs("Cable Crunch"), enabled: false)
            } else {
                addGroup(p, w, makeAbs("Landmine 180's"), enabled: false)
            }
        }
    }
}

final class BasicSmithBuilder: BaseBasic {
    override func setup(_ program: Program) {
        program.summary = "A simple [program](https://thefitness.wiki/routines/r-fitness-basic-beginner-routine) for beginners. It's meant to be run for about three months after which you should switch to an intermediate program. For the last sets do as many reps as you can but try to stop when you have 1-2 reps left."
    
        switch wizard.goal {
        case .strength:
            program.styles["Primary"]   = amrapStyle(warmup: "5/0 5/60 3/80 1/90", workset: "5 5 5", rest: "2m")
            program.styles["Secondary"] = amrapStyle(warmup: "5/60 3/80 1/90", workset: "5 5 5", rest: "2m")
            program.styles["Tertiary"]  = variableStyle(warmup: "", workset: "4-8 4-8 4-8", rest: "2m")
        case .glute, .hypertrophy:
            program.styles["Primary"]  =  amrapStyle(warmup: "5/0 5/60 3/80 1/90", workset: "8 8 8", rest: "90s")
            program.styles["Secondary"] = amrapStyle(warmup: "5/60 3/80 1/90", workset: "8 8 8", rest: "90s")
            program.styles["Tertiary"]  = variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        case .conditioning:
            fatalError("should be complex")
        }
        program.styles["Plank"]     = durationsStyle(secs: "30 30 30", targetSecs: "")
    }

    override func buildWorkout1(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeSquat("Smith Squat"))
        addGroup(p, w, makeBench("Smith Bench"))
        if case .glute = wizard.goal {
            addExercise(p, w, make("Hip Thrust", "Hip Thrust", "Secondary", weights: "Dual Plates", weight: 85))
            if wizard.machines {
                addExercise(p, w, make("Hip Abduction", "Cable Hip Abduction", "Tertiary", weights: "Cable Machine", weight: 10))
            } else {
                addGroup(p, w, makeAbs("Hanging Leg Raise"))
            }
        } else {
            if wizard.machines {
                addGroup(p, w, makeRow("Seated Cable Row"))
                addGroup(p, w, makeCurl("Cable Hammer Curls"))
            } else if wizard.fullDumbbells {
                addGroup(p, w, makeRow("DB Kroc Row"))
                addGroup(p, w, makeCurl("Concentration Curls"))
            } else {
                addGroup(p, w, makeRow("Seated Cable Row"))
            }
        }
    }
    
    override func buildWorkout2(_ p: Program, _ w: Workout) {
        if case .glute = wizard.goal {
            addGroup(p, w, makeDeadlift("Smith Deadlift"))
            if wizard.machines {
                addGroup(p, w, makePullup("Lat Pulldown"))
                addExercise(p, w, make("Cable Kickback", "One-Legged Cable Kickback", "Tertiary", weights: "Cable Machine", weight: 20))
                addGroup(p, w, makeAbs("Hanging Leg Raise"), enabled: false)
            } else if wizard.fullDumbbells {
                addGroup(p, w, makeRow("Kroc Row"))
                addExercise(p, w, make("Step-ups", "Step-ups", "Tertiary", weights: "Dumbbells", weight: 10))
                addGroup(p, w, makeAbs("Hanging Leg Raise"), enabled: false)
            } else {
                addGroup(p, w, makeOHP("Seated Smith Press"))
                addGroup(p, w, makeAbs("Hanging Leg Raise"))
            }
        } else {
            addGroup(p, w, makePullup("Chin-up"))
            addGroup(p, w, makeOHP("Seated Smith Press"))
            addGroup(p, w, makeDeadlift("Smith Deadlift"))
            if wizard.machines {
                addGroup(p, w, makeAbs("Cable Crunch"), enabled: false)
            } else if wizard.fullDumbbells {
                addGroup(p, w, makeBench("Dumbbell Flyes"), enabled: false)
            }
        }
    }
}

/// Used for strength and glutes
final class BasicStopgapDBBuilder: BaseBasic {
    override init(_ wizard: Wizard) {
        super.init(wizard)
        workout1Name = "A"
        workout2Name = "B"
    }
    
    override func setup(_ program: Program) {
        program.summary = "[Designed](https://thefitness.wiki/reddit-archive/dumbbell-stopgap/) for home workouts with a small set of dummbells (or adjustable dumbbells) though it can also be used at a gym."
    
        program.styles["Primary"]   = variableStyle(warmup: "5/0 5/60 3/80 1/90", workset: "5-10 5-10 5-10", rest: "60s")
        program.styles["Secondary"] = variableStyle(warmup: "5/60 3/80 1/90", workset: "5-10 5-10 5-10", rest: "60s")
        program.styles["Tertiary"]  = variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        program.styles["Plank"]     = durationsStyle(secs: "30 30 30", targetSecs: "")
    }

    override func buildWorkout1(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeSquat("Split Squat"))
        addGroup(p, w, makeBench("Dumbbell Bench Press"))
        addGroup(p, w, makeDeadlift("Dumbbell Deadlift"))
        addExercise(p, w, make("Plank", "Plank", "Plank"))
    }
    
    override func buildWorkout2(_ p: Program, _ w: Workout) {
        if case .glute = wizard.goal {
            addGroup(p, w, makeSquat("Split Squat"))
            addGroup(p, w, makeOHP("Dumbbell Shoulder Press"))
            addExercise(p, w, make("Step-ups", "Step-ups", "Tertiary", weights: "Dumbbells", weight: 10))
            addExercise(p, w, make("Plank", "Plank", "Plank"))
        } else {
            addGroup(p, w, makeSquat("Split Squat"))
            addGroup(p, w, makeOHP("Dumbbell Shoulder Press"))
            addGroup(p, w, makeRow("Bent Over Dumbbell Row"))
            addExercise(p, w, make("Plank", "Plank", "Plank"))
        }
    }
}

/// Used for hypertrophy
final class BasicPPLDBBuilder: Builder {
    override var name: String {return "PPL"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(3), .weekly(6), .cycle(4), .cycle(5)]}

    override func build(_ program: Program) {
        program.summary = "A Push/Pull/Legs beginner [program](https://thefitness.wiki/reddit-archive/dumbbell-stopgap-ppl/) that requires minimal equipment."
        
        program.styles["Primary"]   = variableStyle(warmup: "5/0 5/60 3/80 1/90", workset: "6-12 6-12 6-12", rest: "90s")
        program.styles["Secondary"] = variableStyle(warmup: "5/60 3/80 1/90", workset: "6-12 6-12 6-12", rest: "90s")
        program.styles["Tertiary"]  = variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        
        scheduleWorkouts(program)
        initGroups(program)
    }
    
    private func scheduleWorkouts(_ program: Program) {
        switch wizard.schedule {
        case .weekly(let days) where days == 3:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Push", schedule)
            buildPushWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("Pull", schedule)
            buildPullWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Legs", schedule)
            buildLegWorkout(program, workout)
            program.addWorkout(workout)
        case .weekly(let days) where days == 6:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Push 1", schedule)
            buildPushWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.tuesday]))
            workout = Workout("Pull 1", schedule)
            buildPullWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("Legs 1", schedule)
            buildLegWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("Push 2", schedule)
            buildPushWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Pull 2", schedule)
            buildPullWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.saturday]))
            workout = Workout("Legs 2", schedule)
            buildLegWorkout(program, workout)
            program.addWorkout(workout)
        case .cycle(let days) where days == 4:
            let schedule = Schedule.cyclic
            var workout = Workout("Push", schedule)
            buildPushWorkout(program, workout)
            program.addWorkout(workout)
            
            workout = Workout("Pull", schedule)
            buildPullWorkout(program, workout)
            program.addWorkout(workout)
            
            workout = Workout("Legs", schedule)
            buildLegWorkout(program, workout)
            program.addWorkout(workout)
            
            workout = Workout("Rest", schedule)
            program.addWorkout(workout)
        case .cycle(let days) where days == 5:
            let schedule = Schedule.cyclic
            var workout = Workout("Push", schedule)
            buildPushWorkout(program, workout)
            program.addWorkout(workout)
            
            workout = Workout("Pull", schedule)
            buildPullWorkout(program, workout)
            program.addWorkout(workout)
            
            workout = Workout("Legs", schedule)
            buildLegWorkout(program, workout)
            program.addWorkout(workout)
            
            workout = Workout("Rest 1", schedule)
            program.addWorkout(workout)
            workout = Workout("Rest 2", schedule)
            program.addWorkout(workout)
        default:
            fatalError("\(wizard.schedule) shouldn't have happened")
        }
    }
    
    private func buildPushWorkout(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeBench("Dumbbell Bench Press"))
        addExercise(p, w, make("Incline Fly", "Dumbbell Incline Flyes", "Tertiary", weights: "Dumbbells", weight: 10))
        addGroup(p, w, makeOHP("Dumbbell Arnold Press"))
        addExercise(p, w, make("Overhead Tricep Extension", "Standing Triceps Press", "Tertiary", weights: "Dumbbells", weight: 15))
    }
    
    private func buildPullWorkout(_ p: Program, _ w: Workout) {
        addGroup(p, w, makePullup("Pull-up"))
        addGroup(p, w, makeRow("Bent Over Dumbbell Row"))
        addExercise(p, w, make("Reverse Fly", "Reverse Flyes", "Tertiary", weights: "Dumbbells", weight: 10))
        addExercise(p, w, make("Shrug", "Dumbbell Shrug", "Tertiary", weights: "Dumbbells", weight: 30))
        addGroup(p, w, makeCurl("Concentration Curls"))
        addGroup(p, w, makeAbs("Hanging Leg Raise"))
    }

    private func buildLegWorkout(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeSquat("Goblet Squat"))
        addExercise(p, w, make("Lunge", "Dumbbell Lunge", "Tertiary", weights: "Dumbbells", weight: 20))
        addGroup(p, w, makeDeadlift("Single Leg Dumbbell Deadlift"))
        addExercise(p, w, make("Calf Raise", "One-Leg DB Calf Raises", "Tertiary", weights: "Dumbbells", weight: 40))
    }
}

final class BasicMachineBuilder: BaseBasic {
    override init(_ wizard: Wizard) {
        super.init(wizard)
        workout1Name = "Leg Press"
        workout2Name = "Pull Through"
    }
    
    override func setup(_ program: Program) {
        program.summary = "Beginner machine centric program."
    
        program.styles["Primary"] =   variableStyle(warmup: "5/0 5/60 3/80 1/90", workset: "5-10 5-10 5-10", rest: "2m")
        program.styles["Secondary"] = variableStyle(warmup: "5/60 3/80 1/90", workset: "5-10 5-10 5-10", rest: "2m")
        program.styles["Tertiary"]  = variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        program.styles["Plank"]     = durationsStyle(secs: "30 30 30", targetSecs: "")
    }

    override func buildWorkout1(_ p: Program, _ w: Workout) {
        if case .glute = wizard.goal {
            addGroup(p, w, makeSquat("Leg Press"))
            addGroup(p, w, makeBench("Chest Press Machine"))
            addExercise(p, w, make("Leg Curl", "Seated Leg Curl", "Tertiary", weights: "Cable Machine", weight: 20))
            addExercise(p, w, make("Hip Abduction", "Cable Hip Abduction", "Tertiary", weights: "Cable Machine", weight: 10), enabled: false)
        } else {
            addGroup(p, w, makeSquat("Leg Press"))
            addGroup(p, w, makeBench("Chest Press Machine"))
            addGroup(p, w, makeRow("Seated Cable Row"))
            addGroup(p, w, makeCurl("Cable Hammer Curls"), enabled: false)
        }
    }
    
    override func buildWorkout2(_ p: Program, _ w: Workout) {
        if case .glute = wizard.goal {
            addGroup(p, w, makeDeadlift("Cable Pull Through"))
            addGroup(p, w, makeOHP("Machine Shoulder Press"))
            addExercise(p, w, make("Cable Kickback", "One-Legged Cable Kickback", "Tertiary", weights: "Cable Machine", weight: 20))
            addGroup(p, w, makeRow("Seated Cable Row"), enabled: false)
        } else {
            addGroup(p, w, makeDeadlift("Cable Pull Through"))
            addGroup(p, w, makeOHP("Machine Shoulder Press"))
            addGroup(p, w, makePullup("Lat Pulldown"))
            addGroup(p, w, makeAbs("Cable Crunch"), enabled: false)
        }
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
        initGroups(program)
    }
}

// TODO for intermediate and advanced need to account for age

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
        initGroups(program)
    }
}
