import SwiftUI
import SwiftData

/// Shows the workouts in the active program and when they are due. Note that the workouts
/// are ordered by when they are due (e.g. if a workout is due today it will be dhown
/// first) and workouts may appear multiple times (e.e. due might be today and then
/// "in 7 days").
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Program> { program in
        program.active
    }) var programs: [Program]
    var program: Program? { programs.first }
    @State private var newWorkout: Workout?

    // TODO
    // have a due date col
    //    probably want a computed property to create sorted tuple list
    //    tuple has (workout, due date text, due date color)
    //    may want this view to take a now argument so we can test different dates
    //       might get stale though, maybe nil can be current time?
    // sort by due date, maybe secondary sort by name
    // need a way to disable/enable a workout (do this in workouts?)
    // for help use TipKit or popovers?
    // need a toolbar at the bottom
    //    programs view
    //    settings view (for now just imperial or metric)
    //       or should units be part of a weight set?
    //    also need this in NoContentView
    var body: some View {
        Group {
            if program != nil {
                NavigationView {
                    VStack {
                        // It'd be nicer to use a Grid here but Grid doesn't seem to
                        // work very well with NavigationLink,
                        List {
                            ForEach(program!.workouts) { workout in
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
                        }
                        .listStyle(.plain)
                        .navigationTitle("\(program!.name) Workouts")
                        .toolbar {
                            NavigationLink {
                                EditProgram(program: program!)
                            } label: {
                                Text("Edit")
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView("Use the Programs tab at the bottom of the screen to add a new program.", systemImage: "figure.run.square.stack.fill")
                .padding()
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
