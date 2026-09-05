import Foundation
import SwiftUI
import Testing
@testable import GymAce

//enum Style: Codable {
//    case percent(PercentInfo)
//    case double_progression(DoubleProgressionInfo)
//    case durations(DurationsInfo)
//    case missing
class PlanTests {
    @Test("TimedPlan")
    func timed() {
        exercise = make("Walk", "Walking", "Walk")
        var plan = makePlan()
        #expect(plan.details(exercise) == "")
        #expect(to_headers(plan) == "Set 1 of 1/-/-/-")
        #expect(completed() == "0 secs")

        exercise = make("Walk", "Walking", "Walk", weight: 130)
        plan = makePlan()
        #expect(plan.details(exercise) == "130")    // no weight set so no units
        #expect(to_headers(plan) == "Set 1 of 1/130/-/-")
        #expect(completed() == "0 secs")

        exercise = make("Walk", "Walking", "Walk", weights: "Dumbbells", weight: 28)
        plan = makePlan()
        #expect(plan.details(exercise) == "25 lbs") // work sets use lower (unless the percent is under 100)
        #expect(to_headers(plan) == "Set 1 of 1/25 lbs/-/-")
        #expect(completed() == "0 secs")

        exercise = make("Walk", "Walking", "Walk")
        plan = makePlan(daysAgo: 2, secs: [60*60])
        #expect(plan.details(exercise) == "60.0 mins")
        #expect(to_headers(plan) == "Set 1 of 1/-/-/-")

        exercise = make("Walk", "Walking", "Walk")
        plan = makePlan(daysAgo: 2, secs: [2*60*60])
        #expect(plan.details(exercise) == "2.0 hours")
        #expect(to_headers(plan) == "Set 1 of 1/-/-/-")
    }
    
    private func makePlan(daysAgo: Int? = nil, reps: [Int]? = nil, secs: [Int]? = nil, weights: [Float]? = nil) -> ExercisePlan {
        model = Model()

        program = Program("Test Program")
        program.styles["Walk"] = Style.timed

        let schedule = Schedule.days(Weekdays([.monday]))
        workout = Workout("Test Workout", schedule)
        program.addWorkout(workout)

        model.programs.append(program)
        model.activeProgram = program.name
        
        program.exercises.append(exercise)
        workout.addExercise(name: exercise.name)
        model.addMissingWeightsets()
        
        if let reps = reps {
            addCompleted(exercise, daysAgo: daysAgo!, reps: reps, weights: weights)
        }
        if let secs = secs {
            addCompleted(exercise, daysAgo: daysAgo!, secs: secs, weights: weights)
        }

        return ExercisePlan(model, program, workout, exercise)
    }

    private func to_headers(_ plan: ExercisePlan) -> String {
        var headers: [String] = []
        let entry = workout.entries.first(where: {$0.name == exercise.name})!
        entry.started(model, program, workout, exercise)
        headers.append(to_headers(plan, entry))
        
        while !entry.isFinished(program, exercise) {
            entry.completedSet(plan)
            if entry.isFinished(program, exercise) {
                entry.completedLast(program, workout, exercise)
                entry.mode = .finished
            } else {
                entry.mode = .performing
                headers.append(to_headers(plan, entry))
            }
        }

        return headers.joined(separator: ", ")
    }

    private func to_headers(_ plan: ExercisePlan, _ entry: ExerciseEntry) -> String {
        var headers: [String] = []
        
        var h = entry.headline(plan)
        if !h.isEmpty {
            headers.append(h)
        } else {
            headers.append("-")
        }
        h = entry.subhead(plan, model, program, workout, exercise)
        if !h.isEmpty {
            headers.append(h)
        } else {
            headers.append("-")
        }
        h = entry.footer(plan) ?? ""
        if !h.isEmpty {
            headers.append(h)
        } else {
            headers.append("-")
        }
        h = entry.subfooter(plan, model, program, exercise) ?? ""
        if !h.isEmpty {
            headers.append(h)
        } else {
            headers.append("-")
        }
        
        return headers.joined(separator: "/")
    }
    
    private func completed() -> String {
        let c = exercise.history.map {$0.details()}
        return c.joined(separator: ", ")
    }

    private var model: Model! = nil
    private var program: Program! = nil
    private var workout: Workout! = nil
    private var exercise: Exercise! = nil
}
