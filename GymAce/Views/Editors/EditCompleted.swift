import SwiftUI

struct EditCompleted: View {
    var model: Model
    @Bindable var exercise: Exercise
    @State var current: Completed
    @State var index: Int
    @State private var showWeightHelp = false
    @State private var showRepsHelp = false
    @State private var repsError: String? = nil
    @State private var showNoteHelp = false

    var body: some View {
        Form {
            // Reps
            HStack {
                TextField(repsTitle().capitalized, text: repsBinding)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numbersAndPunctuation)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
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
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
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
            
            // Note
            HStack {
                TextField("note", text: noteBinding)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.sentences)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showNoteHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showNoteHelp {
                Text("Arbitrary message shown together with what the user did for this exercise.")
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
        case .timed: return "seconds"
        }
    }
        
    private var repsBinding: Binding<String> {
        Binding(
            get: {
                let completed = exercise.history[index]
                let a = completed.values.map {"\($0)"}
                return a.joined(separator: " ")
            },
            set: {
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
                exercise.history[index].values = values
            }
        )
    }

    private var noteBinding: Binding<String> {
        Binding(
            get: {
                return current.note ?? ""
            },
            set: {
                if $0.isBlankOrEmpty {
                    current.note = nil
                } else {
                    current.note = $0
                }
            }
        )
    }

    private var weightBinding: Binding<String> {
        Binding(
            get: {
                if let w = exercise.history[index].weight {
                    return formatWeight(w, .None)
                } else {
                    return ""
                }
            },
            set: {
                exercise.history[index].weight = Float($0)
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
    NavigationView {
        EditCompleted(model: model, exercise: exercise, current: exercise.history[1], index: 1)
    }
}
