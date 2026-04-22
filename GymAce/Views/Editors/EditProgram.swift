import SwiftUI
import SwiftData

struct EditProgram: View {
    @Bindable var program: Program // Creates the binding to the object
    @State private var showNameHelp = false

    private var isValid: Bool {
        !program.name.isEmpty
    }

    var body: some View {
        VStack {
            Form {
                HStack {
                    TextField("Name", text: $program.name)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                    Spacer()
                    
                    // get rid of all the TipView stuff
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
                if program.name.isEmpty {
                    Text("Program name cannot be empty.")
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            .formStyle(.columns)    // only decent way I can find to stop the form from taking way too much vertical space
            .padding(7)
            
            // Note that we don't allow these rows to be moved in edit mode
            // because in ContentView they're sorted by due date.
            List {
                Section(header: Text("Workouts")) {
                    ForEach($program.workouts) { $workout in
                        NavigationLink {
                            EditWorkout(program: program, workout: workout, name: $workout.name, schedule: $workout.schedule)
                        } label: {
                            Text(workout.name)
                        }
                    }
                    .onDelete(perform: deleteWorkouts)
                }
            }
            .listStyle(.plain)
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
        let workout = Workout("Untitled", .anyDay)
        self.program.addWorkout(workout)
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        withAnimation {
            self.program.deleteWorkouts(offsets)
        }
    }
}

#Preview {
    @Previewable @State var program = PreviewData.shared.defaultProgram
    NavigationView {
        EditProgram(program: program)
            .modelContainer(PreviewData.shared.container)
    }
}
