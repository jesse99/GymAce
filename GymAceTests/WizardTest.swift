import Foundation
import SwiftUI
import Testing
@testable import GymAce

struct WizardTests {
    @Test("Valid")
    func valid() {
        for goal in [Wizard.Goal.strength, Wizard.Goal.hypertrophy, Wizard.Goal.glute, Wizard.Goal.conditioning] {
            for fitness in [Wizard.Fitness.beginner, Wizard.Fitness.intermediate, Wizard.Fitness.advanced] {
                for age in [20, 50, 60, 80] {
                    var model = Model()
                    var wizard = Wizard(model)
                    wizard.goal = goal
                    wizard.fitness = fitness
                    wizard.age = age
                    
                    // no apparatus
                    model = Model()
                    wizard = Wizard(model)
                    wizard.barbells = false
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = false
                    wizard.machines = false
                    wizard.smith = false
                    #expect(validProgram(model, wizard))

                    // one apparatus
                    model = Model()
                    wizard = Wizard(model)
                    wizard.barbells = true
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = false
                    wizard.machines = false
                    wizard.smith = false
                    #expect(validProgram(model, wizard))

                    model = Model()
                    wizard = Wizard(model)
                    wizard.barbells = false
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = true
                    wizard.machines = false
                    wizard.smith = false
                    #expect(validProgram(model, wizard))

                    model = Model()
                    wizard = Wizard(model)
                    wizard.barbells = false
                    wizard.fullDumbbells = true
                    wizard.partialDumbbells = false
                    wizard.machines = false
                    wizard.smith = false
                    #expect(validProgram(model, wizard))

                    model = Model()
                    wizard = Wizard(model)
                    wizard.barbells = false
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = false
                    wizard.machines = true
                    wizard.smith = false
                    #expect(validProgram(model, wizard))

                    model = Model()
                    wizard = Wizard(model)
                    wizard.barbells = false
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = false
                    wizard.machines = false
                    wizard.smith = true
                    #expect(validProgram(model, wizard))

                    // multiple apparatus
                    model = Model()
                    wizard = Wizard(model)
                    wizard.barbells = true
                    wizard.fullDumbbells = true
                    wizard.partialDumbbells = false
                    wizard.machines = true
                    wizard.smith = true
                    #expect(validProgram(model, wizard))

                    model = Model()
                    wizard = Wizard(model)
                    wizard.barbells = true
                    wizard.fullDumbbells = true
                    wizard.partialDumbbells = false
                    wizard.machines = false
                    wizard.smith = false
                    #expect(validProgram(model, wizard))

                    model = Model()
                    wizard = Wizard(model)
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
            let program = Program("test")
            wizard.schedule = schedule
            builder.build(program)
            
            model.programs.append(program)
            model.activeProgram = program.name
            model.addMissingWeightsets()

            if !program.valid(model) {
                return false
            }
            model.programs = []
        }
        return true
    }
}
