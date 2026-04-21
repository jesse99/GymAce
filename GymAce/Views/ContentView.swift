import SwiftUI
import SwiftData

/// Shows the workouts in the active program and when they are due. Note that the workouts
/// are ordered by when they are due (e.g. if a workout is due today it will be shown
/// first) and workouts may appear multiple times (e.g. due might be today and then
/// "in 7 days").
struct ProgramView: View {
    var today: Date = Date()        // used for custom previews
    @Query(filter: #Predicate<Program> { program in
        program.active
    }) private var programs: [Program]
    @State private var newWorkout: Workout?
    
    private var entries: [WorkoutEntry] {
        var e: [WorkoutEntry] = []
        let calendar = Calendar.current
        for i in (0...20) {
            if let date = calendar.date(byAdding: .day, value: i, to: self.today), let program = self.programs.first {
                e.append(contentsOf: program.findWorkouts(on: date, today: self.today))
            }
        }
        return e
    }

    // TODO
    // probably want to move ProgramView into its own file
    // start using TipView, see https://fatbobman.com/en/posts/mastering-tipkit-basic/
    // need a way to disable/enable a workout (do this in workouts?)
    //    EditProgram should draw disabled workouts in gray
    //    don't show disabled workouts in ProgramView
    // need a toolbar at the bottom
    //    programs view
    //    settings view (for now just imperial or metric)
    //       or should units be part of a weight set?
    //    also need this in NoContentView
    var body: some View {
        Group {
            if let program = programs.first {
                NavigationStack {
                    VStack {
                        // It'd be nicer to use a Grid here but Grid doesn't seem to
                        // work very well with NavigationLink,
                        List {
                            ForEach(entries) { entry in
                                HStack {
                                    NavigationLink {
                                        Text("Do \(entry.workout.name) workout")
                                    } label: {
                                        Text(entry.workout.name)
                                    }
                                    .navigationLinkIndicatorVisibility(.hidden)
                                    Spacer()
                                    Text(entry.label)
                                        .foregroundColor(entry.color)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .navigationTitle("\(program.name) Workouts")
                        .toolbar {
                            NavigationLink {
                                EditProgram(program: program)
                            } label: {
                                Text("Edit")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct NoProgramView: View {
    var body: some View {
        ContentUnavailableView("Use the Programs tab at the bottom of the screen to add a new program.", systemImage: "figure.run.square.stack.fill")
        .padding()
    }
}

struct ContentView: View {
    @Query(filter: #Predicate<Program> { program in
        program.active
    }) var programs: [Program]
    var today: Date = Date()        // used for custom previews
   
    var body: some View {
        Group {
            if !programs.isEmpty {
                ProgramView(today: today)
            } else {
                NoProgramView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.shared.container)
}

#Preview("No Programs") {
    ContentView()
        .modelContainer(NoPreviewData.shared.modelContainer)
}

#Preview("Dates") {
    ScrollView {
        ContentView(today: Calendar.current.date(byAdding: .day, value: 0, to: Date.now)!)
            .modelContainer(PreviewData.shared.container)
        ContentView(today: Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!)
            .modelContainer(PreviewData.shared.container)
        ContentView(today: Calendar.current.date(byAdding: .day, value: 2, to: Date.now)!)
            .modelContainer(PreviewData.shared.container)
        ContentView(today: Calendar.current.date(byAdding: .day, value: 3, to: Date.now)!)
            .modelContainer(PreviewData.shared.container)
        ContentView(today: Calendar.current.date(byAdding: .day, value: 4, to: Date.now)!)
            .modelContainer(PreviewData.shared.container)
    }
}
