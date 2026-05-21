import SwiftUI

/// Lists the exercises within a workout.
struct WorkoutView: View {
    var model: Model
    var program: Program
    @Bindable var workout: Workout
    
    // TODO will have nav links so need to use a list?
    //      or will grid work if we disable the chevron?
    // TODO should Workout have info about the current workout?
    //      eg how long has been spent on an exercise
    //      would need some logic to invalidate this
    // TODO when a workout starts may want to tell Apple watch
    //      see https://developer.apple.com/documentation/HealthKit/running-workout-sessions
    //      when last exercise in a workout is completed stop the workout
    // TODO may also want to allow background processing via workout-processing
    //      see https://developer.apple.com/documentation/xcode/configuring-background-execution-modes
    //      normally apps are suspended when in the background so this might make vibrate more reliable
    var body: some View {
        Grid( horizontalSpacing: 20, verticalSpacing: 10 ) {
            GridRow {
                Text("Exercise").bold()
                    .gridColumnAlignment( .leading )
                Text("Details").bold()
                    .gridColumnAlignment( .leading )
                Text("Duration").bold()
                    .gridColumnAlignment( .leading )
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
                                .gridColumnAlignment( .leading )
                            
                            Text("-")   // TODO implement this, will also need a footer with total duration
                                .gridColumnAlignment( .leading )
                        }
                    } else {
                        GridRow {
                            Text(entry.name)
                                .gridColumnAlignment(.leading )
                            Text("not found")
                                .gridColumnAlignment( .leading )
                            Text("-")
                                .gridColumnAlignment( .leading )
                        }
                    }
                }
            }
        }
        .navigationTitle("\(workout.name) Exercises")
        .padding(10)
        Spacer()
    }
    
    func fgColor(_ entry: ExerciseEntry, _ exercise: Exercise) -> Color {
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
