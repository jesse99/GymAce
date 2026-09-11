//import SwiftUI
//
//struct MenuItem: Identifiable, Hashable {
//    let id = UUID() // Identifiable requirement
//    var name: String
//}
//
//struct BasicView: View {
//    var model: Model
//    var program: Program
//    @Bindable var exercise: Exercise
//
//    @State private var info: BasicInfo
//
//    @State private var warmupText = ""
//    @State private var warmupErr: String? = nil
//    @State private var showWarmupHelp = false
//
////    @State private var repsWorksetsText = ""
//////    @State private var repsRestText = ""
////    @State private var repsWorksetsErr: String? = nil
//////    @State private var repsRestErr: String? = nil
////    @State private var showRepsWorksetsHelp = false
//////    @State private var showRepsRestHelp = false
//
//    init(model: Model, program: Program, exercise: Exercise) {
//        self.model = model
//        self.program = program
//        self.exercise = exercise
//            
//        switch program.findStyle(exercise.styleName) {
//        case .basic(let i):
//            _info = State(initialValue: i)
//        default:
//            _info = State(initialValue: BasicInfo(warmup: "5/60 3/80 1/90", workset: "5 5 5", rest: "2.5m")!)
//        }
//
//        _warmupText = State(initialValue: info.warmup.map {$0.asString()}.joined(separator: " "))
////        _repsWorksetsText = State(initialValue: repsData.workset.map {$0.asString()}.joined(separator: " "))
////        if let s = repsData.rest {
////            _repsRestText = State(initialValue: secsToShortStr(s))
////        } else {
////            _repsRestText = State(initialValue: "")
////        }
//    }
//    
//    var body: some View {
//        // Warmup
//        HStack {
//            repsTextField("Warmups", warmupBinding)
//            Spacer()
//            Button("", systemImage: "info.circle") {
//                showWarmupHelp.toggle()
//            }
//            .buttonStyle(.plain)
//            .padding(.leading, 5)
//        }
//        if showWarmupHelp {
//            Text("Sets to do before the work sets. Formated as 5/80, i.e. 5 reps at 80% of the base weight.")
//                .foregroundColor(.blue)
//                .font(.footnote)
//        }
//        if let e = warmupErr {
//            Text(e)
//                .foregroundColor(.red)
//                .font(.footnote)
//        }
////
////                HStack {
////                    repsTextField("Worksets", repsWorksetsBinding)
////                    Spacer()
////                    Button("", systemImage: "info.circle") {
////                        showRepsWorksetsHelp.toggle()
////                    }
////                    .buttonStyle(.plain)
////                    .padding(.leading, 5)
////                }
////                if showRepsWorksetsHelp {
////                    Text("Sets to do using the maximum weight. Formated as 5 for five reps, 8-12 for eight to twelve reps, or 3+ for three or more reps. For fixed and AMRAP sets you can append an optional percent, e.g. 5/90 5/80 3+/70.")
////                        .foregroundColor(.blue)
////                        .font(.footnote)
////                }
////                if let e = repsWorksetsErr {
////                    Text(e)
////                        .foregroundColor(.red)
////                        .font(.footnote)
////                }
//    }
//    
//    private var warmupBinding: Binding<String> {
//        Binding(
//            get: {
//                return warmupText
//            },
//            set: {
//                var a: [OtherReps] = []
//                warmupText = $0
//                for s in $0.split(separator: " ") {
//                    if let r = OtherReps(String(s)) {
//                        a.append(r)
//                    } else {
//                        warmupErr = "Expected a number for reps and a percent, e.g. 5/80, not '\(s)'."
//                        return
//                    }
//                }
//                warmupErr = nil
//                info.warmup = a
//                exercise.data = .reps(repsData)
//            }
//        )
//    }
//
////    private var repsWorksetsBinding: Binding<String> {
////        Binding(
////            get: {
////                return repsWorksetsText
////            },
////            set: {
////                var a: [VariableReps] = []
////                repsWorksetsText = $0
////                for s in $0.split(separator: " ") {
////                    if let r = VariableReps(String(s)) {
////                        a.append(r)
////                    } else {
////                        repsWorksetsErr = "Expected a rep, rep range, or As Many Reps As Possible, not '\(s)'."
////                        return
////                    }
////                }
////                if a.isEmpty {
////                    repsWorksetsErr = "Need at least one set."
////                } else {
////                    repsWorksetsErr = nil
////                    repsData.workset = a
////                    exercise.data = .reps(repsData)
////                }
////            }
////        )
////    }
////
////    private var repsRestBinding: Binding<String> {
////        Binding(
////            get: {
////                return repsRestText
////            },
////            set: {
////                repsRestText = $0
////                if let s = parseShortSecs($0) {
////                    repsRestErr = nil
////                    repsData.rest = s
////                    exercise.data = .reps(repsData)
////                } else if $0.isBlankOrEmpty {
////                    repsRestErr = nil
////                    repsData.rest = nil
////                    exercise.data = .reps(repsData)
////                } else {
////                    repsRestErr = "Expected nothing or a number with an optional time suffix, not '\($0)'."
////                }
////            }
////        )
////    }
//
//    private var isValid: Bool {
//        return warmupErr == nil
////            return warmupErr == nil && repsWorksetsErr == nil
//    }
//}
//
//#Preview {
//    let model = previewModel()
//    let program = model.programs[0]
//    let workout = program.workouts[0]
//    let entry = workout.entries[0]
//    BasicView(model: model, program: program, exercise: program.findExercise(entry.name)!)
//}
//
//#Preview("Two") {
//    let model = previewModel()
//    let program = model.programs[0]
//    let workout = program.workouts[0]
//    let entry = workout.entries[1]
//    BasicView(model: model, program: program, exercise: program.findExercise(entry.name)!)
//}
//
//#Preview("Three") {
//    let model = previewModel()
//    let program = model.programs[0]
//    let workout = program.workouts[0]
//    let entry = workout.entries[2]
//    BasicView(model: model, program: program, exercise: program.findExercise(entry.name)!)
//}
