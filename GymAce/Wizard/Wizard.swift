import Foundation
import SwiftUI

/// Used to generate a new program according to user input.
@Observable
final class Wizard {
    enum Stage: Int, Comparable, CaseIterable {    // used by views to show one page of the wizard
        case apparatus = 1
        case goal = 2
        case schedule = 3
        case group = 4
        
        static func < (lhs: Stage, rhs: Stage) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    enum Apparatus {
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
    
    enum Schedule: Comparable {
        /// Number of days per week to do the program.
        case weekly(Int)

        /// Number of days in a row to do the workouts before repeating (some of the workouts will be rest days).
        case cycle(Int)

        /// Workouts are done as part of an N week block of workouts, e.g. weight percents may ramp up during the block.
        case block(Int)
        
        func toString() -> String {
            switch self{
            case .weekly(let days): "\(days) days/week"
            case .cycle(let days): "\(days) day cycle"
            case .block(let weeks): "\(weeks) week block"
            }
        }
    }
        
    var goal: Goal              // these affect the program type, eg basic or gzcl
    var fitness: Fitness
    var male: Bool
    
    var barbells: Bool          // for the most part these just affect exercise selection
    var fullDumbbells: Bool     // user has plenty of dumbbells
    var partialDumbbells: Bool  // user has a limited selection of dumbbells
    var machines: Bool
    var smith: Bool
    
    var age: Int                // can affect volume
    var schedule: Schedule      // set after we can create a program
    let model: Model
    
    init(_ model: Model) {
        self.model = model
        self.age = 20
        self.barbells = true
        self.fullDumbbells = true
        self.partialDumbbells = false
        self.machines = true
        self.smith = true
        self.goal = .strength
        self.fitness = .beginner
        self.male = true
        self.schedule = .weekly(3)
    }
    
    func build() -> Builder {
        var builder: Builder
        if barbells || fullDumbbells || machines {
            // User has equipment, so we can generate a program with weights.
            switch fitness {
            case .beginner:
                switch goal {
                case .strength, .hypertrophy, .glute:
                    if barbells {
                        builder = BasicBarbellBuilder(self)
                    } else if fullDumbbells {
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
                    if fullDumbbells {
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
        } else if partialDumbbells {
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

