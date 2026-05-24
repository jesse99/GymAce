import SwiftUI

struct EditCompleted: View {
    var model: Model
    @Bindable var exercise: Exercise
    let snapshot: Snapshot
    @State private var showWeightHelp = false
    @State private var showRepsHelp = false
    @State private var repsError: String? = nil
    
    var body: some View {
        Form {
            // Reps
            HStack {
                TextField(repsTitle().capitalized, text: repsBinding)
                    .textFieldStyle(.roundedBorder)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showRepsHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showRepsHelp {
                Text("The \(repsTitle()) the user did for each set.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
            if let e = repsError {
                Text(e)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

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
            
            // TODO allow completed to be edited? would require re-sorting history
        }
        .navigationTitle("Edit Completed")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(repsError != nil)
        .onAppear {
            model.dirty = true
        }
    }
    
    private func repsTitle() -> String {
        switch exercise.data {
        case .durations(_): return "seconds"
        case .percent(_): return "reps"
        case .reps(_): return "reps"
        }
    }
        
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
                repsError = nil
                for part in $0.split(separator: " ") {
                    if let r = Int(part) {
                        if r >= 0 {
                            values.append(r)
                        } else {
                            repsError = "The number can't be negative."
                            break
                        }
                    } else {
                        repsError = "Expected an integer number, but found '\(part)'."
                        break
                    }
                }
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
    let snapshot = entry.history(exercise)[1]
    NavigationView {
        EditCompleted(model: model, exercise: exercise, snapshot: snapshot)
    }
}
