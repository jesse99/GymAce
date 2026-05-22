import SwiftUI

struct EditExercises: View {
    var model: Model
    @Bindable var program: Program

    private var exercisesBinding: Binding<[Exercise]> {
        Binding(
            get: {return self.program.exercises.sorted {$0.name < $1.name}},
            set: {self.program.exercises = $0}
        )
    }
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Exercises")) {
                    ForEach(exercisesBinding, id: \.name) { $exercise in
                        NavigationLink {
                            EditExercise(model: model, program: program, exercise: exercise)
                        } label: {
                            Text(exercise.name)
                        }
                    }
                    .onDelete(perform: deleteExercises)
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
                    Button(action: addExercise) {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("Edit Exercises")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // We could allow the user to create the right exercise type but that makes
    // it harder to give them help about the different types and doesn't really
    // save them much time because they'll have to heavily edit the exercise anyway.
    private func addExercise() {
        let d = DurationsData(secs: [30], targetSecs: nil)
        let exercise = Exercise(name: findName(), formalName: "", durations: d)
        program.exercises.append(exercise)
    }
    
    private func findName() -> String {
        var candidate = "Untitled"
        var n = 2
        while hasName(candidate) {
            candidate = "Untitled \(n)"
            n += 1
        }
        return candidate
    }

    private func hasName(_ name: String) -> Bool {
        return program.exercises.contains(where: {$0.name == name})
    }

    // TODO need to confirm this
    private func deleteExercises(offsets: IndexSet) {
        withAnimation {
            self.program.deleteExercises(offsets)
        }
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    NavigationView {
        EditExercises(model: model, program: program)
    }
}
