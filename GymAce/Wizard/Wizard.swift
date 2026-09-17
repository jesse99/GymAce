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
        if barbells || numDumbbells > 0 || machines {
            // User has equipment, so we can generate a program with weights.
            if case .conditioning = goal, numDumbbells > 0 {
                program = makeComplex()
            } else if !barbells && !machines && numDumbbells > 0 && numDumbbells <= 3 {
                // User has only a few dumbbells, so we will generate a complex program.
                program = makeComplex()
            } else {
                program =  makeStub()   // TODO handle these cases
            }
        } else {
            // User has no equipment, so we will generate a bodyweight program.
            program = makeBW()
        }
        if !program.valid(model) {
            fatalError("bad program")   // TODO handle this better, e.g. show an error message
        }
        model.programs.append(program)
        model.activeProgram = program.name
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
    
        program.styles["Complex"] = basicStyle(warmup: "", workset: "1 1 1", rest: "90s")  // TODO add a manual style

        let exercise = if case .beginner = fitness {
            make("Complex", "Complex - beginner", "Complex", weights: "Dumbbells", weight: 5)
        } else {
            make("Complex", "Complex - intermediate", "Complex", weights: "Dumbbells", weight: 10)
        }
        program.exercises.append(exercise)
    
        // TODO would be nice to support cycle, eg every pther day
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
