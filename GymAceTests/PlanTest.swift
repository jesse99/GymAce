import Foundation
import SwiftUI
import Testing
@testable import GymAce

class PlanTests {
    @Test("AMRAPPlan")
    func amrap() {
        // Bench with AMRAP
        exercise = make("Bench", "Bench Press", "AMRAP", weights: "Dual Plates", weight: 226)
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
        
        // GZCL style AMRAP
        exercise = make("Squat", "Squat", "GZCL", weights: "Dual Plates", weight: 226)
        plan = makePlan()
        #expect(plan.details(exercise) == "3, 2, 1+ @ 205 lbs-225 lbs")
        
        sets = []
        sets.append("Warmup 1 of 3/5 reps @ 135 lbs/45/-")
        sets.append("Warmup 2 of 3/3 reps @ 180 lbs/45 + 10x2 + 2.5/-")
        sets.append("Warmup 3 of 3/1 rep @ 205 lbs/45 + 25 + 10/-")
        sets.append("Workset 1 of 3/3 reps @ 205 lbs/45 + 25 + 10/-")
        sets.append("Workset 2 of 3/2 reps @ 215 lbs/45 + 25 + 10 + 5/-")
        sets.append("Workset 3 of 3/1+ reps @ 225 lbs/45x2/-")
        #expect(to_headers(plan) == sets.joined(separator: ", "))
        #expect(completed() == "3 reps, 2 reps, 1 reps @ 205-225 lbs")
        
        // Check progression
        exercise = make("Bench", "Bench Press", "AMRAP", weights: "Dual Plates", weight: 226)
        plan = makePlan()
        setCompleted([])
        #expect(exercise.progress(program) == 0)    // no completed
        
        let b = exercise.baseWeight!
        setCompleted([([5, 5, 2], nil)])
        #expect(exercise.progress(program) == -2)    // not enough reps
        
        setCompleted([([5, 5, 3], nil)])
        #expect(exercise.progress(program) == -2)    // not enough reps
        
        setCompleted([([5, 5], nil)])
        #expect(exercise.progress(program) == 0)    // not enough sets
        
        setCompleted([([5, 5, 5], nil)])
        #expect(exercise.progress(program) == 0)    // not enough reps
        
        setCompleted([([5, 5, 6], b - 10.0)])
        #expect(exercise.progress(program) == 0)    // not enough weight
        
        setCompleted([([5, 5, 6], nil)])
        #expect(exercise.progress(program) == 1)    // one extra rep

        setCompleted([([10, 10, 5], nil)])
        #expect(exercise.progress(program) == 3)    // one extra rep (earlier reps do matter)
        
        setCompleted([([2, 2, 7], nil)])
        #expect(exercise.progress(program) == 0)    // two extra reps (earlier reps do matter)
        
        setCompleted([([5, 5, 8], nil)])
        #expect(exercise.progress(program) == 3)    // three extra reps
        
        setCompleted([([5, 5, 9], nil)])
        #expect(exercise.progress(program) == 3)    // four extra reps
        
        setCompleted([([5, 5, 4], nil)])
        #expect(exercise.progress(program) == 0)    // one missed rep is OK

        setCompleted([([5, 5, 3], nil)])
        #expect(exercise.progress(program) == -2)    // not enough reps

        setCompleted([([5, 5, 4], nil),  ([5, 5, 5], nil),  ([5, 5, 5], nil)])
        #expect(exercise.progress(program) == -2)    // stuck too many times
    }
    
    @Test("BeginnerPlan")
    func beginner() {
        // Bench with AMRAP
        exercise = make("Bench", "Bench Press", "Beginner", weights: "Dual Plates", weight: 225)
        let plan = makePlan()
        #expect(plan.details(exercise) == "3x5 @ 225 lbs")
        
        var sets: [String] = []
        sets.append("Warmup 1 of 4/5 reps @ 45 lbs/-/-")                // 0.0 * 225 = 0.0
        sets.append("Warmup 2 of 4/5 reps @ 135 lbs/45/-")              // 0.6 * 225 = 135.0
        sets.append("Warmup 3 of 4/3 reps @ 180 lbs/45 + 10x2 + 2.5/-") // 0.8 * 225 = 180.0
        sets.append("Warmup 4 of 4/1 rep @ 205 lbs/45 + 25 + 10/-")     // 0.9 * 225 = 202.5
        sets.append("Workset 1 of 3/5 reps @ 225 lbs/45x2/-")
        sets.append("Workset 2 of 3/5 reps @ 225 lbs/45x2/-")
        sets.append("Workset 3 of 3/5 reps @ 225 lbs/45x2/-")
        #expect(to_headers(plan) == sets.joined(separator: ", "))
        #expect(completed() == "5 reps x3 @ 225 lbs")
        
        // Check progression
        setCompleted([])
        #expect(exercise.progress(program) == 0)    // no completed
        
        let b = exercise.baseWeight!
        setCompleted([([5, 5, 4], nil)])
        #expect(exercise.progress(program) == 0)    // not enough reps
        
        setCompleted([([4, 5, 5], nil)])
        #expect(exercise.progress(program) == 0)    // not enough reps
        
        setCompleted([([5, 5], nil)])
        #expect(exercise.progress(program) == 0)    // not enough sets
        
        setCompleted([([5, 5, 5], b - 10.0)])
        #expect(exercise.progress(program) == 0)    // not enough weight, weird case, maybe can happen if baseWeight is changed mid-exercise
        
        setCompleted([([5, 5, 5], nil)])
        #expect(exercise.progress(program) == 1)    // enough reps
        
        setCompleted([([6, 5, 5], nil)])
        #expect(exercise.progress(program) == 1)    // extra reps
        
        setCompleted([([6, 5, 5], b + 10.0)])
        #expect(exercise.progress(program) == 1)    // extra reps and extra weight
        
        setCompleted([([5, 5, 4], nil),  ([5, 5, 4], nil)])
        #expect(exercise.progress(program) == 0)    // not enough reps
        
        setCompleted([([5, 5, 2], b - 10.0),  ([5, 5, 3], nil),  ([5, 5, 4], nil)])
        #expect(exercise.progress(program) == 0)    // not enough reps too many times (but weights don't match)
        
        let c = b - 10.0
        setCompleted([([5, 5, 2], c),  ([5, 5, 3], c),  ([5, 5, 4], c)])
        #expect(exercise.progress(program) == 0)    // not enough reps too many times (but weights don't match)
        
        setCompleted([([5, 2, 1], nil)])
        #expect(exercise.progress(program) == -2)    // bad workouts can happen, but if it's really bad we'll drop weight

        setCompleted([([5, 5, 2], nil),  ([5, 5, 3], nil),  ([5, 5, 4], nil)])
        #expect(exercise.progress(program) == -2)    // not enough reps too many times
    }
    
    @Test("OneRepMaxPlan")
    func oneRepMax() {
        exercise = make("Bench", "Bench Press", "1RM", weights: "Dual Plates", weight: 225)
        let plan = makePlan()
        #expect(plan.details(exercise) == "5 @ 225 lbs")
        
        var sets: [String] = []
        sets.append("Warmup 1 of 4/5 reps @ 45 lbs/-/-")                // 0.0 * 225 = 0.0
        sets.append("Warmup 2 of 4/5 reps @ 135 lbs/45/-")              // 0.6 * 225 = 135.0
        sets.append("Warmup 3 of 4/3 reps @ 180 lbs/45 + 10x2 + 2.5/-") // 0.8 * 225 = 180.0
        sets.append("Warmup 4 of 4/1 rep @ 205 lbs/45 + 25 + 10/-")     // 0.9 * 225 = 202.5
        sets.append("Workset 1 of 1/5 reps @ 225 lbs/45x2/-")
        #expect(to_headers(plan) == sets.joined(separator: ", "))
        #expect(completed() == "5 reps @ 225 lbs")        
    }
    
    @Test("VariablePlan")
    func variable() {
        // Variable reps
        exercise = make("Face Pulls", "Face Pull", "Accessory", weights: "Cable Machine", weight: 42.6)
        var plan = makePlan()
        #expect(plan.details(exercise) == "3x8-12 @ 42.5 lbs")
        
        var sets: [String] = []
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
        
        // Check progression
        setCompleted([])
        #expect(exercise.progress(program) == 0)    // no completed
        
        let b = exercise.baseWeight!
        setCompleted([([12, 12, 4], nil)])
        #expect(exercise.progress(program) == 0)    // not enough reps
        
        setCompleted([([12, 12, 12], b - 10.0)])
        #expect(exercise.progress(program) == 0)    // not enough weight
        
        setCompleted([([12, 12, 12], nil)])
        #expect(exercise.progress(program) == 1)    // enough reps
        
        setCompleted([([12, 13, 12], nil)])
        #expect(exercise.progress(program) == 1)    // one extra rep
        
        setCompleted([([12, 12, 4], nil),  ([12, 12, 4], nil)])
        #expect(exercise.progress(program) == 0)    // not enough reps
        
        setCompleted([([8, 8, 7], nil),  ([8, 8, 8], nil),  ([10, 9, 8], nil),  ([10, 10, 9], nil)])
        #expect(exercise.progress(program) == 0)    // reps are going up

        setCompleted([([11, 10, 10], nil),  ([10, 10, 10], nil),  ([10, 10, 9], nil),  ([10, 9, 8], nil)])
        #expect(exercise.progress(program) == -2)    // reps are going down

        setCompleted([([8, 8, 8], b - 10.0),  ([8, 8, 8], b - 10.0),  ([8, 8, 8], nil),  ([8, 8, 8], nil)])
        #expect(exercise.progress(program) == 0)    // stuck at same reps too many times (but weights don't match)
        
        let c = b - 10.0
        setCompleted([([10, 10, 10], c),  ([10, 10, 10], c),  ([10, 10, 10], c),  ([10, 10, 10], c)])
        #expect(exercise.progress(program) == 0)    // stuck at same reps too many times (but weights don't match)
        
        setCompleted([([10, 10, 10], nil),  ([10, 10, 10], nil),  ([10, 10, 10], nil),  ([10, 10, 10], nil)])
        #expect(exercise.progress(program) == -2)    // stuck at same reps too many times
        
        setCompleted([([8, 8, 7], nil)])
        #expect(exercise.progress(program) == -2)    // did fewer than min reps
        
        setCompleted([([8, 7, 8], nil)])
        #expect(exercise.progress(program) == -2)    // did fewer than min reps
    }
    
    @Test("PercentPlan")
    func percent() {
        // No completed
        exercise = make("Light Bench", "Bench Press", "Light")
        var plan = makePlan(other: make("Heavy Bench", "Bench Press", "Main", weights: "Dual Plates", weight: 225))
        
        #expect(plan.details(exercise) == "3x5 @ 205 lbs")          // 0.9 * 225 = 202.5
        
        var sets: [String] = []
        sets.append("Warmup 1 of 4/5 reps @ 45 lbs/-/20% of 225")               // 0.0 * 0.9 * 225 = 0.0% = 0.0
        sets.append("Warmup 2 of 4/5 reps @ 120 lbs/25 + 10 + 2.5/53% of 225")  // 0.6 * 0.9 * 225 = 0.54% = 121.5
        sets.append("Warmup 3 of 4/3 reps @ 160 lbs/45 + 10 + 2.5/71% of 225")  // 0.8 * 0.9 * 225 = 0.72% = 162.0
        sets.append("Warmup 4 of 4/1 rep @ 180 lbs/45 + 10x2 + 2.5/80% of 225") // 0.9 * 0.9 * 225 = 0.81% = 182.25
        sets.append("Workset 1 of 3/5 reps @ 205 lbs/45 + 25 + 10/91% of 225")
        sets.append("Workset 2 of 3/5 reps @ 205 lbs/45 + 25 + 10/91% of 225")
        sets.append("Workset 3 of 3/5 reps @ 205 lbs/45 + 25 + 10/91% of 225")
        #expect(to_headers(plan) == sets.joined(separator: ", "))
        #expect(completed() == "5 reps x3 @ 205 lbs")   // TODO need to get weightset from other
        
        // Percent is based on other baseWeight, not other completed. It makes some sense to use completed
        // because the user may not be able to do a new baseWeight but we don't want to do that for gzcl
        // and keeping things simple and consistent seems like a good idea.
        exercise = make("Light Bench", "Bench Press", "Light")
        plan = makePlan(other: make("Heavy Bench", "Bench Press", "Main", weights: "Dual Plates", weight: 225),
                        daysAgo: 2, reps: [5, 5, 5], weights: [250, 250, 250])
        
        #expect(plan.details(exercise) == "3x5 @ 205 lbs")          // 0.9 * 225 = 202.5
        
        sets = []
        sets.append("Warmup 1 of 4/5 reps @ 45 lbs/-/20% of 225")               // 0.0 * 0.9 * 225 = 0.0% = 0.0
        sets.append("Warmup 2 of 4/5 reps @ 120 lbs/25 + 10 + 2.5/53% of 225")  // 0.6 * 0.9 * 225 = 0.54% = 121.5
        sets.append("Warmup 3 of 4/3 reps @ 160 lbs/45 + 10 + 2.5/71% of 225")  // 0.8 * 0.9 * 225 = 0.72% = 162.0
        sets.append("Warmup 4 of 4/1 rep @ 180 lbs/45 + 10x2 + 2.5/80% of 225") // 0.9 * 0.9 * 225 = 0.81% = 182.25
        sets.append("Workset 1 of 3/5 reps @ 205 lbs/45 + 25 + 10/91% of 225")
        sets.append("Workset 2 of 3/5 reps @ 205 lbs/45 + 25 + 10/91% of 225")
        sets.append("Workset 3 of 3/5 reps @ 205 lbs/45 + 25 + 10/91% of 225")
        #expect(to_headers(plan) == sets.joined(separator: ", "))
        #expect(completed() == "5 reps x3 @ 205 lbs")
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
    
    private func makePlan(other: Exercise? = nil, daysAgo: Int? = nil, reps: [Int]? = nil, secs: [Int]? = nil, weights: [Float]? = nil) -> ExercisePlan {
        model = Model()

        program = Program("Test Program")
        program.styles["Accessory"] = .variable(VariableInfo(warmup: "", workset: "8-12 8-12 8-12", rest: "2m")!)
        program.styles["AMRAP"] = .amrap(AMRAPInfo(warmup: "5/0 5/60 3/80 1/90", workset: "5 5 5", rest: "2m")!)
        program.styles["Beginner"] = .beginner(BeginnerInfo(warmup: "5/0 5/60 3/80 1/90", workset: [5, 5, 5], rest: "2m")!)
        program.styles["GZCL"] = .amrap(AMRAPInfo(warmup: "5/60 3/80 1/90", workset: "3/90 2/95 1", rest: "2m")!)   // week 4 version
        program.styles["Light"] = .percent(PercentInfo(percent: 90, rest: "2m")!)
        program.styles["Main"] = .variable(VariableInfo(warmup: "5/0 5/60 3/80 1/90", workset: "5 5 5", rest: "3m")!)
        program.styles["Stretch1"] = .durations(DurationsInfo(secs: "30s", targetSecs: "")!)
        program.styles["Stretch3"] = .durations(DurationsInfo(secs: "30s 40s 50s", targetSecs: "")!)
        program.styles["Stretch3b"] = .durations(DurationsInfo(secs: "30s 30s 30s", targetSecs: "60s")!)
        program.styles["Walk"] = Style.timed
        program.styles["1RM"] = .oneRepMax(OneRepMaxInfo(warmup: "5/0 5/60 3/80 1/90", workset: 5, rest: "2m")!)

        let schedule = Schedule.days(Weekdays([.monday]))
        workout = Workout("Test Workout", schedule)
        program.addWorkout(workout)

        model.programs.append(program)
        model.activeProgram = program.name
        
        program.exercises.append(exercise)
        workout.addExercise(name: exercise.name)
        if let o = other {
            program.exercises.append(o)
            workout.addExercise(name: o.name)
        }
        model.addMissingWeightsets()
        
        if let reps = reps {
            let e = other ?? exercise!
            GymAce.addCompleted(e, daysAgo: daysAgo!, reps: reps, weights: weights)
        }
        if let secs = secs {
            let e = other ?? exercise!
            GymAce.addCompleted(e, daysAgo: daysAgo!, secs: secs, weights: weights)
        }

        return ExercisePlan(model, program, workout, exercise)
    }

    private func setCompleted(_ repsAndWeight: [([Int], Float?)]) {
        let calendar = Calendar.current
        let c = repsAndWeight.enumerated().map {
            let daysAgo = repsAndWeight.count - $0
            let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
            let b = $1.1 ?? exercise.baseWeight
            let weights: [Float]? = if let c = b {
                Array(repeating: c, count: $1.0.count)    // values don't really matter for progression
            } else {
                nil
            }
            return Completed(reps: $1.0, weights: weights, baseWeight: b, units: .Imperial, completed: d!)
        }
        exercise.history.removeAll()
        exercise.history.append(contentsOf: c)
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

