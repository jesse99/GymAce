import SwiftUI

/// Shows the workouts in the active program and when they are due. Note that the workouts
/// are ordered by when they are due (e.g. if a workout is due today it will be shown
/// first) and workouts may appear multiple times (e.g. due might be today and then
/// "in 7 days").
struct ProgramView: View {
    var today: Date        // used for custom previews
    @Bindable var model: Model
    @State private var newWorkout: Workout? = nil
    
    private var entries: [WorkoutEntry] {
        var e: [WorkoutEntry] = []
        let calendar = Calendar.current
        for i in (0...20) {
            if let date = calendar.date(byAdding: .day, value: i, to: self.today), let program = model.active() {
                e.append(contentsOf: program.findWorkouts(on: date, today: self.today))
            }
        }
        return e
    }

    // TODO
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
            if let program = model.active() {
                NavigationStack {
                    VStack {
                        // TODO should be able to use a Grid here
                        List {
                            ForEach(entries) { entry in
                                HStack {
                                    NavigationLink {
                                        WorkoutView(model: model, program: program, workout: entry.workout)
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
                        .navigationTitle("\(model.activeProgram) Workouts")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Menu {
                                    NavigationLink(destination: EditProgram(model: model, program: program)) {
                                        Text("Edit Program")
                                    }
                                    NavigationLink(destination: EditPrograms(model: model)) {
                                        Text("Edit Programs")
                                    }
//                                    NavigationLink(destination: Text("Weight Sets")) {
//                                        Text("Edit Weight Sets")  // TODO support these
//                                    }
//                                    NavigationLink(destination: Text("Current Week")) {
//                                        Text("Set Current Week")
//                                    }
                                } label: {
                                    Image(systemName: "line.horizontal.3")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProgramView(today: Date(), model: previewModel())
}

#Preview("Tomorrow") {
    ProgramView(today: Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!, model: previewModel())
}

#Preview("In 2 days") {
    ProgramView(today: Calendar.current.date(byAdding: .day, value: 2, to: Date.now)!, model: previewModel())
}

#Preview("In 3 days") {
    ProgramView(today: Calendar.current.date(byAdding: .day, value: 3, to: Date.now)!, model: previewModel())
}
