import SwiftUI

struct EditCompleted: View {
    var model: Model
    @Bindable var exercise: Exercise
    let snapshot: Snapshot
    @State private var showWeightHelp = false
    @State private var repsError: String = ""
    
    var body: some View {
        Form {
            // Weight
            HStack {
                TextField("Weight", text: weightBinding)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showWeightHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showWeightHelp {
                Text("The weight the user used when performing the exercise.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
        }
        .navigationTitle("Edit Completed")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // TODO ExerciseView isn't getting redrawn, maybe change dirty to an editCount
            // then List could use tag with that
            model.dirty = true
        }
    }
        
    // TODO need an error label
    // disable back button if error
    private var repsBinding: Binding<String> {
        Binding(
            get: {
                let i = exercise.history.count - snapshot.index
                let completed = exercise.history[i]
                let a = completed.values.map {"\($0)"}
                return a.joined(separator: " ")
            },
            set: {
                let i = exercise.history.count - snapshot.index
                var values: [Int] = []
                repsError = ""
                for part in $0.split(separator: " ") {
                    if let r = Int(part) {
                        values.append(r)
                    } else {
                        repsError = "xxx"   // TODO mo better
                        break
                    }
                }
                // TODO should there be an error if there are no values?
                exercise.history[i].values = values
            }
        )
    }

    private var weightBinding: Binding<String> {
        Binding(
            get: {
                let i = exercise.history.count - snapshot.index
                if let w = exercise.history[i].weight {
                    return formatWeight(w, .None)
                } else {
                    return ""
                }
            },
            set: {
                let i = exercise.history.count - snapshot.index
                exercise.history[i].weight = Float($0)
            }
        )
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[0]
    let exercise = program.findExercise(entry.name)!
    let snapshot = entry.history(exercise)[0]
    NavigationView {
        EditCompleted(model: model, exercise: exercise, snapshot: snapshot)
    }
}

#Preview("Two") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[0]
    let exercise = program.findExercise(entry.name)!
    let snapshot = entry.history(exercise)[1]
    NavigationView {
        EditCompleted(model: model, exercise: exercise, snapshot: snapshot)
    }
}
