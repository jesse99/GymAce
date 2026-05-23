import SwiftUI

struct EditProgram: View {
    @Bindable var model: Model
    @Bindable var program: Program
    @State private var showNameHelp = false
    @State private var showCurrentWeekHelp = false
    @State private var malformedCurrentWeek: String? = nil

    // Note that here we are always editing the active program so we do know which name to use.
    private var nameBinding: Binding<String> {
        Binding(
            get: {return model.activeProgram},
            set: {model.renameProgram(program, $0)}
        )
    }

    private var isValid: Bool {
        !model.activeProgram.isEmpty
    }

    private var currentWeekBinding: Binding<String> {
        Binding(
            get: {
                if let w = program.currentWeek(on: Date()) {
                    return "\(w)"
                } else {
                    return ""
                }
            },
            set: {
                if let n = Int($0) {
                    if n > 0 {
                        program.setCurrentWeek(n)
                        malformedCurrentWeek = nil
                    } else {
                        malformedCurrentWeek = "Current weeks cannot be 0."
                    }
                } else {
                    // Note that, if there are workouts with weeks, we need a current week.
                    malformedCurrentWeek = "Current week should be a 1-based number."
                }
            }
        )
    }
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    TextField("Name", text: nameBinding)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                    Spacer()
                    
                    // TODO what if we just toggle a field to show/hide a text field?
                    // TODO use questionmark.circle?                    
                    Button("", systemImage: "info.circle") {
                        showNameHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                    .padding(.leading, 5)
                }
                if showNameHelp {
                    Text("The program name, e.g. \"My\" or \"Gym\" and \"Home\".")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if model.activeProgram.isEmpty {
                    Text("Program name cannot be empty.")
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                if program.usesWeeks() {
                    HStack {
                        TextField("Current week, e.g. 1", text: currentWeekBinding)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        Spacer()
                        Button("", systemImage: "info.circle") {
                            showCurrentWeekHelp.toggle()
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 5)
                    }
                    if showCurrentWeekHelp {
                        Text("The 1-based week number for the current week. Used when scheduling workouts that happen on specified weeks.")
                            .foregroundColor(.blue)
                            .font(.footnote)
                    }
                    if let m = malformedCurrentWeek {
                        Text(m)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .formStyle(.columns)    // only decent way I can find to stop the form from taking way too much vertical space
            .padding(7)
            // Note that we don't allow these rows to be moved in edit mode
            // because in ContentView they're sorted by due date.
            List {
                Section(header: Text("Workouts")) {
                    ForEach(program.workouts.sorted(by: {$0.name < $1.name})) { workout in
                        NavigationLink {
                            EditWorkout(model: model, program: program, workout: workout)
                        } label: {
                            Text(workout.name)
                        }
                    }
                    .onDelete(perform: deleteWorkouts)
                }
            }
            .listStyle(.plain)
            .onAppear {
                model.dirty = true
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addWorkout) {
                        Label("Add Workout", systemImage: "plus")
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("Edit Program")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!isValid)
    }
    
    private func addWorkout() {
        let name = findName(hasName)
        let workout = Workout(name, .anyDay)
        self.program.addWorkout(workout)
    }
    
    private func hasName(_ name: String) -> Bool {
        return program.workouts.contains(where: { $0.name == name })
    }

    // TODO confirm this, mention if program is using the workout (ie not disabled)
    private func deleteWorkouts(offsets: IndexSet) {
        let workouts = program.workouts.sorted(by: {$0.name < $1.name})
        let names = offsets.map {workouts[$0].name}
        withAnimation {
            self.program.deleteWorkouts(names)
        }
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    NavigationView {
        EditProgram(model: model, program: program)
    }
}
