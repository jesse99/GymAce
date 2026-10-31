import SwiftUI

/// Shows the workouts in the active program and when they are due. Note that the workouts
/// are ordered by when they are due (e.g. if a workout is due today it will be shown
/// first) and workouts may appear multiple times (e.g. due might be today and then
/// "in 7 days").
struct ProgramView: View {
    var today: Date? = nil        // used for custom previews
    @Bindable var model: Model
    @State private var newWorkout: Workout? = nil
    @State private var viewID = UUID()
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.openURL) private var openUrl
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) var colorScheme

    private var entries: [WorkoutEntry] {
        let today = self.today ?? Date()
        let program = model.active()
        let entries = program?.findScheduledWorkouts(today: today, colorScheme)
        return entries?.flatMap {$0} ?? []
    }

    // TODO
    // need a way to disable/enable a workout (do this in workouts?)
    //    EditProgram should draw disabled workouts in gray
    //    don't show disabled workouts in ProgramView
    var body: some View {
        Group {
            NavigationStack {
                VStack {
                    if let program = model.active() {
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
                    } else {
                        ContentUnavailableView("Use Create Program on the top right to create a workout routine customized for you. Note that you can edit this program after it's created to make it work even better for you. You can also use Edit Programs on the top right to crate a new program from scratch.", systemImage: "figure.run.square.stack.fill")
                        .padding()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            if let program = model.active() {
                                NavigationLink(destination: EditExercises(model: model, program: program)) {
                                    Text("Edit Exercises")
                                }
                                NavigationLink(destination: EditGroups(model: model, program: program)) {
                                    Text("Edit Groups")
                                }
                                NavigationLink(destination: EditNotes(model: model, program: program)) {
                                    Text("Edit Notes")
                                }
                                NavigationLink(destination: EditProgram(model: model, program: program)) {
                                    Text("Edit Program")
                                }
                            }
                            NavigationLink(destination: EditPrograms(model: model)) {
                                Text("Edit Programs")
                            }
                            if let program = model.active() {
                                NavigationLink(destination: EditStyles(model: model, program: program)) {
                                    Text("Edit Styles")
                                }
                            }
                            NavigationLink(destination: EditWeightSets(model: model)) {
                                Text("Edit Weight Sets")
                            }
                            
                            Divider()

                            NavigationLink(destination: WizardView(model)) {
                                Text("Create Program")
                            }
                            Button("Email Feedback", action: emailFeedback)
                            if model.active() != nil {
                                Button("Email Program", action: emailProgram)  // TODO add an option to email completed, maybe as json
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(blueColor(colorScheme))
                        }
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        }
        if let p = model.active(), let s = p.findIssues(model) {
            Spacer()
            Text(s)
                .font(.footnote)
                .foregroundStyle(.red)
                .padding(.top, 10)
        }
    }
    
    private func programTitle() -> String {
        return "\(model.activeProgram) Workouts"
    }

    private func workoutName(_ workout: Workout) -> String {
        return workout.name
    }
    
    private func emailProgram() {
        if let program = model.active() {
            let body = model.dump()
            let urlString = "mailto:?subject=\(program.name) Program&body=\(body)"
            sendEmail(urlString)
        }
    }

    private func emailFeedback() {
        let urlString = "mailto:jesse.vorisek@gmail.com?subject=GymAce Feedback"
        sendEmail(urlString)
    }

    private func sendEmail(_ urlString: String) {
        // Note that the URL class will do any necessary encoding.
        guard let url = URL(string: urlString) else {
            errorMessage = "Failed to send the email: bad URL." // this shouldn't happen
            showErrorAlert = true
            return
        }
        
        openUrl(url) {accepted in
            if !accepted {
                // Unfortunately there's no way to get error information.
                errorMessage = "Failed to send the email."
                showErrorAlert = true
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
