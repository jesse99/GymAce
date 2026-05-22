import SwiftUI

struct EditExercise: View {
    var model: Model
    var program: Program
    @Bindable var exercise: Exercise
    @State private var showNameHelp = false
    @State private var showWeightPickerHelp = false
    @State private var showWeightHelp = false
    private let weightDelta = 10

    init(model: Model, program: Program, exercise: Exercise) {
        self.model = model
        self.program = program
        self.exercise = exercise
    }
    
    // TODO use onAppear to make the name textbox the focus?
    var body: some View {
        Form {
            HStack {
                TextField("Name", text: nameBinding)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showNameHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showNameHelp {
                Text("The name shown in the Workout view.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
            if isNameEmpty {
                Text("Exercise name cannot be empty.")
                    .foregroundColor(.red)
                    .font(.footnote)
            } else if doesNameExist {
                Text("There is already a exercise with that name.")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            if let n = exercise.weightSet, let ws = model.weightSets[n] {
                HStack {
                    Picker("", selection: weightsBinding) {
                        ForEach(getWeightLabels(ws), id: \.0) {tuple in
                            Text(tuple.0).tag(tuple.1)
                        }
                    }
                    .labelsHidden()
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showWeightPickerHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showWeightPickerHelp {
                    Text("The weight the user should do next using the \(n) weight set.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
            } else {
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
                    Text("The weight the user should do next (with no weight set).")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!isValid)
        .onAppear {
            model.dirty = true
        }
    }
        
    private func getWeightLabels(_ ws: WeightSet) -> [(String, Int)] {
        var labels: [(String, Int)] = []
        
        let w = exercise.weight ?? 0.0
        var actual = ActualWeight(discrete: w, ws.units)
        for _ in 1...weightDelta {
            let old = actual.text()
            actual = ws.lower(target: actual.value() - 0.001)
            if actual.text() != old {
                labels.append((actual.text(), Int(1000*actual.value())))
            } else {
                break
            }
        }
        labels.reverse()

        actual = ActualWeight(discrete: w, ws.units)
        labels.append((actual.text(), Int(1000*actual.value())))

        for _ in 1...weightDelta {
            let old = actual.text()
            actual = ws.advance(target: actual.value() + 0.001)
            if actual.text() != old && actual.value() != Float.greatestFiniteMagnitude {    // TODO ugh
                labels.append((actual.text(), Int(1000*actual.value())))
            } else {
                break
            }
        }
        return labels
    }
    
    private var nameBinding: Binding<String> {
        Binding(
            get: {return exercise.name},
            set: {program.setExerciseName(exercise, $0)}
        )
    }

    private var weightBinding: Binding<String> {
        Binding(
            get: {
                let w = exercise.weight ?? 0.0
                return formatWeight(w, .None)
            },
            set: {exercise.weight = Float($0) ?? 0.0}
        )
    }

    private var weightsBinding: Binding<Int> {
        Binding(
            get: {
                // Current value is always the current exercise weight.
                let w = exercise.weight ?? 0.0
                return Int(1000*w)
            },
            set: {exercise.weight = Float($0)/1000.0}
        )
    }

    private var isNameEmpty: Bool {
        self.exercise.name.isEmpty
    }

    private var doesNameExist: Bool {
        self.program.exercises.count(where: {
            $0 !== self.exercise && $0.name == self.exercise.name
        }) > 0
    }

    private var isValid: Bool {
        !isNameEmpty && !doesNameExist
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[0]
    NavigationView {
        EditExercise(model: model, program: program, exercise: program.findExercise(entry.name)!)
    }
}

#Preview("Two") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[1]
    NavigationView {
        EditExercise(model: model, program: program, exercise: program.findExercise(entry.name)!)
    }
}

#Preview("Three") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[2]
    NavigationView {
        EditExercise(model: model, program: program, exercise: program.findExercise(entry.name)!)
    }
}
