import Foundation
import SwiftUI
import Testing
@testable import GymAce

struct WizardTests {
    @Test("Valid")
    func valid() {
        for goal in [Wizard.Goal.strength, Wizard.Goal.bodybuilding, Wizard.Goal.aesthetic, Wizard.Goal.conditioning] {
            for fitness in [Wizard.Fitness.beginner, Wizard.Fitness.intermediate, Wizard.Fitness.advanced] {
                for age in [20, 50, 60, 80] {
                    // no apparatus
                    var model = Model()
                    var wizard = Wizard(model)
                    wizard.goal = goal
                    wizard.fitness = fitness
                    wizard.age = age
                    wizard.barbells = false
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = false
                    wizard.machines = false
                    wizard.smith = false
                    #expect(validProgram(model, wizard))
                    
                    // one apparatus
                    model = Model()
                    wizard = Wizard(model)
                    wizard.goal = goal
                    wizard.fitness = fitness
                    wizard.age = age
                    wizard.barbells = true
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = false
                    wizard.machines = false
                    wizard.smith = false
                    #expect(validProgram(model, wizard))
                    
                    model = Model()
                    wizard = Wizard(model)
                    wizard.goal = goal
                    wizard.fitness = fitness
                    wizard.age = age
                    wizard.barbells = false
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = true
                    wizard.machines = false
                    wizard.smith = false
                    #expect(validProgram(model, wizard))
                    
                    model = Model()
                    wizard = Wizard(model)
                    wizard.goal = goal
                    wizard.fitness = fitness
                    wizard.age = age
                    wizard.barbells = false
                    wizard.fullDumbbells = true
                    wizard.partialDumbbells = false
                    wizard.machines = false
                    wizard.smith = false
                    #expect(validProgram(model, wizard))
                    
                    model = Model()
                    wizard = Wizard(model)
                    wizard.goal = goal
                    wizard.fitness = fitness
                    wizard.age = age
                    wizard.barbells = false
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = false
                    wizard.machines = true
                    wizard.smith = false
                    #expect(validProgram(model, wizard))
                    
                    model = Model()
                    wizard = Wizard(model)
                    wizard.goal = goal
                    wizard.fitness = fitness
                    wizard.age = age
                    wizard.barbells = false
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = false
                    wizard.machines = false
                    wizard.smith = true
                    #expect(validProgram(model, wizard))
                    
                    // multiple apparatus
                    model = Model()
                    wizard = Wizard(model)
                    wizard.goal = goal
                    wizard.fitness = fitness
                    wizard.age = age
                    wizard.barbells = true
                    wizard.fullDumbbells = true
                    wizard.partialDumbbells = false
                    wizard.machines = true
                    wizard.smith = true
                    #expect(validProgram(model, wizard))
                    
                    model = Model()
                    wizard = Wizard(model)
                    wizard.goal = goal
                    wizard.fitness = fitness
                    wizard.age = age
                    wizard.barbells = true
                    wizard.fullDumbbells = true
                    wizard.partialDumbbells = false
                    wizard.machines = false
                    wizard.smith = false
                    #expect(validProgram(model, wizard))
                    
                    model = Model()
                    wizard = Wizard(model)
                    wizard.goal = goal
                    wizard.fitness = fitness
                    wizard.age = age
                    wizard.barbells = false
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = false
                    wizard.machines = true
                    wizard.smith = true
                    #expect(validProgram(model, wizard))
                }
            }
        }
    }
    
    private func validProgram(_ model: Model, _ wizard: Wizard) -> Bool {
        let builder = wizard.build()
        for schedule in builder.schedules {
            let program = Program(builder.name)
            wizard.schedule = schedule
            builder.build(program)
            updateGroups(program, wizard)
            builder.initGroups(program)
            
            builder.fixup(program)
            model.programs.append(program)
            model.activeProgram = program.name
            model.addMissingWeightsets()
            
            if let s = findAllIssues(model, program) {
                print(s)
                model.programs = []
                return false
            }
            model.programs = []
        }
        return true
    }
    
    private func findAllIssues(_ model: Model, _ program: Program) -> String? {
        var issues = ""

        if let s = program.findIssues(model) {
            issues += "program: \(program.name) \(s)\n"
        }
        
        for w in program.workouts {
            if let s = w.findIssues(model, program) {
                issues += "program: \(program.name) workout: \(w.name) \(s)\n"
            }
        }

        for e in program.exercises {
            if let s = e.findIssues(model, program) {
                issues += "program: \(program.name) exercise: \(e.name) \(s)\n"
            }
        }
        
        return issues.isEmpty ? nil : issues
    }
}
