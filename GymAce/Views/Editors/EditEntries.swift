import SwiftUI

struct EditEntries: View {
    @Bindable var model: Model
    @Bindable var program: Program
    @Bindable var workout: Workout
    @State var canAdd: [String] = []
    
    init(model: Model, program: Program, workout: Workout) {
        self.model = model
        self.program = program
        self.workout = workout
        
        var names: [String] = []
        for e in program.exercises where workout.entries.contains(where: {$0.name == e.name}) == false {
            names.append(e.name)
        }
        names.sort()
        _canAdd = State(initialValue: names)
    }
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("\(workout.name) Exercises")) {
                    ForEach($workout.entries, id: \.name, editActions: .move) {$entry in    // TODO this does mean names must be unique in a workout
                        Text(entry.name)
                            .foregroundColor(entry.enabled ? .black : .gray)
                            .onTapGesture {
                                entry.enabled = !entry.enabled
                            }
                    }
                    .onDelete(perform: deleteExercises)
                    .onMove(perform: moveExercises)
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
                    Menu {
                        ForEach(canAdd, id: \.self) {name in
                            Button(name, action: {addExercise(name)})
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            Spacer()
            Text("Tap to enable or disable an exercise from this workout. To edit the exercise go back to the main view and select \"Edit Exercises\".")
        }
        .navigationTitle("Edit Workout Exercises")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addExercise(_ name: String) {
        if let index = canAdd.firstIndex(of: name) {
            canAdd.remove(at: index)
        }
        workout.addExercise(name: name)
    }
    
    // TODO need to confirm this
    private func deleteExercises(offsets: IndexSet) {
        let names = offsets.map {workout.entries[$0].name}
        withAnimation {
            for n in names {
                workout.removeExercise(name: n)
                canAdd.append(n)
            }
        }
        canAdd.sort()
    }
    
    func moveExercises(from source: IndexSet, to destination: Int) {
        workout.entries.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[2]
    NavigationView {
        EditEntries(model: model, program: program, workout: workout)
    }
}
