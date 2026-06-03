import SwiftUI

/// Lists the exercises within a workout.
struct WorkoutView: View {
    var model: Model
    var program: Program
    @Bindable var workout: Workout
    
    // TODO may want to allow background processing via workout-processing
    //      see https://developer.apple.com/documentation/xcode/configuring-background-execution-modes
    //      just need to add Audio background capability?
    //      normally apps are suspended when in the background so this might make vibrate more reliable
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 10) {
            GridRow {
                Text("Exercise").bold()
                    .gridColumnAlignment(.leading)
                Text("Details").bold()
                    .gridColumnAlignment(.leading)
            }
            ForEach($workout.entries, id: \.name) { $entry in
                if entry.enabled {
                    if let exercise = program.findExercise(entry.name) {
                        GridRow {
                            NavigationLink {
                                ExerciseView(model: model, program: program, workout: workout, exercise: exercise, entry: entry)
                            } label: {
                                Text(entry.name)
                            }
                            .navigationLinkIndicatorVisibility(.hidden)
                            .gridColumnAlignment(.leading)
                            .foregroundColor(fgColor(entry, exercise))
                            
                            Text(exercise.details(model, program))
                                .gridColumnAlignment(.leading)
                        }
                    } else {
                        GridRow {
                            Text(entry.name)
                                .gridColumnAlignment(.leading )
                            Text("not found")
                                .gridColumnAlignment(.leading)
                        }
                    }
                }
            }
            if let wt = workout.type, healthKit.enabled && !workout.allFinished(program) {
                if !healthKit.inProgress {
                    // We require the user to manually start this so that a workout isn't started when
                    // the user is just poking around.
                    Button("Record Workout", action: {Task {await healthKit.start(wt)}})
                        .padding(.top, 25)
                } else {
                    // We do automatically stop the workout once the user finishes all the exercises
                    // but, if they're only doing some of the exercises, we also allow them to stop
                    // recording early.
                    //
                    // TODO it'd be nice if there was a way to end the workout if the
                    // user forgot to hit stop. A timer is a possibility but it's not
                    // clear that will run when the app is in the background (they
                    // normally won't but I think when a HeathKit workout is running
                    // they might). Or if the user goes back to the ProgramView we
                    // could stop the workout? Note that if we use a timer we'll
                    // probably want to reset it as the user does stuff. And it'd
                    // have to have a pretty long duration in case the workout is
                    // something like walking or a long run.
                    Button("Stop Recording", action: {healthKit.stop(workout.name)})
                        .padding(.top, 25)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationTitle("\(workout.name) Exercises")
        .padding(10)
        Spacer()
        if let s = footer() {
            Text(s)
                .font(.footnote)
        } else if !workout.notes.isEmpty {
            Text(workout.notes)
                .font(.footnote)
        }
    }
    
    private func footer() -> String? {
        var s: String? = nil
        
        if let elapsed = workout.elapsed {
            if elapsed > 2*60 {
                s = "Worked out for \(secsToLongStr(Int(elapsed))). "
            }
        }
        if let status = healthKit.status, let h = status.text(workout.name) {
            if let t = s {
                s = t + h
            } else {
                s = h
            }
        }

        return s
    }
    
    private func fgColor(_ entry: ExerciseEntry, _ exercise: Exercise) -> Color {
        if let latest = exercise.latestCompleted(), latest.completed.daysBetween(Date()) == 0 {
            return .black
        } else {
            return .blue
        }
    }
}

#Preview("Upper") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    NavigationStack {
        WorkoutView(model: model, program: program, workout: workout)
    }
}

#Preview("Lower)") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[1]
    NavigationStack {
        WorkoutView(model: model, program: program, workout: workout)
    }
}

#Preview("Active Rest)") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[2]
    NavigationStack {
        WorkoutView(model: model, program: program, workout: workout)
    }
}
