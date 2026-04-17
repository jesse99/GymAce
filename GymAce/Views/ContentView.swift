import SwiftUI
import SwiftData

struct WithContentView: View {
    @Environment(\.modelContext) private var modelContext
    var program: Program
    @State private var newWorkout: Workout?
    
    // TODO
    // add to git, make sure account still looks ok
    // how do we edit the program name?
    //   edit button should popup a view with name textfield and editable list?
    //   but not movable
    //   that's also better because we want to list workouts multiple times here
    //   also active toggle? but then how would we re-enable it?
    // content view needs to select one of these views
    // have a due date col (for now can have a hard coded value)
    //    or just handle the really simple cases
    // sort by due date, maybe secondary sort by name
    // need a way to disable/enable a workout (do this in workouts?)
    // need a toolbar at the bottom
    //    programs view
    //    settings view (for now just imperial or metric)
    //       or should units be part of a weight set?
    //    also need this in NoContentView
    var body: some View {
        NavigationView {
            VStack {
                // Note that we don't allow these rows to be moved in edit mode
                // because they're sorted by due date.
                List {
                    ForEach(program.workouts) { workout in
                        HStack {
                            NavigationLink {
                                Text("Do \(workout.name) workout")
                            } label: {
                                Text(workout.name)
                                    .foregroundStyle(.blue)
                            }
                            .navigationLinkIndicatorVisibility(.hidden)
                            
                            Spacer()
                            Text("tomorrow")
                        }
                    }
                    .onDelete(perform: deleteWorkouts)
                }
                .listStyle(.plain)
                .navigationTitle("\(program.name) Workouts")
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
                .sheet(item: $newWorkout) { workout in    // TODO animate?
                    NavigationStack {
                        EditWorkout(editing: false, program: program, workout: workout)
                    }
                    .interactiveDismissDisabled()
                }
                //        } detail: {
                //            Text("Select an item")  // TODO do better here
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

struct NoContentView: View {
    @Environment(\.modelContext) private var modelContext
    var program: Program?
    @State private var newWorkout: Workout?

    // TODO add a toolbar at the bottom
    var body: some View {
        ContentUnavailableView("Use the Programs tab at the bottom of the screen to add a new program.", systemImage: "figure.run.square.stack.fill")
        .padding()
    }
}


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Program> { program in
        program.active
    }) var programs: [Program]
    var program: Program? { programs.first }
    @State private var newWorkout: Workout?

    // TODO
    // have a due date col (for now can have a hard coded value)
    //    or just handle the really simple cases
    // sort by due date, maybe secondary sort by name
    // need a way to disable/enable a workout (do this in workouts?)
    // need a toolbar at the bottom
    //    programs view
    //    settings view (for now just imperial or metric)
    var body: some View {
        NavigationSplitView {
            VStack {
                if program != nil {
//                    HStack {
//                        Text("Workout") // TODO underline these?
////                               .gridColumnAlignment(.leading)
//                        Spacer()
//                        Text("Due")
//                    }
//                    .font(.headline)

                    ForEach(program!.workouts) { workout in
                        List {
                            HStack {
                                NavigationLink {
                                    Text("Do \(workout.name) workout")
                                } label: {
                                    Text(workout.name)
                                }
                                Spacer()
                                Text("tomorrow")
                            }
                        }
                    }
                    .onDelete(perform: deleteWorkouts)
                    Spacer()
                } else {
                    ContentUnavailableView("Use the Programs button at the bottom of the screen to add a new program.", systemImage: "figure.run.square.stack.fill")
                }
            }
            .padding()
            .navigationTitle(program?.name ?? "No Program")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .disabled(program == nil)
                }
                ToolbarItem {
                    Button(action: addWorkout) {
                        Label("Add Workout", systemImage: "plus")
                    }
                    .disabled(program == nil)
                }
            }
            .sheet(item: $newWorkout) { workout in    // TODO animate?
                NavigationStack {
                    EditWorkout(editing: false, program: program!, workout: workout)
                }
                .interactiveDismissDisabled()
            }
        } detail: {
            Text("Select an item")  // TODO do better here
        }
    }

    private func addWorkout() {
        let newWorkout = Workout("Untitled", .anyDay)
        program!.addWorkout(newWorkout)
        self.newWorkout = newWorkout
    }

    // TODO confirm this
    private func deleteWorkouts(offsets: IndexSet) {
        withAnimation {
            program!.deleteWorkouts(offsets)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.shared.modelContainer)
}

#Preview("No Programs") {
    ContentView()
        .modelContainer(NoPreviewData.shared.modelContainer)
}

#Preview("With Content") {
    WithContentView(program: PreviewData.shared.defaultProgram)
        .modelContainer(PreviewData.shared.modelContainer)
}

#Preview("No Content") {
    NoContentView(program: NoPreviewData.shared.defaultProgram)
        .modelContainer(NoPreviewData.shared.modelContainer)
}
