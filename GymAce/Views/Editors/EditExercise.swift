import SwiftUI

struct MenuItem: Identifiable, Hashable {
    let id = UUID() // Identifiable requirement
    var name: String
}

struct EditExercise: View {
    var model: Model
    var program: Program
    @Bindable var exercise: Exercise
    @State private var showNameHelp = false
    @State private var showFormalHelp = false
    @State private var showWeightPickerHelp = false
    @State private var showWeightHelp = false
    @State private var showWeightSetHelp = false
    @State private var showTypePickerHelp = false
    @State private var type: Int
    @State private var showDurationsHelp = false
    @State private var formalNames: [MenuItem] = []
    private let weightDelta = 10
    private let weightSets: [String]

    init(model: Model, program: Program, exercise: Exercise) {
        self.model = model
        self.program = program
        self.exercise = exercise
        self.weightSets = model.weightSets.keys.sorted()
        switch exercise.data {
        case .durations(_): type = 0
        case .percent(_): type = 1
        case .reps(_): type = 2
        }
    }
    
    // TODO use onAppear to make the name textbox the focus?
    var body: some View {
        Form {
            // Name
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
            
            // Formal name
            HStack {
                TextField("Formal Name", text: formalBinding)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(formalColor(formalBinding.wrappedValue))   // TODO not 100% reliable when editing
                //                    .id(exercise.formalName.hashValue) // think this causes the text field to lose focus when typing
                Menu("", systemImage: "chevron.up.chevron.down") {
                    ForEach($formalNames) {$item in
                        Button(action: {setFormalName(item.name)}, label: {
                            Text(item.name)
                        })
                    }
                }
                .id(formalNames.hashValue) // force redraw if the list changes
                Spacer()
                Button("", systemImage: "info.circle") {
                    showFormalHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showFormalHelp {
                Text("The name used to lookup notes for the exercise.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
            
            // Weight set
            HStack {
                Picker("Weight Set", selection: weightSetBinding) {
                    Text("None").tag(-1)
                    ForEach(Array(weightSets.enumerated()), id: \.element) {tuple in
                        Text(tuple.1).tag(tuple.0)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showWeightSetHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showWeightSetHelp {
                if let n = exercise.weightSet {
                    if let ws = model.weightSets[n] {
                        Text(ws.description())
                            .foregroundColor(.blue)
                            .font(.footnote)
                    } else {
                        Text("\(n) has no associated weight set.")
                            .foregroundColor(.blue)
                            .font(.footnote)
                    }
                } else {
                    Text("This exercise has no weights associated with it.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
            }
            
            // Weight
            if let n = exercise.weightSet, let ws = model.weightSets[n] {
                HStack {
                    Picker("", selection: weightsBinding) {
                        ForEach(getWeightLabels(ws), id: \.0) {tuple in
                            Text(tuple.0).tag(tuple.1)  // TODO why is the selection dimmed?
                        }
                    }
                    .pickerStyle(.menu)
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
            
            // Type picker
            HStack {
                Picker("", selection: $type) {  // TODO need a custom binding so we can switch state
                    Text("Durations").tag(0)
                    Text("Percent").tag(1)
                    Text("Reps").tag(2)
                }
                .pickerStyle(.menu)
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showTypePickerHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showTypePickerHelp {
                if type == 0 {
                    Text("Each set is done for a specified amount of time.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                } else if type == 1 {
                    Text("Each set is done using weights that are a percentage of another exercise.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                } else {
                    Text("Each work set is done using minimum and maximum reps.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
            }

            // Durations type
            if type == 0 {
                HStack {
                    TextField("Durations", text: durationsBinding)
                        .textFieldStyle(.roundedBorder)     // TODO make sure empty is sensible
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showDurationsHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showDurationsHelp {
                    Text("The amount of time to do each set. Suffixes can be used, s for seconds, m for minutes, and h for hours. Seconds are assumed if there is no suffix.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                //                if isNameEmpty {
                //                    Text("Exercise name cannot be empty.")
                //                        .foregroundColor(.red)
                //                        .font(.footnote)
                //                } else if doesNameExist {
                //                    Text("There is already a exercise with that name.")
                //                        .foregroundColor(.red)
                //                        .font(.footnote)
                //                }
            }
            // Percent type
            // TODO make sure empty sets is sensible
            
            // Reps type
            // TODO make sure empty sets is sensible
            //        }
        }
        .navigationTitle("Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!isValid)
        .onAppear {
            model.dirty = true
        }
    }
        
    // TODO need to update internal state as well as the exercise state
    // TODO need to allow suffixes
    private var durationsBinding: Binding<String> {
        Binding(
            get: {return "30s 30s 30s"},
            set: {_ = $0}
        )
    }

    private var nameBinding: Binding<String> {
        Binding(
            get: {return exercise.name},
            set: {program.setExerciseName(exercise, $0)}
        )
    }

    private var formalBinding: Binding<String> {
        Binding(
            get: {return exercise.formalName},
            set: {
                exercise.formalName = $0
                formalNames = []
                for n in model.notes.defaults.keys {    // TODO can custom notes be brand new?
                    if n.lowercased().contains($0.lowercased()) {
                        let item = MenuItem(name: n)
                        formalNames.append(item)
                        if formalNames.count > 30 {
                            formalNames.append(MenuItem(name: "…"))
                            break
                        }
                    }
                }
                formalNames.sort() {$0.name < $1.name}
            }
        )
    }
    
    private var weightSetBinding: Binding<Int> {
        Binding(
            get: {
                if let n = exercise.weightSet {
                    return weightSets.firstIndex(of: n) ?? 0
                } else {
                    return -1
                }
            },
            set: {
                if $0 == -1 {
                    exercise.weightSet = nil
                } else {
                    exercise.weightSet = weightSets[$0]
                }
            }
        )
    }

    private func formalColor(_ name: String) -> Color {
        if model.notes.defaults[name] != nil {
            return .black
        } else {
            return .red
        }
    }

    private func setFormalName(_ name: String) {
        exercise.formalName = name
        formalNames = []
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
