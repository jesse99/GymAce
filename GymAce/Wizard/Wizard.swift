/// Used to generate a new program according to user input.
final class Wizard {
    enum Apparatus {
        /// User has barbells
        case barbells
        case dumbbels(Int)
        case machines
        case smith
    }
    
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
    
    enum Schedule {
        /// Number of days per week to do the program.
        case weekly(Int)

        /// Number of days in a row to do the workouts before repeating (some of the workouts will be rest days).
        case cycle(Int)

        /// Workouts are done as part of an N week block of workouts, e.g. weight percents may ramp up during the block.
        case block(Int)
    }
    
    var goal: Goal              // these affect the program type, eg basic or gzcl
    var fitness: Fitness
    
    var barbells: Bool          // for the most part these just affect exercise selection
    var numDumbbells: Int       // but if all they have are one or two dumbbells then we'll just use a complex
    var machines: Bool
    var smith: Bool
    
    var age: Int                // can affect volume
    var schedule: Schedule      // set after we create a program but before we populate it with workouts
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
        self.schedule = .weekly(3)
    }
    
    func build() -> Builder {
        var builder: Builder
        let enoughDumbbells = numDumbbells > 5
        if barbells || enoughDumbbells || machines {
            // User has equipment, so we can generate a program with weights.
            switch fitness {
            case .beginner:
                switch goal {
                case .strength, .hypertrophy, .glute:
                    if barbells {
                        builder = BasicBarbellBuilder(self)
                    } else if enoughDumbbells {
                        if case .hypertrophy = goal {
                            builder = BasicPPLDBBuilder(self)
                        } else {
                            builder = BasicStopgapDBBuilder(self)
                        }
                    } else if smith {
                        builder = BasicSmithBuilder(self)
                    } else {    // TODO verify links in notes
                        builder = BasicMachineBuilder(self)
                    }
                case .conditioning:
                    if numDumbbells > 0 {
                        builder = ComplexBuilder(self)
                    } else {
                        builder = StubBuilder(self)   // TODO use one of A8, B8, or F8?
                    }
                }
            case .intermediate, .advanced:  // TODO for now we handle advanced like intermediate
                switch goal {
                case .strength:
                    builder = StubBuilder(self)   // TODO gzcl style, may want to allow them to select between different base routines
                case .hypertrophy:
                    builder = StubBuilder(self)   // TODO ppl style? or boring but big? or PHAT? may want to allow them to select between different base routines
                case .glute:
                    builder = StubBuilder(self)   // TODO gzcl style (tweak exercises)
                case .conditioning:
                    builder = ComplexBuilder(self)
                }
            }
        } else if numDumbbells > 0 {
            // User has only a few dumbbells, so we will generate a complex program.
            builder = ComplexBuilder(self)
        } else {
            // User has no equipment, so we will generate a bodyweight program.
            builder = StubBuilder(self)   // TODO
        }
        
        return builder
    }

    func generate(_ builder: Builder) {
        let name = findName(hasName, prefix: builder.name)
        let program = Program(name)
        schedule = builder.schedules[0] // TODO user needs to select this
        builder.build(program)
        
        model.programs.append(program)
        model.activeProgram = program.name
        model.addMissingWeightsets()

        if !program.valid(model) {      // TODO this should probably check links
            fatalError("bad program")   // TODO handle this better, e.g. show an error message
        }
    }
    
    private func hasName(_ name: String) -> Bool {
        return model.programs.contains(where: {$0.name == name})
    }
}

// TODO may want a unit test to verify that each combo results in the right program name and that it validates
