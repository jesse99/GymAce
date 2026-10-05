class Builder {
    fileprivate let wizard: Wizard
    
    init(_ wizard: Wizard) {
        self.wizard = wizard
    }
    
    /// The name of the program. A suffix may be appended by the wizard to make the name unique.
    var name: String {fatalError("override this")}
    
    /// The schedules supported by the program. The user will pick one of these before the program is populated.
    var schedules: [Wizard.Schedule] {fatalError("override this")}

    /// Index of the default schedule.
    var defaultSchedule: Int {fatalError("override this")}
    
    func build(_ program: Program) {
        fatalError("override this")
    }
    
    /// Used to update the program after the user has had a chance to switch around exercises using GroupView.
    func fixup(_ program: Program) {
    }

    fileprivate func addExercise(_ program: Program, _ workout: Workout, _ exercise: Exercise, enabled: Bool = true) {
        if exercise.name.lowercased().contains("db ") || exercise.name.lowercased().contains("dumbbell") {
            assert(exercise.weightSet! == "Dumbbells")
        } else if exercise.name.lowercased().contains("smith ") {
            assert(exercise.weightSet!.contains("no bar"))
        } else if exercise.name.lowercased().contains("machine ") {
            assert(exercise.weightSet!.contains("no bar"))
        }

        if program.findExercise(exercise.name) == nil {
            program.exercises.append(exercise)
        }
        workout.addExercise(name: exercise.name, enabled: enabled)
    }
    
    fileprivate func addGroup(_ program: Program, _ workout: Workout, _ inExercises: (String, Int, [Exercise]), enabled: Bool = true) {
        let group = inExercises.0
        let enabledIndex = inExercises.1
        let exercises = inExercises.2
        for (i, e) in exercises.enumerated() {
            assert(exercises.count(where: {$0.name == e.name}) == 1)    // names in a group must be unique
            addExercise(program, workout, e, enabled: enabled && i == enabledIndex)
            workout.entries.last!.group = group
        }
    }

    func initGroups(_ program: Program) {
        if !wizard.groups.isEmpty {
            var groups: [String: [String]] = [:]
            for (groupName, group) in wizard.groups {
                groups[groupName] = group.exercises
                enableGroup(program, groupName, group.active)
            }
            program.groups = groups
        } else {
            program.groups = nil
        }
    }
    
    fileprivate func enableGroup(_ program: Program, _ groupName: String, _ activeName: String) {
        for w in program.workouts {
            for e in w.entries {
                if e.group == groupName {
                    e.enabled = e.name == activeName
                }
            }
        }
    }
        
    private func upper(_ weight: Double, floor: Double = 0.0) -> Float {
        var multiplier = 1.0
        if wizard.male {
            multiplier *= 2.0
        }
        switch wizard.fitness {
        case .beginner: break
        case .intermediate: multiplier *= 2.0
        case .advanced: multiplier *= 3.0
        }
        if wizard.age > 70 {
            multiplier *= 0.7
        } else if wizard.age > 60 {
            multiplier *= 0.8
        } else if wizard.age > 50 {
            multiplier *= 0.9
        }
        return Float(max(multiplier * weight, floor))
    }
    
    private func lower(_ weight: Double, floor: Double = 0.0) -> Float {
        var multiplier = 1.0
        if wizard.male {
            multiplier *= 1.5
        }
        switch wizard.fitness {
        case .beginner: break
        case .intermediate: multiplier *= 2.0
        case .advanced: multiplier *= 3.0
        }
        if wizard.age > 70 {
            multiplier *= 0.7
        } else if wizard.age > 60 {
            multiplier *= 0.8
        } else if wizard.age > 50 {
            multiplier *= 0.9
        }
        return Float(max(multiplier * weight, floor))
    }
    
    fileprivate func makeSquat(_ primary: String, style: String, prefix: String = "", suffix: String = "", group: String = "Squat") -> (String, Int, [Exercise]) {
        let exercises = [
             make("\(prefix)High Bar Squat\(suffix)", "High bar Squat", style, weights: "Dual Lower Plates", weight: lower(45 + 2*5)),
             make("\(prefix)Low Bar Squat\(suffix)", "Low bar Squat", style, weights: "Dual Lower Plates", weight: lower(45 + 2*5)),
             make("\(prefix)Front Squat\(suffix)", "Front Squat", style, weights: "Dual Lower Plates", weight: lower(45)),
             make("\(prefix)Hack Squat\(suffix)", "Hack Squat", style, weights: "Dual Lower Plates no bar", weight: lower(45 + 2*5)),
             make("\(prefix)Smith Squat\(suffix)", "Smith Machine Squat", style, weights: "Dual Lower Plates no bar", weight: lower(45 + 2*5)),
             make("\(prefix)Split Squat\(suffix)", "DB Split Squat", style, weights: "Dumbbells", weight: lower(15)),
             make("\(prefix)Goblet Squat\(suffix)", "DB Goblet Squat", style, weights: "Dumbbells", weight: lower(25)),
             make("\(prefix)Leg Press\(suffix)", "Leg Press", style, weights: "Dual Lower Plates no bar", weight: lower(2*35)),
        ]
        let r = exercises.sorted(by: {$0.name < $1.name})
        let enabledIndex = r.firstIndex(where: {$0.name == prefix + primary + suffix})!
        return (group, enabledIndex, r)
    }
    
    fileprivate func makeDeadlift(_ primary: String, style: String, prefix: String = "", group: String = "Deadlift") -> (String, Int, [Exercise]) {
        let exercises = [
            make("\(prefix)American Deadlift", "Deadlift", style, weights: "Dual Lower Plates", weight: lower(45 + 2*20)),
            make("\(prefix)Romanian Deadlift", "Romanian Deadlift", style, weights: "Dual Lower Plates", weight: lower(45 + 2*20)),
            make("\(prefix)Stiff-Legged Deadlift", "Stiff-Legged Deadlift", style, weights: "Dual Lower Plates", weight: lower(45 + 2*10)),
            make("\(prefix)Sumo Deadlift", "Sumo Deadlift", style, weights: "Dual Lower Plates", weight: lower(45 + 2*20)),
            make("\(prefix)Trap Bar Deadlift", "Trap Bar Deadlift", style, weights: "Trapbar", weight: lower(45 + 2*20)),
            make("\(prefix)Dumbbell Deadlift", "Dumbbell Deadlift", style, weights: "Dumbbells", weight: lower(20)),
            make("\(prefix)Dumbbell Romanian Deadlift", "Dumbbell Romanian Deadlift", style, weights: "Dumbbells", weight: lower(20)),
            make("\(prefix)Single Leg Dumbbell Deadlift", "Single Leg Dumbbell Deadlift", style, weights: "Dumbbells", weight: lower(20)),
            make("\(prefix)Smith Deadlift", "Smith Machine Deadlift", style, weights: "Dual Lower Plates no bar", weight: lower(2*35)),
            make("\(prefix)Smith Romanian Deadlift", "Smith Machine Romanian Deadlift", style, weights: "Dual Lower Plates no bar", weight: lower(2*35)),
        ]
        let r = exercises.sorted(by: {$0.name < $1.name})
        let enabledIndex = r.firstIndex(where: {$0.name == prefix + primary})!
        return (group, enabledIndex, r)
    }
    
    fileprivate func makeBench(_ primary: String, style: String, prefix: String = "", group: String = "Bench") -> (String, Int, [Exercise]) {
        let exercises = [
            make("\(prefix)Bench Press", "Bench Press", style, weights: "Dual Upper Plates", weight: upper(40, floor: 45)),
            make("\(prefix)Close-Grip Bench", "Close-Grip Bench Press", style, weights: "Dual Upper Plates", weight: upper(35, floor: 45)),
            make("\(prefix)Incline Bench Press", "Incline Bench Press", style, weights: "Dual Upper Plates", weight: upper(35, floor: 45)),
            make("\(prefix)Dumbbell Bench Press", "Dumbbell Bench Press", style, weights: "Dumbbells", weight: upper(15)),
            make("\(prefix)Dumbbell Incline Press", "Dumbbell Incline Press", style, weights: "Dumbbells", weight: upper(15)),
            make("\(prefix)Chest Press Machine", "Chest Press Machine", style, weights: "Dual Upper Plates no bar", weight: upper(2*20)),
            make("\(prefix)Smith Bench", "Smith Machine Bench", style, weights: "Dual Upper Plates no bar", weight: upper(2*20)),
        ]
        let r = exercises.sorted(by: {$0.name < $1.name})
        let enabledIndex = r.firstIndex(where: {$0.name == prefix + primary})!
        return (group, enabledIndex, r)
    }
    
    fileprivate func makeOHP(_ primary: String, style: String, prefix: String = "", group: String = "OHP") -> (String, Int, [Exercise]) {
        let exercises = [
            make("\(prefix)Overhead Press", "Overhead Press", style, weights: "Dual Upper Plates", weight: upper(25, floor: 45)),
            make("\(prefix)Dumbbell Shoulder Press", "Dumbbell Shoulder Press", style, weights: "Dumbbells", weight: upper(10)),
            make("\(prefix)Machine Shoulder Press", "Machine Shoulder Press", style, weights: "Dual Upper Plates no bar", weight: upper(2*10)),
            make("\(prefix)Dumbbell Arnold Press", "Dumbbell Arnold Press", style, weights: "Dumbbells", weight: upper(10)),
            make("\(prefix)Seated Smith Press", "Seated Smith Machine Press", style, weights: "Dual Upper Plates no bar", weight: upper(2*10)),
            make("\(prefix)Landmine Press", "Landmine Press", style, weights: "Single Upper Plates no bar", weight: upper(15)),
        ]
        let r = exercises.sorted(by: {$0.name < $1.name})
        let enabledIndex = r.firstIndex(where: {$0.name == prefix + primary})!
        return (group, enabledIndex, r)
    }
    
    fileprivate func makeRow(_ primary: String, style: String, prefix: String = "", group: String = "Row") -> (String, Int, [Exercise]) {
        let exercises = [
            make("\(prefix)Pendlay Row", "Pendlay Row", style, weights: "Dual Lower Plates", weight: upper(35, floor: 45)),
            make("\(prefix)Chest Supported Row", "Chest Supported Row", style, weights: "Dumbbells", weight: upper(15)),
            make("\(prefix)Kroc Row", "Kroc Row", style, weights: "Dumbbells", weight: upper(20)),
            make("\(prefix)Bent Over Dumbbell Row", "Bent Over Dumbbell Row", style, weights: "Dumbbells", weight: upper(15)),
            make("\(prefix)Seated Cable Row", "Seated Cable Row", style, weights: "Cable Machine", weight: upper(25)),
            make("\(prefix)Standing One Arm Cable Row", "Standing One Arm Cable Row", style, weights: "Cable Machine", weight: upper(10)),
            make("\(prefix)Smith Bent-Over Row", "Smith Machine Bent-Over Row", style, weights: "Dual Lower Plates no bar", weight: upper(25)),
            make("\(prefix)T-Bar Row", "T-Bar Row", style, weights: "Single Lower Plates no bar", weight: upper(30)),
        ]
        let r = exercises.sorted(by: {$0.name < $1.name})
        let enabledIndex = r.firstIndex(where: {$0.name == prefix + primary})!
        return (group, enabledIndex, r)
    }

    fileprivate func makeAbs(_ primary: String, style: String, prefix: String = "", group: String = "Abs") -> (String, Int, [Exercise]) {
        var exercises = [
            make("\(prefix)Cable Crunch", "Cable Crunch", style, weights: "Cable Machine", weight: upper(10)),
            make("\(prefix)Ab Wheel Rollout", "Ab Wheel Rollout", style),
            make("\(prefix)Decline Situp", "Decline Situp", style, weights: "Single Lower Plates no bar", weight: 0),
            make("\(prefix)Hanging Leg Raise", "Hanging Leg Raise", style),
            make("\(prefix)Landmines", "Landmine 180's", style, weights: "Single Upper Plates no bar", weight: upper(10)),
        ]
        if style != "T3" {
            exercises += [make("Plank", "Plank", "Plank")]
        }
        let r = exercises.sorted(by: {$0.name < $1.name})
        let enabledIndex = r.firstIndex(where: {$0.name == prefix + primary})!
        return (group, enabledIndex, r)
    }

    fileprivate func makePullup(_ primary: String, style: String, prefix: String = "", group: String = "Pullup") -> (String, Int, [Exercise]) {
        let exercises = [
            make("\(prefix)Chin-up", "Chin-up", style, weights: "Single Lower Plates no bar", weight: 0),
            make("\(prefix)Pull-up", "Pull-up", style, weights: "Single Lower Plates no bar", weight: 0),
            make("\(prefix)Lat Pulldown", "Lat Pulldown", style, weights: "Cable Machine", weight: upper(25)),
        ]
        let r = exercises.sorted(by: {$0.name < $1.name})
        let enabledIndex = r.firstIndex(where: {$0.name == prefix + primary})!
        return (group, enabledIndex, r)
    }
    
    fileprivate func makeCurl(_ primary: String, style: String, prefix: String = "", group: String = "Curl") -> (String, Int, [Exercise]) {
        let exercises = [
            make("\(prefix)Barbell Curl", "Barbell Curl", style, weights: "Dual Upper Plates", weight: upper(10, floor: 45)),
            make("\(prefix)Concentration Curls", "Concentration Curls", style, weights: "Dumbbells", weight: upper(10)),
            make("\(prefix)Spider Curls", "Spider Curls", style, weights: "Dumbbells", weight: upper(10)),
            make("\(prefix)Cable Hammer Curls", "Cable Hammer Curls", style, weights: "Cable Machine", weight: upper(10)),
        ]
        let r = exercises.sorted(by: {$0.name < $1.name})
        let enabledIndex = r.firstIndex(where: {$0.name == prefix + primary})!
        return (group, enabledIndex, r)
    }
}

class BaseBasic: Builder {
    fileprivate var workout1Name: String = "Squat"
    fileprivate var workout2Name: String = "Deadlift"

    override init(_ wizard: Wizard) {
        super.init(wizard)
    }
    
    override var name: String {return "Basic"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(count: 2), .weekly(count: 3), .weekly(count: 4), .cycle(count: 2, rest: 2), .cycle(count: 2, rest: 4)]}

    override var defaultSchedule: Int {return 1}

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
        case .cycle(let count, let rest) where count == 2 && rest == 2:
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
        case .cycle(let count, let rest) where count == 2 && rest == 4:
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
            program.styles["Primary"]   = amrapStyle(warmup: "5/60 3/80 1/90", workset: "5 5 5", rest: "2m")
            program.styles["Accessory"] = variableStyle(warmup: "", workset: "4-8 4-8 4-8", rest: "2m")
        case .bodybuilding, .aesthetic:
            program.styles["Primary"]   = amrapStyle(warmup: "5/60 3/80 1/90", workset: "8 8 8", rest: "90s")
            program.styles["Accessory"] = variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        case .conditioning:
            fatalError("should be complex")
        }
        program.styles["Plank"] = durationsStyle(secs: "30 30 30", targetSecs: "")
    }

    override func buildWorkout1(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeSquat("High Bar Squat", style: "Primary"))
        addGroup(p, w, makeBench("Bench Press", style: "Primary"))
        switch wizard.goal {
        case .strength:
            addGroup(p, w, makeRow("Pendlay Row", style: "Accessory"))
            addGroup(p, w, makeCurl("Barbell Curl", style: "Accessory"), enabled: false)
        case .bodybuilding:
            addGroup(p, w, makeRow("Pendlay Row", style: "Accessory"))
            addGroup(p, w, makeCurl("Barbell Curl", style: "Accessory"))
        case .aesthetic:
            if wizard.male {
                addGroup(p, w, makeRow("Pendlay Row", style: "Accessory"))
                addGroup(p, w, makeCurl("Barbell Curl", style: "Accessory"))
            } else {
                addExercise(p, w, make("Hip Thrust", "Hip Thrust", "Primary", weights: "Dual Lower Plates", weight: 85))
                addGroup(p, w, makeRow("Pendlay Row", style: "Accessory"), enabled: false)
            }
        case .conditioning:
            fatalError("should be complex")
        }
    }
    
    override func buildWorkout2(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeDeadlift("American Deadlift", style: "Primary"))
        addGroup(p, w, makeOHP("Overhead Press", style: "Primary"))
        switch wizard.goal {
        case .strength:
            addGroup(p, w, makePullup("Chin-up", style: "Accessory"))
            if wizard.machines {
                addGroup(p, w, makeAbs("Cable Crunch", style: "Accessory"), enabled: false)
            } else {
                addGroup(p, w, makeAbs("Landmines", style: "Accessory"), enabled: false)
            }
        case .bodybuilding:
            addGroup(p, w, makePullup("Chin-up", style: "Accessory"))
            if wizard.machines {
                addGroup(p, w, makeAbs("Cable Crunch", style: "Accessory"))
            } else {
                addGroup(p, w, makeAbs("Landmines", style: "Accessory"))
            }
        case .aesthetic:
            if wizard.male {
                addGroup(p, w, makePullup("Chin-up", style: "Accessory"))
                if wizard.machines {
                    addGroup(p, w, makeAbs("Cable Crunch", style: "Accessory"))
                } else {
                    addGroup(p, w, makeAbs("Landmines", style: "Accessory"))
                }
            } else {
                addGroup(p, w, makePullup("Chin-up", style: "Accessory"), enabled: false)
                if wizard.machines {
                    addGroup(p, w, makeAbs("Cable Crunch", style: "Accessory"))
                } else {
                    addGroup(p, w, makeAbs("Landmines", style: "Accessory"))
                }
            }
        case .conditioning:
            fatalError("should be complex")
        }
    }
}

final class BasicSmithBuilder: BaseBasic {
    override func setup(_ program: Program) {
        program.summary = "A simple [program](https://thefitness.wiki/routines/r-fitness-basic-beginner-routine) for beginners. It's meant to be run for about three months after which you should switch to an intermediate program. For the last sets do as many reps as you can but try to stop when you have 1-2 reps left."
    
        switch wizard.goal {
        case .strength:
            program.styles["Primary"]   = amrapStyle(warmup: "5/60 3/80 1/90", workset: "5 5 5", rest: "2m")
            program.styles["Accessory"] = variableStyle(warmup: "", workset: "4-8 4-8 4-8", rest: "2m")
        case .bodybuilding, .aesthetic:
            program.styles["Primary"]   =  amrapStyle(warmup: "5/0 5/60 3/80 1/90", workset: "8 8 8", rest: "90s")
            program.styles["Accessory"] = variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        case .conditioning:
            fatalError("should be complex")
        }
        program.styles["Plank"] = durationsStyle(secs: "30 30 30", targetSecs: "")
    }

    override func buildWorkout1(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeSquat("Smith Squat", style: "Primary"))
        addGroup(p, w, makeBench("Smith Bench", style: "Primary"))
        switch wizard.goal {
        case .strength:
            if wizard.machines {
                addGroup(p, w, makeRow("Seated Cable Row", style: "Accessory"))
                addGroup(p, w, makeCurl("Cable Hammer Curls", style: "Accessory"), enabled: false)
            } else if wizard.fullDumbbells {
                addGroup(p, w, makeRow("DB Kroc Row", style: "Accessory"))
                addGroup(p, w, makeCurl("Concentration Curls", style: "Accessory"), enabled: false)
            } else {
                addGroup(p, w, makeRow("Seated Cable Row", style: "Accessory"))
            }
        case .bodybuilding:
            if wizard.machines {
                addGroup(p, w, makeRow("Seated Cable Row", style: "Accessory"))
                addGroup(p, w, makeCurl("Cable Hammer Curls", style: "Accessory"))
            } else if wizard.fullDumbbells {
                addGroup(p, w, makeRow("DB Kroc Row", style: "Accessory"))
                addGroup(p, w, makeCurl("Concentration Curls", style: "Accessory"))
            } else {
                addGroup(p, w, makeRow("Seated Cable Row", style: "Accessory"))
            }
        case .aesthetic:
            if wizard.male {
                if wizard.machines {
                    addGroup(p, w, makeRow("Seated Cable Row", style: "Accessory"))
                    addGroup(p, w, makeCurl("Cable Hammer Curls", style: "Accessory"))
                } else if wizard.fullDumbbells {
                    addGroup(p, w, makeRow("DB Kroc Row", style: "Accessory"))
                    addGroup(p, w, makeCurl("Concentration Curls", style: "Accessory"))
                } else {
                    addGroup(p, w, makeRow("Seated Cable Row", style: "Accessory"))
                }
            } else {
                addExercise(p, w, make("Hip Thrust", "Hip Thrust", "Primary", weights: "Dual Lower Plates", weight: 85))
                if wizard.machines {
                    addExercise(p, w, make("Hip Abduction", "Cable Hip Abduction", "Accessory", weights: "Cable Machine", weight: 10))
                } else {
                    addGroup(p, w, makeAbs("Hanging Leg Raise", style: "Accessory"))
                }
            }
        case .conditioning:
            fatalError("should be complex")
        }
    }
    
    override func buildWorkout2(_ p: Program, _ w: Workout) {
        switch wizard.goal {
        case .strength:
            addGroup(p, w, makePullup("Chin-up", style: "Accessory"))
            addGroup(p, w, makeOHP("Seated Smith Press", style: "Primary"))
            addGroup(p, w, makeDeadlift("Smith Deadlift", style: "Primary"))
            if wizard.machines {
                addGroup(p, w, makeAbs("Cable Crunch", style: "Accessory"), enabled: false)
            } else if wizard.fullDumbbells {
                addExercise(p, w, make("Dumbbell Flyes", "Dumbbell Flyes", "Accessory", weights: "Dumbbells", weight: 5), enabled: false)
            }
        case .bodybuilding:
            addGroup(p, w, makePullup("Chin-up", style: "Accessory"))
            addGroup(p, w, makeOHP("Seated Smith Press", style: "Primary"))
            addGroup(p, w, makeDeadlift("Smith Deadlift", style: "Primary"))
            if wizard.machines {
                addGroup(p, w, makeAbs("Cable Crunch", style: "Accessory"))
            } else if wizard.fullDumbbells {
                addExercise(p, w, make("Dumbbell Flyes", "Dumbbell Flyes", "Accessory", weights: "Dumbbells", weight: 5))
            }
        case .aesthetic:
            if wizard.male {
                addGroup(p, w, makePullup("Chin-up", style: "Accessory"))
                addGroup(p, w, makeOHP("Seated Smith Press", style: "Primary"))
                addGroup(p, w, makeDeadlift("Smith Deadlift", style: "Primary"))
                if wizard.machines {
                    addGroup(p, w, makeAbs("Cable Crunch", style: "Accessory"))
                } else if wizard.fullDumbbells {
                    addExercise(p, w, make("Dumbbell Flyes", "Dumbbell Flyes", "Accessory", weights: "Dumbbells", weight: 5))
                }
            } else {
                addGroup(p, w, makeDeadlift("Smith Deadlift", style: "Primary"))
                if wizard.machines {
                    addGroup(p, w, makePullup("Lat Pulldown", style: "Accessory"))
                    addExercise(p, w, make("Cable Kickback", "One-Legged Cable Kickback", "Accessory", weights: "Cable Machine", weight: 20))
                    addGroup(p, w, makeAbs("Hanging Leg Raise", style: "Accessory"), enabled: false)
                } else if wizard.fullDumbbells {
                    addGroup(p, w, makeRow("Kroc Row", style: "Accessory"))
                    addExercise(p, w, make("Step-ups", "Step-ups", "Accessory", weights: "Dumbbells", weight: 10))
                    addGroup(p, w, makeAbs("Hanging Leg Raise", style: "Accessory"), enabled: false)
                } else {
                    addGroup(p, w, makeOHP("Seated Smith Press", style: "Primary"))
                    addGroup(p, w, makeAbs("Hanging Leg Raise", style: "Accessory"))
                }
            }
        case .conditioning:
            fatalError("should be complex")
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
    
        program.styles["Primary"]   = variableStyle(warmup: "5/60 3/80 1/90", workset: "5-10 5-10 5-10", rest: "60s")
        program.styles["Accessory"] = variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        program.styles["Plank"]     = durationsStyle(secs: "30 30 30", targetSecs: "")
    }

    override func buildWorkout1(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeSquat("Split Squat", style: "Primary"))
        addGroup(p, w, makeBench("Dumbbell Bench Press", style: "Primary"))
        addGroup(p, w, makeDeadlift("Dumbbell Deadlift", style: "Primary"))
        addExercise(p, w, make("Plank", "Plank", "Plank"))
    }
    
    override func buildWorkout2(_ p: Program, _ w: Workout) {
        if case .aesthetic = wizard.goal, !wizard.male {
            addGroup(p, w, makeSquat("Split Squat", style: "Primary"))
            addGroup(p, w, makeOHP("Dumbbell Shoulder Press", style: "Primary"))
            addExercise(p, w, make("Step-ups", "Step-ups", "Accessory", weights: "Dumbbells", weight: 10))
            addExercise(p, w, make("Plank", "Plank", "Plank"))
        } else {
            addGroup(p, w, makeSquat("Split Squat", style: "Primary"))
            addGroup(p, w, makeOHP("Dumbbell Shoulder Press", style: "Primary"))
            addGroup(p, w, makeRow("Bent Over Dumbbell Row", style: "Accessory"))
            addExercise(p, w, make("Plank", "Plank", "Plank"))
        }
    }
}

final class BasicPPLDBBuilder: Builder {
    override var name: String {return "PPL"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(count: 3), .weekly(count: 6), .cycle(count: 3, rest: 1), .cycle(count: 3, rest: 2)]}

    override var defaultSchedule: Int {return 0}

    override func build(_ program: Program) {
        program.summary = "A Push/Pull/Legs beginner [program](https://thefitness.wiki/reddit-archive/dumbbell-stopgap-ppl/) that requires minimal equipment."
        
        program.styles["Primary"]   = variableStyle(warmup: "5/60 3/80 1/90", workset: "6-12 6-12 6-12", rest: "90s")
        program.styles["Accessory"] = variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        
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
        case .cycle(let count, let rest) where count == 3 && rest == 1:
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
        case .cycle(let count, let rest) where count == 3 && rest == 2:
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
    
    // Note that this is bodybuilding only.
    private func buildPushWorkout(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeBench("Dumbbell Bench Press", style: "Primary"))
        addExercise(p, w, make("Incline Fly", "Dumbbell Incline Flyes", "Accessory", weights: "Dumbbells", weight: 10))
        addGroup(p, w, makeOHP("Dumbbell Arnold Press", style: "Primary"))
        addExercise(p, w, make("Overhead Tricep Extension", "Standing Triceps Press", "Accessory", weights: "Dumbbells", weight: 15))
    }
    
    private func buildPullWorkout(_ p: Program, _ w: Workout) {
        addGroup(p, w, makePullup("Pull-up", style: "Accessory"))
        addGroup(p, w, makeRow("Bent Over Dumbbell Row", style: "Accessory"))
        addExercise(p, w, make("Reverse Fly", "Reverse Flyes", "Accessory", weights: "Dumbbells", weight: 10))
        addExercise(p, w, make("Shrug", "Dumbbell Shrug", "Accessory", weights: "Dumbbells", weight: 30))
        addGroup(p, w, makeCurl("Concentration Curls", style: "Accessory"))
        addGroup(p, w, makeAbs("Hanging Leg Raise", style: "Accessory"))
    }

    private func buildLegWorkout(_ p: Program, _ w: Workout) {
        addGroup(p, w, makeSquat("Goblet Squat", style: "Primary"))
        addExercise(p, w, make("Lunge", "Dumbbell Lunge", "Accessory", weights: "Dumbbells", weight: 20))
        addGroup(p, w, makeDeadlift("Single Leg Dumbbell Deadlift", style: "Primary"))
        addExercise(p, w, make("Calf Raise", "One-Leg DB Calf Raises", "Accessory", weights: "Dumbbells", weight: 40))
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
    
        program.styles["Primary"]   = variableStyle(warmup: "5/60 3/80 1/90", workset: "5-10 5-10 5-10", rest: "2m")
        program.styles["Accessory"] = variableStyle(warmup: "", workset: "6-12 6-12 6-12", rest: "90s")
        program.styles["Plank"]     = durationsStyle(secs: "30 30 30", targetSecs: "")
    }

    override func buildWorkout1(_ p: Program, _ w: Workout) {
        if case .aesthetic = wizard.goal, !wizard.male {
            addGroup(p, w, makeSquat("Leg Press", style: "Primary"))
            addGroup(p, w, makeBench("Chest Press Machine", style: "Primary"))
            addExercise(p, w, make("Leg Curl", "Seated Leg Curl", "Accessory", weights: "Cable Machine", weight: 20))
            addExercise(p, w, make("Hip Abduction", "Cable Hip Abduction", "Accessory", weights: "Cable Machine", weight: 10), enabled: false)
        } else {
            addGroup(p, w, makeSquat("Leg Press", style: "Primary"))
            addGroup(p, w, makeBench("Chest Press Machine", style: "Primary"))
            addGroup(p, w, makeRow("Seated Cable Row", style: "Accessory"))
            addGroup(p, w, makeCurl("Cable Hammer Curls", style: "Accessory"), enabled: false)
        }
    }
    
    override func buildWorkout2(_ p: Program, _ w: Workout) {
        if case .aesthetic = wizard.goal, !wizard.male {
            addExercise(p, w, make("Cable Pull Through", "Cable Pull Through", "Accessory", weights: "Cable Machine", weight: 20))
            addGroup(p, w, makeOHP("Machine Shoulder Press", style: "Primary"))
            addExercise(p, w, make("Cable Kickback", "One-Legged Cable Kickback", "Accessory", weights: "Cable Machine", weight: 20))
            addGroup(p, w, makeRow("Seated Cable Row", style: "Accessory"), enabled: false)
        } else {
            addExercise(p, w, make("Cable Pull Through", "Cable Pull Through", "Accessory", weights: "Cable Machine", weight: 20))
            addGroup(p, w, makeOHP("Machine Shoulder Press", style: "Primary"))
            addGroup(p, w, makePullup("Lat Pulldown", style: "Accessory"))
            addGroup(p, w, makeAbs("Cable Crunch", style: "Accessory"), enabled: false)
        }
    }
}

final class ComplexBuilder: Builder {
    override var name: String {return "Complex"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(count: 1), .weekly(count: 2), .weekly(count: 3), .cycle(count: 1, rest: 1), .cycle(count: 1, rest: 2)]}

    override var defaultSchedule: Int {return 2}

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
        case .cycle(let count, let rest) where count == 1 && rest == 1:
            let schedule = Schedule.cyclic
            var workout = Workout("Complex", schedule)
            workout.addExercise(name: "Complex")
            program.addWorkout(workout)

            workout = Workout("Rest", schedule)
            program.addWorkout(workout)
        case .cycle(let count, let rest) where count == 1 && rest == 2:
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

    override var defaultSchedule: Int {return 0}

    override func build(_ program: Program) {
        program.summary = "Place holder until we can handle this case."
        let workout = Workout("Workout", Schedule.days(Weekdays([.monday])))
        program.addWorkout(workout)
        initGroups(program)
    }
}

/// Intermediate and advanced strength program
final class GzclBuilder: Builder {
    override var name: String {return "GZCL"}
    
    override var schedules: [Wizard.Schedule] {return [.block(weeks: 3, count: 3), .block(weeks: 3, count: 4), .block(weeks: 4, count: 3), .block(weeks: 4, count: 4)]}
    
    override var defaultSchedule: Int {return 1}

    override func build(_ program: Program) {
        // Also see
        // https://swoleateveryheight.blogspot.com/2016/02/gzcl-applications-adaptations.html
        // https://www.reddit.com/r/gzcl/wiki/index/
        program.summary = "Intermediate stength [program](https://swoleateveryheight.blogspot.com/2014/07/the-gzcl-method-simplified_13.html) that uses three tiers and 3-4 week blocks. Tier 1 and tier 2 start at lower weights but higher volume and weights increase each week with volume decreasing. One rep maxes are retested in the last week. Tier 1 are primary exercises (like squat and bench). Tier 2 are designed to directly support the T1 exercises and T3 are general assistance exercises. Volume increases with each tier."
                
        initStyles(program)
        switch wizard.schedule {
        case .block(let weeks, _) where weeks == 3:
            use3WeekStyles(program)
        default:
            // otherwise it's a 4 week block so initial styles are OK
            break
        }
        scheduleWorkouts(program)
        initGroups(program)
    }
    
    override func fixup(_ program: Program) {
        var oldExercises: [(Exercise, Bool)] = []
        let maxWorkout = program.workouts.first(where: {$0.name == "One Rep Max"})!
        for workout in program.workouts {
            for entry in workout.entries {
                if let exercise = program.findExercise(entry.name), exercise.styleName == "T1" || exercise.styleName == "T2" {
                    do {
                        if !oldExercises.contains(where: {$0.0.name == exercise.name}) {
                            if entry.enabled {
                                oldExercises.insert((exercise, entry.enabled), at: 0)
                            } else {
                                oldExercises.append((exercise, entry.enabled))
                            }
                        }
                        
                        // Add a new version of the exercise for the workout's week.
                        let new = try exercise.clone()
                        let baseName = exercise.name.dropFirst(3)
                        new.styleName += ".\(workout.weeks!.lowerBound)"
                        new.name = "\(new.styleName) \(baseName)"
                        new.baseWeight = .other
                        entry.name = new.name
                        if program.findExercise(new.name) == nil {
                            program.exercises.append(new)
                        }
                    } catch {
                        fatalError("clone should not have thrown")
                    }
                }
            }
        }
        
        // Add the old exercises to the Max workout
        for (old, enabled) in oldExercises {
            // Note that these are looked up using formalName so we'll use that instead of having to worry about
            // the style prefix or modifiers like "Paused".
            let newName = "Max \(old.formalName)"
            if !maxWorkout.entries.contains(where: {$0.name == newName}) {
                old.name = newName
                old.styleName = "1RM"
                maxWorkout.addExercise(name: old.name, enabled: enabled)
            } else {
                program.exercises.removeAll(where: {$0.name == old.name})
            }
        }
    }
    
    private func initStyles(_ program: Program) {
        program.styles["1RM"]  = oneRepMaxStyle(warmup: "5/60 3/80 1/90", workset: "1", rest: "3m")
        
        if wizard.age >= 70 {
            program.styles["T1.1"] = basicStyle(warmup: "5/45 3/65 1/75", workset: "5/85 5/85", rest: "5m")          // 10 reps
            program.styles["T1.2"] = basicStyle(warmup: "5/50 3/70 1/80", workset: "4/90 4/90", rest: "5m")          // 8 reps
            program.styles["T1.3"] = basicStyle(warmup: "5/47 3/67 1/77", workset: "3/87 2/92 1/97", rest: "5m")     // 6 reps
            program.styles["T1.4"] = amrapStyle(warmup: "5/50 3/70 1/80", workset: "1/90 1/95 1", rest: "5m")        // 3+ reps

            program.styles["T2.1"] = basicStyle(warmup: "5/25 3/45 1/55", workset: "6/65 6/65 6/65", rest: "3.5m")   // 18 reps
            program.styles["T2.2"] = basicStyle(warmup: "5/30 3/50 1/60", workset: "5/70 5/70 5/70", rest: "3.5m")   // 15 reps
            program.styles["T2.3"] = basicStyle(warmup: "5/35 3/55 1/65", workset: "4/75 4/75 4/75", rest: "3.5m")   // 12 reps
            program.styles["T2.4"] = amrapStyle(warmup: "5/40 3/60 1/70", workset: "3/80 3/80 3/80", rest: "3.5m")   // 9 reps

            program.styles["T3"] = variableStyle(warmup: "", workset: "5-10 5-10 5-10", rest: "2m")                  // up to 30
       
        } else if wizard.age >= 60 {
            program.styles["T1.1"] = basicStyle(warmup: "5/45 3/65 1/75", workset: "4/85 4/85 4/85", rest: "4m")        // 12 reps
            program.styles["T1.2"] = basicStyle(warmup: "5/50 3/70 1/80", workset: "3/90 3/90 3/90", rest: "4m")        // 9 reps
            program.styles["T1.3"] = basicStyle(warmup: "5/47 3/67 1/77", workset: "3/87 2/92 2/92 1/97", rest: "4m")   // 8 reps
            program.styles["T1.4"] = amrapStyle(warmup: "5/50 3/70 1/80", workset: "2/90 2/95 1", rest: "4m")           // 5+ reps

            program.styles["T2.1"] = basicStyle(warmup: "5/25 3/45 1/55", workset: "6/65 6/65 6/65 6/65", rest: "3m")   // 24 reps
            program.styles["T2.2"] = basicStyle(warmup: "5/30 3/50 1/60", workset: "5/70 5/70 5/70 5/70", rest: "3m")   // 20 reps
            program.styles["T2.3"] = basicStyle(warmup: "5/35 3/55 1/65", workset: "4/75 4/75 4/75 4/75", rest: "3m")   // 16 reps
            program.styles["T2.4"] = amrapStyle(warmup: "5/40 3/60 1/70", workset: "3/80 3/80 3/80 3/80", rest: "3m")   // 12 reps

            program.styles["T3"] = variableStyle(warmup: "", workset: "5-10 5-10 5-10", rest: "90s")                    // up to 30
       
        } else {
            program.styles["T1.1"] = basicStyle(warmup: "5/45 3/65 1/75", workset: "5/85 5/85 5/85", rest: "4m")                  // 15 reps
            program.styles["T1.2"] = basicStyle(warmup: "5/50 3/70 1/80", workset: "3/90 3/90 3/90 3/90", rest: "4m")             // 12 reps
            program.styles["T1.3"] = basicStyle(warmup: "5/47 3/67 1/77", workset: "3/87 2/92 2/92 1/97 1/97 1/97", rest: "4m")   // 10 reps
            program.styles["T1.4"] = amrapStyle(warmup: "5/50 3/70 1/80", workset: "3/90 2/95 1", rest: "4m")                     // 6+ reps

            program.styles["T2.1"] = basicStyle(warmup: "5/25 3/45 1/55", workset: "8/65 8/65 8/65 8/65", rest: "2.5m")           // 32 reps
            program.styles["T2.2"] = basicStyle(warmup: "5/30 3/50 1/60", workset: "6/70 6/70 6/70 6/70 6/70", rest: "2.5m")      // 30 reps
            program.styles["T2.3"] = basicStyle(warmup: "5/35 3/55 1/65", workset: "5/75 5/75 5/75 5/75 5/75", rest: "2.5m")      // 30 reps
            program.styles["T2.4"] = amrapStyle(warmup: "5/40 3/60 1/70", workset: "4/80 4/80 4/80 4/80 4/80", rest: "2.5m")      // 20 reps

            if wizard.age < 50 {
                program.styles["T3"] = variableStyle(warmup: "", workset: "8-12 8-12 8-12 8-12", rest: "80s")                      // up to 36
            } else {
                program.styles["T3"] = variableStyle(warmup: "", workset: "5-10 5-10 5-10", rest: "80s")                           // up to 30
            }
        }
    }
    
    private func use3WeekStyles(_ program: Program) {
        // Replace T1.3 with T1.4
        program.styles["T1.3"] = program.styles["T1.4"]
        program.styles["T1.4"] = nil
        
        // Remove T2.1
        program.styles["T2.1"] = program.styles["T2.2"]
        program.styles["T2.2"] = program.styles["T2.3"]
        program.styles["T2.3"] = program.styles["T2.4"]
        program.styles["T2.4"] = nil
    }
    
    private func scheduleWorkouts(_ program: Program) {
        let schedule = Schedule.anyDay
        let workout = Workout("One Rep Max", schedule)
        program.addWorkout(workout)
        
        switch wizard.schedule {
        case .block(let weeks, let count) where count == 3:
            for week in 1...weeks {
                var schedule = Schedule.days(Weekdays([.monday]))
                var workout = Workout("Squat week \(week)", schedule)
                workout.weeks = week...week
                buildSquatWorkout(program, workout, week)
                program.addWorkout(workout)
                
                schedule = Schedule.days(Weekdays([.wednesday]))
                workout = Workout("Bench week \(week)", schedule)
                workout.weeks = week...week
                buildBenchWorkout(program, workout, week)
                program.addWorkout(workout)
                
                schedule = Schedule.days(Weekdays([.friday]))
                workout = Workout("Deadlift week \(week)", schedule)
                workout.weeks = week...week
                buildDeadWorkout(program, workout, week)
                program.addWorkout(workout)
            }
        case .block(let weeks, let count) where count == 4:
            for week in 1...weeks {
                var schedule = Schedule.days(Weekdays([.monday]))
                var workout = Workout("Squat week \(week)", schedule)
                workout.weeks = week...week
                buildSquatWorkout(program, workout, week)
                program.addWorkout(workout)
                
                schedule = Schedule.days(Weekdays([.tuesday]))
                workout = Workout("Bench week \(week)", schedule)
                workout.weeks = week...week
                buildBenchWorkout(program, workout, week)
                program.addWorkout(workout)
                
                schedule = Schedule.days(Weekdays([.thursday]))
                workout = Workout("OHP week \(week)", schedule)
                workout.weeks = week...week
                buildOhpWorkout(program, workout, week)
                program.addWorkout(workout)
                
                schedule = Schedule.days(Weekdays([.friday]))
                workout = Workout("Deadlift week \(week)", schedule)
                workout.weeks = week...week
                buildDeadWorkout(program, workout, week)
                program.addWorkout(workout)
            }
        default:
            fatalError("\(wizard.schedule) shouldn't have happened")
        }
    }
    
    private func buildSquatWorkout(_ p: Program, _ w: Workout, _ week: Int) {
        // Initially we add just one exercise for the T1 and T2 exercises. We do this so that GroupView
        // can swap in a new exercise that takes affect for each week. Then, as the last step, in making
        // a program we fixup the program by adding new exercises for each week as well as a Max version
        // of the exercise.
        if wizard.barbells {
            addGroup(p, w, makeSquat("Low Bar Squat", style: "T1", prefix: "T1 ", group: "T1 Squat"))
            addGroup(p, w, makeSquat("Low Bar Squat", style: "T2", prefix: "T2 Paused ", group: "T2 Squat"))
        } else if wizard.fullDumbbells {
            addGroup(p, w, makeSquat("Split Squat", style: "T1", prefix: "T1 ", group: "T1 Squat"))
            addGroup(p, w, makeSquat("Split Squat", style: "T2", prefix: "T2 Paused ", group: "T2 Squat"))
        } else {
            addGroup(p, w, makeSquat("Leg Press", style: "T1", prefix: "T1 ", group: "T1 Squat"))
            addGroup(p, w, makeSquat("Leg Press", style: "T2", prefix: "T2 Paused ", group: "T2 Squat"))
        }

        if wizard.age < 60 {
            if wizard.machines {
                addExercise(p, w, make("T3 Leg Extensions", "Leg Extensions", "T3", weights: "Cable Machine", weight: 20))
            }
        }
        if wizard.age < 50 {
            if wizard.barbells {
                addExercise(p, w, make("T3 Calf Raises", "Standing Calf Raises", "T3", weights: "Dual Lower Plates", weight: 2*45))
            }
        }
        if wizard.machines {
            addExercise(p, w, make("T3 Leg Curl", "Seated Leg Curl", "T3", weights: "Cable Machine", weight: 20))
        }
    }
    
    private func buildBenchWorkout(_ p: Program, _ w: Workout, _ week: Int) {
        if wizard.barbells {
            addGroup(p, w, makeBench("Bench Press", style: "T1", prefix: "T1 ", group: "T1 Bench"))
            addGroup(p, w, makeBench("Close-Grip Bench", style: "T2", prefix: "T2 ", group: "T2 Bench"))
        } else if wizard.fullDumbbells {
            addGroup(p, w, makeBench("Dumbbell Bench Press", style: "T1", prefix: "T1 ", group: "T1 Bench"))
            addGroup(p, w, makeBench("Dumbbell Incline Press", style: "T2", prefix: "T2 ", group: "T2 Bench"))
        } else {
            addGroup(p, w, makeBench("Chest Press Machine", style: "T1", prefix: "T1 ", group: "T1 Bench"))
            addExercise(p, w, make("T2.\(week) Pec Deck Fly", "Pec Deck Fly", "T2.\(week)", weights: "Cable Machine", weight: 20))
        }

        if wizard.age < 60 {
            if wizard.fullDumbbells {
                addGroup(p, w, makeCurl("Concentration Curls", style: "T3", prefix: "T3 ", group: "T3 Curls"))
            }
        }
        if wizard.age < 50 {
            addExercise(p, w, make("T3 Bodyweight Dips", "Dips", "T3", weights: "Single Lower Plates no bar", weight: 0))
        }
        if wizard.machines {
            addGroup(p, w, makeRow("Seated Cable Row", style: "T3", prefix: "T3 ", group: "T3 Row"))
        }
    }
    
    private func buildOhpWorkout(_ p: Program, _ w: Workout, _ week: Int) {
        if wizard.barbells {
            addGroup(p, w, makeOHP("Overhead Press", style: "T1", prefix: "T1 ", group: "T1 OHP"))
            addExercise(p, w, make("T2.\(week) Barbell Shrug", "Barbell Shrug", "T2.\(week)", weights: "Cable Machine", weight: 20))
        } else if wizard.fullDumbbells {
            addGroup(p, w, makeOHP("Dumbbell Shoulder Press", style: "T1", prefix: "T1 ", group: "T1 OHP"))
            addExercise(p, w, make("T2.\(week) Pec Deck Fly", "Pec Deck Fly", "T2.\(week)", weights: "Cable Machine", weight: 20))
        } else {
            addGroup(p, w, makeOHP("Machine Shoulder Press", style: "T1", prefix: "T1 ", group: "T1 OHP"))
            addExercise(p, w, make("T2.\(week) Smith Machine Shrug", "Smith Machine Shrug", "T2.\(week)", weights: "Dual Lower Plates no bar", weight: 20))
        }

        if wizard.age < 50 {
            addGroup(p, w, makeAbs("Ab Wheel Rollout", style: "T3", prefix: "T3 ", group: "T3 Abs"))
        }
        if wizard.fullDumbbells {
            if wizard.fullDumbbells {
                addExercise(p, w, make("T3 Skull Crushers", "Skull Crushers", "T3", weights: "Dumbbells", weight: 20))
            }
        }
    }
    
    private func buildDeadWorkout(_ p: Program, _ w: Workout, _ week: Int) {
        if wizard.barbells {
            addGroup(p, w, makeDeadlift("American Deadlift", style: "T1", prefix: "T1 ", group: "T1 Deadlift"))
            addGroup(p, w, makeDeadlift("American Deadlift", style: "T2", prefix: "T2 Deficit ", group: "T2 Deadlift"))
        } else if wizard.fullDumbbells {
            addGroup(p, w, makeDeadlift("Dumbbell Deadlift", style: "T1", prefix: "T1 ", group: "T1 Deadlift"))
            addGroup(p, w, makeDeadlift("Dumbbell Deadlift", style: "T2", prefix: "T2 Deficit ", group: "T2 Deadlift"))
        } else {
            addGroup(p, w, makeDeadlift("Smith Deadlift", style: "T1", prefix: "T1 ", group: "T1 Deadlift"))
            addGroup(p, w, makeDeadlift("Smith Deadlift", style: "T2", prefix: "T2 Deficit ", group: "T2 Deadlift"))
        }

        if wizard.age < 60 {
            if wizard.fullDumbbells {
                addExercise(p, w, make("T3 Back Extension", "Back Extension", "T3", weights: "Dumbbells", weight: 20))
            } else if wizard.barbells {
                addExercise(p, w, make("T3 Back Extension", "Back Extension", "T3", weights: "Single Lower Plates no bar", weight: 20))
            }
        }
        if wizard.machines {
            addExercise(p, w, make("T3 Face Pulls", "Face Pull", "T3", weights: "Cable Machine", weight: 20))
        }
        addGroup(p, w, makePullup("Pull-up", style: "T3", prefix: "T3 ", group: "T3 Pullup"))
    }
}

/// Intermediate and advanced bodybuilding program
final class PHATBuilder: Builder {
    override var name: String {return "PHAT"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(count: 5)]}

    override var defaultSchedule: Int {return 0}

    override func build(_ program: Program) {
        program.summary = "Five day a week bodybuilding [program](https://thefitness.wiki/reddit-archive/dumbbell-stopgap-ppl/)."
        
        program.styles["Power"] = variableStyle(warmup: "5/60 3/80 1/90", workset: "3-5 3-5 3-5", rest: "4m")
        program.styles["Speed"] = manualStyle(warmup: "5/35 3/55", workset: "3/65 3/65 3/65 3/65 3/65 3/65", rest: "60s")
        
        program.styles["2x6-10"]  = variableStyle(warmup: "", workset: "6-10 6-10", rest: "90s")
        program.styles["2x12-15"] = variableStyle(warmup: "", workset: "12-15 12-15", rest: "90s")
        program.styles["3x5-8"]   = variableStyle(warmup: "", workset: "5-8 5-8 5-8", rest: "90s")
        program.styles["3x6-10"]  = variableStyle(warmup: "", workset: "6-10 6-10 6-10", rest: "90s")
        program.styles["3x8-12"]  = variableStyle(warmup: "", workset: "8-12 8-12 8-12", rest: "90s")
        program.styles["3x12-20"] = variableStyle(warmup: "", workset: "12-20 12-20 12-20", rest: "90s")
        program.styles["3x15-20"] = variableStyle(warmup: "", workset: "15-20 15-20 15-20", rest: "90s")
        program.styles["4x10-15"] = variableStyle(warmup: "", workset: "10-15 10-15 10-15 10-15", rest: "90s")

        scheduleWorkouts(program)
        initGroups(program)
    }
    
    private func scheduleWorkouts(_ program: Program) {
        switch wizard.schedule {
        case .weekly(let days) where days == 5:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Upper Power", schedule)
            buildUpperPowerWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.tuesday]))
            workout = Workout("Lower Power", schedule)
            buildLowerPowerWorkout(program, workout)
            program.addWorkout(workout)
                        
            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("Back and Shoulders Hypertrophy", schedule)
            buildBackWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Lower Body Hypertrophy", schedule)
            buildLowerWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.saturday]))
            workout = Workout("Chest and Arms Hypertrophy", schedule)
            buildChestWorkout(program, workout)
            program.addWorkout(workout)
        default:
            fatalError("\(wizard.schedule) shouldn't have happened")
        }
    }
    
    private func buildUpperPowerWorkout(_ p: Program, _ w: Workout) {
        addExercise(p, w, make("Power Pendlay Row", "Pendlay Row",                    "Power", weights: "Dual Lower Plates", weight: 135))
        addExercise(p, w, make("Pull-up",           "Pull-up",                        "2x6-10", weights: "Single Lower Plates no bar", weight: 10))
        addExercise(p, w, make("Rack Chin-up",      "Rack Chin-up",                   "2x6-10"))
        addExercise(p, w, make("Power DB Bench",    "Dumbbell Bench Press",           "Power", weights: "Dumbbells", weight: 60))
        addExercise(p, w, make("Dips",              "Dips",                           "2x6-10", weights: "Single Lower Plates no bar", weight: 20))
        addExercise(p, w, make("DB Shoulder Press", "Dumbbell Seated Shoulder Press", "3x6-10", weights: "Dumbbells", weight: 40))
        addExercise(p, w, make("Preacher Curl",     "Preacher Curl",                  "3x6-10", weights: "Dual Upper Plates", weight: 10))
        addExercise(p, w, make("Skull Crushers",    "Skull Crushers",                 "3x6-10", weights: "Dumbbells", weight: 10))
    }
    
    private func buildLowerPowerWorkout(_ p: Program, _ w: Workout) {
        addExercise(p, w, make("Power Squat", "Low bar Squat", "Power", weights: "Dual Lower Plates", weight: 165))
        
        // In general we don't want to mess with groups here because there's just too much
        // and they get annoying with other exercises. But hack squat machiness are relatively
        // uncommon so we'll allow users to swap those out.
        addGroup(p, w, makeSquat("Hack Squat", style: "2x6-10", suffix: " 1"))

        addExercise(p, w, make("Leg Extensions",           "Leg Extensions",        "2x6-10", weights: "Cable Machine", weight: 30))
        addExercise(p, w, make("Power Stiff-Leg Deadlift", "Stiff-Legged Deadlift", "Power", weights: "Dual Lower Plates", weight: 250))
        addExercise(p, w, make("Glute Ham Raise",          "Glute Ham Raise",       "2x6-10", weights: "Single Lower Plates no bar", weight: 10))
        addExercise(p, w, make("Standing Calf Raises",     "Standing Calf Raises",  "3x6-10", weights: "Dual Lower Plates no bar", weight: 135))
        addExercise(p, w, make("Seated Calf Raises",       "Seated Calf Raises",    "2x6-10", weights: "Dual Lower Plates no bar", weight: 80))
    }

    private func buildBackWorkout(_ p: Program, _ w: Workout) {
        addExercise(p, w, make("Speed Pendlay Row", "Pendlay Row",                    "Speed", weights: "Dual Lower Plates", base: .other))
        addExercise(p, w, make("Rack Chin-up",      "Rack Chin-up",                   "3x8-12"))
        addExercise(p, w, make("Cable Row",         "Seated Cable Row",               "3x8-12", weights: "Cable Machine", weight: 50))
        addExercise(p, w, make("Kroc Row",          "Kroc Row",                       "2x12-15", weights: "Dumbbells", weight: 70))
        addExercise(p, w, make("Cable Pulldowns",   "Underhand Cable Pulldowns",      "2x15-20", weights: "Cable Machine", weight: 30))
        addExercise(p, w, make("DB Shoulder Press", "Dumbbell Seated Shoulder Press", "3x8-12", weights: "Dumbbells", weight: 40))
        addExercise(p, w, make("Upright Row",       "Upright Row",                    "2x12-15", weights: "Dual Upper Plates", weight: 20))
        addExercise(p, w, make("Lateral Raise",     "Side Lateral Raise",             "3x12-20", weights: "Dumbbells", weight: 10))
    }

    private func buildLowerWorkout(_ p: Program, _ w: Workout) {
        addExercise(p, w, make("Speed Squat",        "Low bar Squat",     "Speed", weights: "Dual Lower Plates", base: .other))
        addGroup(p, w, makeSquat("Hack Squat", style: "3x8-12", suffix: " 1"))
        addExercise(p, w, make("Leg Press",          "Leg Press",          "2x12-15", weights: "Dual Lower Plates no bar", base: .other))
        addExercise(p, w, make("Leg Extensions",     "Leg Extensions",     "3x15-20", weights: "Cable Machine", weight: 40))
        addExercise(p, w, make("Romanian Deadlift",  "Romanian Deadlift",  "3x8-12", weights: "Dual Lower Plates", weight: 250))
        addExercise(p, w, make("Lying Leg Curls",    "Lying Leg Curls",    "2x12-15", weights: "Cable Machine", weight: 40))
        addExercise(p, w, make("Seated Leg Curl",    "Seated Leg Curl",    "2x15-20", weights: "Cable Machine", weight: 40))
        addExercise(p, w, make("Donkey Calf Raises", "Donkey Calf Raises", "4x10-25"))
        addExercise(p, w, make("Seated Calf Raises", "Seated Calf Raises", "3x15-20", weights: "Cable Machine", weight: 50))
    }

    private func buildChestWorkout(_ p: Program, _ w: Workout) {
        addExercise(p, w, make("Speed DB Bench",       "Dumbbell Bench Press",      "Speed", weights: "Dumbbells", base: .other))
        addExercise(p, w, make("DB Incline Press",     "Dumbbell Incline Press",    "3x8-12", weights: "Dumbbells", weight: 40))
        addExercise(p, w, make("Chest Press Machine",  "Chest Press Machine",       "3x12-15", weights: "Dual Upper Plates no bar", weight: 50))
        addExercise(p, w, make("Incline Cable Flye",   "Incline Cable Flye",        "2x15-20", weights: "Cable Machine", weight: 20))
        addExercise(p, w, make("Preacher Curl",        "Preacher Curl",             "3x8-12", weights: "Dual Upper Plates", weight: 10))
        addExercise(p, w, make("Concentration Curls",  "Concentration Curls",       "2x12-15", weights: "Dumbbells", weight: 10))
        addExercise(p, w, make("Spider Curls",         "Spider Curls",              "2x15-20", weights: "Dumbbells", weight: 10))
        addExercise(p, w, make("Seated Triceps Press", "Seated Triceps Press",      "3x8-12", weights: "Dumbbells", weight: 20))
        addExercise(p, w, make("Triceps Pushdown",     "Triceps Pushdown (rope)",   "2x12-15", weights: "Cable Machine", weight: 40))
        addExercise(p, w, make("Cable Kickback",       "One-Legged Cable Kickback", "2x15-20", weights: "Cable Machine", weight: 30))
    }
}

final class MaleAestheticBuilder: Builder {
    override var name: String {return "Aesthetic"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(count: 2), .weekly(count: 3), .weekly(count: 4), .weekly(count: 6)]}

    override var defaultSchedule: Int {return 1}

    override func build(_ program: Program) {
        program.summary = "Push/Pull/Leg program with an emphasis on upper body. The 2 and 4 day/week versions omit leg day."
        
        program.styles["Primary"]   = variableStyle(warmup: "5/60 3/80 1/90", workset: "4-8 4-8 4-8", rest: "3m")
        program.styles["Accessory"] = variableStyle(warmup: "", workset: "8-12 8-12 8-12", rest: "90s")
        program.styles["Plank"]     = durationsStyle(secs: "60 60 60", targetSecs: "")

        scheduleWorkouts(program)
        initGroups(program)
    }
    
    private func scheduleWorkouts(_ program: Program) {
        switch wizard.schedule {
        case .weekly(let days) where days == 2:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Push", schedule)
            buildPushWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("Pull", schedule)
            buildPullWorkout(program, workout)
            program.addWorkout(workout)
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
        case .weekly(let days) where days == 4:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Push", schedule)
            buildPushWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.tuesday]))
            workout = Workout("Pull", schedule)
            buildPullWorkout(program, workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("Push", schedule)
            buildPushWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Pull", schedule)
            buildPullWorkout(program, workout)
            program.addWorkout(workout)
        case .weekly(let days) where days == 6:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Push", schedule)
            buildPushWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.tuesday]))
            workout = Workout("Pull", schedule)
            buildPullWorkout(program, workout)
            program.addWorkout(workout)
                        
            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("Legs", schedule)
            buildLegWorkout(program, workout)

            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("Push", schedule)
            buildPushWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Pull", schedule)
            buildPullWorkout(program, workout)
            program.addWorkout(workout)
                        
            schedule = Schedule.days(Weekdays([.saturday]))
            workout = Workout("Legs", schedule)
            buildLegWorkout(program, workout)
        default:
            fatalError("\(wizard.schedule) shouldn't have happened")
        }
    }
    
    private func buildPushWorkout(_ p: Program, _ w: Workout) {
        if wizard.barbells {
            addGroup(p, w, makeBench("Bench Press", style: "Primary"))
            addGroup(p, w, makeOHP("Overhead Press", style: "Primary"))
        } else if wizard.fullDumbbells {
            addGroup(p, w, makeBench("Dumbbell Bench Press", style: "Primary"))
            addGroup(p, w, makeOHP("Dumbbell Shoulder Press", style: "Primary"))
        } else {
            addGroup(p, w, makeBench("Chest Press Machine", style: "Primary"))
            addGroup(p, w, makeOHP("Machine Shoulder Press", style: "Primary"))
        }

        if wizard.fullDumbbells {
            addGroup(p, w, makeCurl("Concentration Curls", style: "Accessory"))
        } else if wizard.machines {
            addGroup(p, w, makeCurl("Cable Hammer Curls", style: "Accessory"))
        } else {
            addGroup(p, w, makeCurl("Barbell Curl", style: "Accessory"))
        }
        addExercise(p, w, make("Dips", "Dips", "Accessory", weights: "Single Upper Plates no bar", weight: 0))
    }
    
    private func buildPullWorkout(_ p: Program, _ w: Workout) {
        if wizard.fullDumbbells {
            addGroup(p, w, makeRow("Kroc Row", style: "Primary"))
        } else if wizard.barbells {
            addGroup(p, w, makeRow("Pendlay Row", style: "Primary"))
        } else {
            addGroup(p, w, makeRow("Seated Cable Row", style: "Primary"))
        }
        
        addGroup(p, w, makePullup("Pull-up", style: "Accessory"))

        if wizard.fullDumbbells {
            addGroup(p, w, makeCurl("Spider Curls", style: "Accessory"))
        } else if wizard.machines {
            addGroup(p, w, makeCurl("Cable Hammer Curls", style: "Accessory"))
        } else {
            addGroup(p, w, makeCurl("Barbell Curl", style: "Accessory"))
        }

        if wizard.fullDumbbells {
            addExercise(p, w, make("Lateral Raise", "Side Lateral Raise", "Accessory", weights: "Dumbbells", weight: 5))
        } else if wizard.machines {
            addExercise(p, w, make("Cable Wood Chop", "Cable Wood Chop", "Accessory", weights: "Cable Machine", weight: 20))
        }

        if wizard.barbells {
            addExercise(p, w, make("Shrug", "Barbell Shrug", "Accessory", weights: "Dual Upper Plates", weight: 45 + 2*25))
        } else if wizard.fullDumbbells {
            addExercise(p, w, make("DB Shrug", "Dumbbell Shrug", "Accessory", weights: "Dumbbells", weight: 30))
        } else {
            addExercise(p, w, make("Pec Deck Fly", "Pec Deck Fly", "Accessory", weights: "Cable Machine", weight: 40))
        }
    }

    private func buildLegWorkout(_ p: Program, _ w: Workout) {
        if wizard.barbells {
            addGroup(p, w, makeDeadlift("American Deadlift", style: "Primary"))
        } else if wizard.fullDumbbells {
            addGroup(p, w, makeDeadlift("Dumbbell Deadlift", style: "Primary"))
        } else {
            addGroup(p, w, makeDeadlift("Smith Deadlift", style: "Primary"))
        }
        
        if wizard.machines {
            addGroup(p, w, makeSquat("Leg Press", style: "Primary"))
        } else {
            addExercise(p, w, make("Back Extension", "Back Extension", "Accessory", weights: "Single Lower Plates no bar", weight: 25))
        }

        addGroup(p, w, makeAbs("Ab Wheel Rollout", style: "Accessory"))
        addGroup(p, w, makePullup("Pull-up", style: "Accessory"))
    }
}

final class FemaleAestheticBuilder: Builder {
    override var name: String {return "Aesthetic"}
    
    override var schedules: [Wizard.Schedule] {return [.weekly(count: 2), .weekly(count: 3)]}

    override var defaultSchedule: Int {return 1}

    override func build(_ program: Program) {
        program.summary = "A program with a focus on lower body exercises. The two day version omits upper body work."
        
        program.styles["Primary"]   = variableStyle(warmup: "5/60 3/80 1/90", workset: "4-8 4-8 4-8", rest: "3m")
        program.styles["Accessory"] = variableStyle(warmup: "", workset: "8-12 8-12 8-12", rest: "90s")
        program.styles["Plank"]     = durationsStyle(secs: "60 60 60", targetSecs: "")

        scheduleWorkouts(program)
        initGroups(program)
    }
    
    private func scheduleWorkouts(_ program: Program) {
        switch wizard.schedule {
        case .weekly(let days) where days == 2:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Squat", schedule)
            buildSquatWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.thursday]))
            workout = Workout("Deadlift", schedule)
            buildDeadliftWorkout(program, workout)
            program.addWorkout(workout)
        case .weekly(let days) where days == 3:
            var schedule = Schedule.days(Weekdays([.monday]))
            var workout = Workout("Squat", schedule)
            buildSquatWorkout(program, workout)
            program.addWorkout(workout)
            
            schedule = Schedule.days(Weekdays([.wednesday]))
            workout = Workout("Upper", schedule)
            buildUpperWorkout(program, workout)
            program.addWorkout(workout)

            schedule = Schedule.days(Weekdays([.friday]))
            workout = Workout("Deadlift", schedule)
            buildDeadliftWorkout(program, workout)
            program.addWorkout(workout)
        default:
            fatalError("\(wizard.schedule) shouldn't have happened")
        }
    }
    
    private func buildSquatWorkout(_ p: Program, _ w: Workout) {
        if wizard.barbells {
            addGroup(p, w, makeSquat("High Bar Squat", style: "Primary"))
        } else if wizard.fullDumbbells {
            addGroup(p, w, makeSquat("Split Squat", style: "Primary"))
        } else {
            addGroup(p, w, makeSquat("Smith Squat", style: "Primary"))
        }
        addGroup(p, w, makeAbs("Ab Wheel Rollout", style: "Accessory"))
        if wizard.machines {
            addExercise(p, w, make("Seated Adduction", "Seated Hip Adduction", "Accessory", weights: "Cable Machine", weight: 20))
        } else if wizard.fullDumbbells {
            addExercise(p, w, make("DB Side Bend", "Dumbbell Side Bend", "Accessory", weights: "Dumbbells", weight: 10))
        }
        if wizard.barbells {
            addExercise(p, w, make("Hip Thrust", "Hip Thrust", "Primary", weights: "Dual Lower Plates", weight: 45 + 2*25))
        } else if wizard.fullDumbbells {
            addExercise(p, w, make("Step-ups", "Step-ups", "Accessory", weights: "Dumbbells", weight: 20))
        } else {
            addExercise(p, w, make("Step-ups", "Step-ups", "Accessory"))
        }
    }
    
    private func buildUpperWorkout(_ p: Program, _ w: Workout) {
        if wizard.barbells {
            addGroup(p, w, makeBench("Bench Press", style: "Primary"))
            addGroup(p, w, makeOHP("Overhead Press", style: "Primary"))
        } else if wizard.fullDumbbells {
            addGroup(p, w, makeBench("Dumbbell Bench Press", style: "Primary"))
            addGroup(p, w, makeOHP("Dumbbell Shoulder Press", style: "Primary"))
        } else {
            addGroup(p, w, makeBench("Chest Press Machine", style: "Primary"))
            addGroup(p, w, makeOHP("Machine Shoulder Press", style: "Primary"))
        }

        if wizard.machines {
            addGroup(p, w, makeRow("Seated Cable Row", style: "Primary"))
        } else if wizard.barbells {
            addGroup(p, w, makeRow("Pendlay Row", style: "Primary"))
        } else {
            addGroup(p, w, makeRow("Kroc Row", style: "Primary"))
        }

        addGroup(p, w, makeAbs("Hanging Leg Raise", style: "Accessory"))
    }

    private func buildDeadliftWorkout(_ p: Program, _ w: Workout) {
        if wizard.barbells {
            addGroup(p, w, makeDeadlift("American Deadlift", style: "Primary"))
        } else if wizard.fullDumbbells {
            addGroup(p, w, makeDeadlift("Dumbbell Deadlift", style: "Primary"))
        } else {
            addGroup(p, w, makeDeadlift("Smith Deadlift", style: "Primary"))
        }

        if wizard.machines {
            addExercise(p, w, make("Seated Leg Curl", "Seated Leg Curl", "Accessory", weights: "Cable Machine", weight: 30))
        } else if wizard.fullDumbbells {
            addGroup(p, w, makeDeadlift("Dumbbell Romanian Deadlift", style: "Primary"))
        } else {
            addExercise(p, w, make("Back Extension", "Back Extension", "Accessory", weights: "Single Lower Plates no bar", weight: 20))
        }

        if wizard.machines {
            addExercise(p, w, make("Hip Abduction", "Seated Hip Abduction", "Accessory", weights: "Cable Machine", weight: 20))
        } else if wizard.fullDumbbells {
            addExercise(p, w, make("Step-ups", "Step-ups", "Accessory", weights: "Dumbbells", weight: 20))
        } else {
            addExercise(p, w, make("Step-ups", "Step-ups", "Accessory"))
        }

        if wizard.machines {
            addExercise(p, w, make("Cable Kickback", "One-Legged Cable Kickback", "Accessory", weights: "Cable Machine", weight: 20))
        } else {
            addExercise(p, w, make("Lying Leg Curls", "Lying Leg Curls", "Accessory"))
        }
    }
}

