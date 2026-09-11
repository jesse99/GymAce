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
    @State private var formalNames: [MenuItem] = []
    @State private var showStylePickerHelp = false
    private var workoutsLabel: String = ""

    init(model: Model, program: Program, exercise: Exercise) {
        self.model = model
        self.program = program
        self.exercise = exercise
        
        var workouts: [String] = []
        for w in program.workouts {
            if w.entries.contains(where: { $0.name == exercise.name }) {
                workouts.append(w.name)
            }
        }
        if workouts.isEmpty {
            self.workoutsLabel = "This exercise is not part of any workout."
        } else if workouts.count == 1{
            self.workoutsLabel = "Part of the \(workouts[0]) workout."
        } else {
            self.workoutsLabel = "Part of \(workouts.sorted().joined(separator: " and ")) workouts."
        }
    }
    
    // TODO use onAppear to make the name textbox the focus?
    var body: some View {
        Form {
            // Name
            HStack {
                nameTextField("Name", nameBinding)
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
            } else if dupeName {
                Text("There is already a exercise with that name.")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            // Formal name
            HStack {
                nameTextField("Formal Name", formalBinding)
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
            
            // Style picker
            HStack {
                Picker("", selection: styleBinding) {
                    ForEach(program.styles.sorted(by: {$0.key < $1.key}), id: \.key) {key, value in
                        Text(key).tag(key)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showStylePickerHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showStylePickerHelp {
                let style = program.findStyle(exercise.styleName)
                Text(style.description() + "\n" + style.summary().joined(separator: "\n"))
                    .foregroundColor(.blue)
                    .font(.footnote)
            }

            WeightView(model: model, exercise: exercise)

            Text(workoutsLabel)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!isValid)
        .onAppear {
            model.dirty = true
        }
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
                for n in model.notes.defaults.keys {
                    if n.lowercased().contains($0.lowercased()) {   // only show formal names that match current formal name
                        let item = MenuItem(name: n)
                        formalNames.append(item)
                        if formalNames.count > 30 {
                            formalNames.append(MenuItem(name: "…"))
                            break
                        }
                    }
                }
                for n in model.notes.custom.keys {
                    if n.lowercased().contains($0.lowercased()) && model.notes.defaults[n] == nil {
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
    
    private var styleBinding: Binding<String> {
        Binding(
            get: {return exercise.styleName},
            set: {exercise.styleName = $0}
        )
    }

    private func formalColor(_ name: String) -> Color {
        if model.notes.defaults[name] != nil || model.notes.custom[name] != nil {
            return .black
        } else {
            return .red
        }
    }

    private func setFormalName(_ name: String) {
        exercise.formalName = name
        formalNames = []
    }

    private var isNameEmpty: Bool {
        self.exercise.name.isEmpty
    }

    private var dupeName: Bool {
        self.program.exercises.count(where: {
            $0 !== self.exercise && $0.name == self.exercise.name
        }) > 0
    }

    private var isValid: Bool {
        guard !isNameEmpty && !dupeName else {
            return false
        }
        return true
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
