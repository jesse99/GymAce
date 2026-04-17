import SwiftUI
import SwiftData

struct EditProgram: View {
    @State var program: Program
    @State private var newWorkout: Workout?
    @State private var isShowingInfo = false

    var body: some View {
        VStack {
            // Note that we don't allow these rows to be moved in edit mode
            // because in ContentView they're sorted by due date.
            List {
                Section(header: Text("Workouts")) {
                    ForEach(program.workouts) { workout in
                        NavigationLink {
                            EditWorkout(editing: true, program: program, workout: workout)
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
            .sheet(item: $newWorkout) { workout in
                NavigationStack {
                    EditWorkout(editing: false, program: program, workout: workout)
                }
                .interactiveDismissDisabled()
            }

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
                    .sheet(isPresented: $isShowingInfo) {
                        InfoView(text: "The title of the program, e.g. \"My\". Or you might have two programs like \"Gym\" and \"Home\".")
                            .presentationDetents([.height(80)])
                            .presentationDragIndicator(.visible)
                    }
                }
            }

        }
    }
    
    private func addWorkout() {
        let newWorkout = Workout("Untitled", .anyDay)
        program.addWorkout(newWorkout)
        self.newWorkout = newWorkout
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        withAnimation {
            program.deleteWorkouts(offsets)
        }
    }
}

#Preview {
    NavigationView {
        EditProgram(program: PreviewData.shared.defaultProgram)
            .modelContainer(PreviewData.shared.container)
    }
}
