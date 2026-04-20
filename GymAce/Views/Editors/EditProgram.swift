import SwiftUI
import SwiftData

struct EditProgram: View {
    @Bindable var program: Program // Creates the binding to the object
    @State private var isShowingInfo = false

    var isValid: Bool {
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
                    Button("", systemImage: "info.circle") {
                        isShowingInfo.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                    .sheet(isPresented: $isShowingInfo) {
                        InfoView(text: "The title of the program, e.g. \"My\". Or you might have two programs like \"Gym\" and \"Home\".")
                            .presentationDetents([.height(80)])
                            .presentationDragIndicator(.visible)
                    }
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
                            EditWorkout(name: $workout.name, schedule: $workout.schedule)
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
