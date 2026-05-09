//import Foundation
//import SwiftData
//
//fileprivate func makeReps(name: String, formalName: String, warmups: [FixedReps] = [], worksets: [VariableReps], backoff: [FixedReps] = [], weights: String? = nil, weight: Float? = nil, rest: Int? = nil) -> Exercise {
//    let reps = RepsData(warmups: warmups, worksets: worksets, backoff: backoff, rest: rest)
//    if let n = weights {
//        return Exercise(name: name, formalName: formalName, reps: reps, weights: testWeightSets[n], weight: weight)
//    } else {
//        return Exercise(name: name, formalName: formalName, reps: reps)
//    }
//}
//
//@MainActor
//let previewContainer: ModelContainer = {
//    let schema = Schema([
//        Exercise.self,
//        Program.self,
//        WeightSet.self
//    ])
//    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//    do {
//        let container = try ModelContainer(for: schema, configurations: [configuration])
////            for ws in testWeightSets.values {
////                container.mainContext.insert(ws)
////            }
////            for exercise in testExercises.values {
////                container.mainContext.insert(exercise)
////            }
//        
//        let reps5 = [VariableReps(5), VariableReps(5), VariableReps(5)]
//        let warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
//        var lightBench = makeReps(name: "Light Bench", formalName: "Bench Press", warmups: warmup, worksets: reps5, weights: "Dual", weight: 130, rest: 10)
//
//        var program = Program(name: "My")
//        program.active = true
//        let schedule = Schedule.days(Weekdays(days: [5]))       // thursday
//        let workout = Workout("Squat", schedule)
//        workout.addExercise(exercise: lightBench)
//        program.addWorkout(workout)
//        if let r = lightBench.reps {
//            container.mainContext.insert(r)
//        }
//        container.mainContext.insert(lightBench)
//        container.mainContext.insert(workout)
//        container.mainContext.insert(program)
//
//        program = Program(name: "My2")
//        program.active = true
//        container.mainContext.insert(program)
//
//        program = Program(name: "Preview")
//        program.active = true
//        container.mainContext.insert(program)
//
////        container.mainContext.insert(makeMyProgram())
////        container.mainContext.insert(testProgram)
////        container.mainContext.insert(makeMy2Program())
//        try container.mainContext.save()
//        return container
//    } catch {
//        fatalError("Could not create ModelContainer: \(error)") // prints to console and exits
//    }
//}()
//
//
//// ModelContainer for use by preview views.
////@MainActor
////class PreviewData {
////    static let shared = PreviewData()        // this is the only way to access the PreviewData instance
////    let container: ModelContainer
////    
////    var context: ModelContext {
////        container.mainContext
////    }
////    
////    var defaultProgram: Program {
////        testProgram
////    }
////    
////    private init() {
////        let schema = Schema([
////            Exercise.self,
////            Program.self,
////            WeightSet.self
////        ])
////        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
////        do {
////            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
//////            for ws in testWeightSets.values {
//////                container.mainContext.insert(ws)
//////            }
//////            for exercise in testExercises.values {
//////                context.insert(exercise)
//////            }
////            context.insert(makeMyProgram())
////            context.insert(testProgram)
////            context.insert(makeMy2Program())
////            try context.save()
////        } catch {
////            fatalError("Could not create ModelContainer: \(error)") // prints to console and exits
////        }
////    }
////}
//
//// ModelContainer for use by preview views that doesn't have any programs.
//class NoPreviewData {
//    static let shared = NoPreviewData()
//    let modelContainer: ModelContainer
//    
//    var context: ModelContext {
//        modelContainer.mainContext
//    }
//    
////    var defaultProgram: Program {
////        testProgram
////    }
//    
//    private init() {
//        let schema = Schema([
//            Exercise.self,
//            Program.self,
//            WeightSet.self
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//        do {
//            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)") // prints to console and exits
//        }
//    }
//}
