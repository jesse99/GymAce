import SwiftUI

/// Shows the workouts in the active program and when they are due. Note that the workouts
/// are ordered by when they are due (e.g. if a workout is due today it will be shown
/// first) and workouts may appear multiple times (e.g. due might be today and then
/// "in 7 days").
struct ProgramView: View {
    var today: Date        // used for custom previews
    @Bindable var model: Model
    @State private var newWorkout: Workout? = nil
    @State private var viewID = UUID()
    @Environment(\.openURL) private var openUrl
    @Environment(\.scenePhase) private var scenePhase

    private var entries: [WorkoutEntry] {
        var e: [WorkoutEntry] = []
        let calendar = Calendar.current
        for i in (0...30) {
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
                                        Text(workoutName(entry.workout))
                                    }
                                    .navigationLinkIndicatorVisibility(.hidden)
                                    Spacer()
                                    Text(entry.label)
                                        .foregroundColor(entry.color)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .navigationTitle(programTitle())
                        .id(viewID)
                        .onAppear {
                            if model.dirty {
                                model.addMissingWeightsets()
                                model.save()
                            }
                        }
                        .onChange(of: scenePhase) {(_, newPhase) in
                            if newPhase == .active {
                                // WorkoutEntry labels change as time passes. This is awkward to handle; a timer
                                // is the obvious solution but we'd have to use a fairly fast timer because timers
                                // are completely suspended when the app is in the background. So instead, we'll
                                // just force the view to rebuild whenever the app becomes active.
                                viewID = UUID()
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Menu {
                                    NavigationLink(destination: EditExercises(model: model, program: program)) {
                                        Text("Edit Exercises")
                                    }
                                    NavigationLink(destination: EditNotes(model: model, program: program)) {
                                        Text("Edit Notes")
                                    }
                                    NavigationLink(destination: EditProgram(model: model, program: program)) {
                                        Text("Edit Program")
                                    }
                                    NavigationLink(destination: EditPrograms(model: model)) {
                                        Text("Edit Programs")
                                    }
                                    NavigationLink(destination: EditWeightSets(model: model)) {
                                        Text("Edit Weight Sets") 
                                    }
                                    Button("Email Program", action: sendEmail)
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
    
    private func programTitle() -> String {
        return "\(model.activeProgram) Workouts"
    }

    private func workoutName(_ workout: Workout) -> String {
        return workout.name
    }
    
    private func sendEmail() {
        if let program = model.active() {
            do {
                // TODO might want to use yaml, or even a custom human readable format
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
                encoder.dateEncodingStrategy = .iso8601

                let data = try encoder.encode(program)
                if let str = String(data: data, encoding: .utf8) {
                    if let body = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        let urlString = "mailto:?subject=\(program.name)%20Program&body=\(body)"
                        guard let url = URL(string: urlString) else { return }
                        
                        openUrl(url) { accepted in
                            if !accepted {
                                // TODO Handle the error, e.g., show an alert
                            }
                        }
                    }
                }
            } catch {
                print("Encoding failed")    // TODO do a better job with this
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
