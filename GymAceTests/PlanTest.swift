import Foundation
import SwiftUI
import Testing
@testable import GymAce

class PlanTests {
    @Test("DoubleProgressPlan")
    func doubleProgress() {
        // Bench with AMRAP
        exercise = make("Bench", "Bench Press", "Main", weights: "Dual Plates", weight: 225)
        var plan = makePlan()
        #expect(plan.details(exercise) == "2x5, 5+ @ 225 lbs")
        
        var sets: [String] = []
        sets.append("Warmup 1 of 4/5 reps @ 45 lbs/-/-")                // 0.0 * 225 = 0.0
        sets.append("Warmup 2 of 4/5 reps @ 135 lbs/45/-")              // 0.6 * 225 = 135.0
        sets.append("Warmup 3 of 4/3 reps @ 180 lbs/45 + 10x2 + 2.5/-") // 0.8 * 225 = 180.0
        sets.append("Warmup 4 of 4/1 rep @ 205 lbs/45 + 25 + 10/-")     // 0.9 * 225 = 202.5
        sets.append("Workset 1 of 3/5 reps @ 225 lbs/45x2/-")
        sets.append("Workset 2 of 3/5 reps @ 225 lbs/45x2/-")
        sets.append("Workset 3 of 3/5+ reps @ 225 lbs/45x2/-")
        #expect(to_headers(plan) == sets.joined(separator: ", "))
        #expect(completed() == "5 reps x3 @ 225 lbs")
        
        // AMRAP with an old completed
        exercise = make("Bench", "Bench Press", "Main", weights: "Dual Plates", weight: 199)
        plan = makePlan(daysAgo: 2, reps: [5, 5, 7], weights: [195, 195, 195])
        #expect(plan.details(exercise) == "2x5, 7+ @ 195 lbs")  // same weight as last time so use the last AMRAP reps
        
        sets = []
        sets.append("Warmup 1 of 4/5 reps @ 45 lbs/-/-")                // 0.0 * 199 = 0.0
        sets.append("Warmup 2 of 4/5 reps @ 120 lbs/25 + 10 + 2.5/-")   // 0.6 * 199 = 119.4
        sets.append("Warmup 3 of 4/3 reps @ 160 lbs/45 + 10 + 2.5/-")   // 0.8 * 199 = 159.2
        sets.append("Warmup 4 of 4/1 rep @ 180 lbs/45 + 10x2 + 2.5/-")  // 0.9 * 199 = 179.1
        sets.append("Workset 1 of 3/5 reps @ 195 lbs/45 + 25 + 5/-")
        sets.append("Workset 2 of 3/5 reps @ 195 lbs/45 + 25 + 5/-")
        sets.append("Workset 3 of 3/7+ reps @ 195 lbs/45 + 25 + 5/-")
        #expect(to_headers(plan) == sets.joined(separator: ", "))
        #expect(completed() == "5 reps x2, 7 reps @ 195 lbs, 5 reps x2, 7 reps @ 195 lbs")

        // Variable reps
        exercise = make("Face Pulls", "Face Pull", "Accessory", weights: "Cable Machine", weight: 42.5)
        plan = makePlan()
        #expect(plan.details(exercise) == "3x8-12 @ 42.5 lbs")
        
        sets = []
        sets.append("Workset 1 of 3/8-12 reps @ 42.5 lbs/-/-")
        sets.append("Workset 2 of 3/8-12 reps @ 42.5 lbs/-/-")
        sets.append("Workset 3 of 3/8-12 reps @ 42.5 lbs/-/-")
        #expect(to_headers(plan) == sets.joined(separator: ", "))
        #expect(completed() == "8 reps x3 @ 42.5 lbs")

        // Variable reps with an old completed
        exercise = make("Face Pulls", "Face Pull", "Accessory", weights: "Cable Machine", weight: 42.5)
        plan = makePlan(daysAgo: 2, reps: [10, 10, 9], weights: [42.5, 42.5, 42.5])
        #expect(plan.details(exercise) == "2x10-12, 9-12 @ 42.5 lbs")
        
        sets = []
        sets.append("Workset 1 of 3/10-12 reps @ 42.5 lbs/-/-")
        sets.append("Workset 2 of 3/10-12 reps @ 42.5 lbs/-/-")
        sets.append("Workset 3 of 3/9-12 reps @ 42.5 lbs/-/-")
        #expect(to_headers(plan) == sets.joined(separator: ", "))
        #expect(completed() == "10 reps x2, 9 reps @ 42.5 lbs, 10 reps x2, 9 reps @ 42.5 lbs")

        // Variable reps with another old completed
        exercise = make("Face Pulls", "Face Pull", "Accessory", weights: "Cable Machine", weight: 42.5)
        plan = makePlan(daysAgo: 2, reps: [12, 12, 12], weights: [42.5, 42.5, 42.5])
        #expect(plan.details(exercise) == "3x12 @ 42.5 lbs")
        
        sets = []
        sets.append("Workset 1 of 3/12 reps @ 42.5 lbs/-/-")
        sets.append("Workset 2 of 3/12 reps @ 42.5 lbs/-/-")
        sets.append("Workset 3 of 3/12 reps @ 42.5 lbs/-/-")
        #expect(to_headers(plan) == sets.joined(separator: ", "))
        #expect(completed() == "12 reps x3 @ 42.5 lbs, 12 reps x3 @ 42.5 lbs")
    }
    
    @Test("DurationsPlan")
    func durations() {
        exercise = make("Quad Stretch", "Standing Quad Stretch", "Stretch1")
        var plan = makePlan()
        #expect(plan.details(exercise) == "30s")
        #expect(to_headers(plan) == "Workset 1 of 1/30 secs/-/-")
        #expect(completed() == "30 secs")

        exercise = make("Quad Stretch", "Standing Quad Stretch", "Stretch3")
        plan = makePlan()
        #expect(plan.details(exercise) == "30s, 40s, 50s")
        #expect(to_headers(plan) == "Workset 1 of 3/30 secs/-/-, Workset 2 of 3/40 secs/-/-, Workset 3 of 3/50 secs/-/-")
        #expect(completed() == "30 secs, 40 secs, 50 secs")

        exercise = make("Quad Stretch", "Standing Quad Stretch", "Stretch3b")
        plan = makePlan()
        #expect(plan.details(exercise) == "3x30s")
        #expect(to_headers(plan) == "Workset 1 of 3/30 secs/-/-, Workset 2 of 3/30 secs/-/-, Workset 3 of 3/30 secs/-/-")
        #expect(completed() == "30 secs x3")

        exercise = make("Quad Stretch", "Standing Quad Stretch", "Stretch3b", weights: "Dumbbells", weight: 25)
        plan = makePlan()
        #expect(plan.details(exercise) == "3x30s @ 25 lbs")
        #expect(to_headers(plan) == "Workset 1 of 3/30 secs @ 25 lbs/-/-, Workset 2 of 3/30 secs @ 25 lbs/-/-, Workset 3 of 3/30 secs @ 25 lbs/-/-")
        #expect(completed() == "30 secs x3 @ 25 lbs")
    }
    
    @Test("MissingPlan")
    func missing() {
        exercise = make("Walk", "Walking", "Bad")
        var plan = makePlan()
        #expect(plan.details(exercise) == "5 reps")
        #expect(to_headers(plan) == "Workset 1 of 1/5 reps/-/-")
        #expect(completed() == "5 reps")

        exercise = make("Walk", "Walking", "Bad", weight: 130)
        plan = makePlan()
        #expect(plan.details(exercise) == "5 @ 130")    // no weight set so no units
        #expect(to_headers(plan) == "Workset 1 of 1/5 reps @ 130/-/-")
        #expect(completed() == "5 reps @ 130")

        exercise = make("Walk", "Walking", "Bad", weights: "Dumbbells", weight: 28)
        plan = makePlan()
        #expect(plan.details(exercise) == "5 @ 25 lbs") // work sets use lower (unless the percent is under 100)
        #expect(to_headers(plan) == "Workset 1 of 1/5 reps @ 25 lbs/-/-")
        #expect(completed() == "5 reps @ 25 lbs")

        exercise = make("Walk", "Walking", "Bad")
        plan = makePlan(daysAgo: 2, secs: [60*60])
        #expect(plan.details(exercise) == "5 reps")
        #expect(to_headers(plan) == "Workset 1 of 1/5 reps/-/-")

        exercise = make("Walk", "Walking", "Bad")
        plan = makePlan(daysAgo: 2, secs: [2*60*60])
        #expect(plan.details(exercise) == "5 reps")
        #expect(to_headers(plan) == "Workset 1 of 1/5 reps/-/-")
    }
    
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
        program.styles["Accessory"] = .double_progression(DoubleProgressionInfo(warmup: "", workset: "8-12 8-12 8-12", rest: "2m")!)
        program.styles["Light"] = .percent(PercentInfo(percent: 0.9, rest: "2m")!)
        program.styles["Main"] = .double_progression(DoubleProgressionInfo(warmup: "5/0 5/60 3/80 1/90", workset: "5 5 5+", rest: "3m")!)
        program.styles["Stretch1"] = .durations(DurationsInfo(secs: "30s", targetSecs: "")!)
        program.styles["Stretch3"] = .durations(DurationsInfo(secs: "30s 40s 50s", targetSecs: "")!)
        program.styles["Stretch3b"] = .durations(DurationsInfo(secs: "30s 30s 30s", targetSecs: "60s")!)
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
