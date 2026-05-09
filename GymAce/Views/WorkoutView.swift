import SwiftUI
import SwiftData

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
                if let exercise = program.findExercise(entry.name) {
                    GridRow {
                        NavigationLink {
                            ExerciseView(model: model, program: program, exercise: exercise, entry: entry)
                        } label: {
                            Text(entry.name)
                        }
                        .navigationLinkIndicatorVisibility(.hidden)
                        .gridColumnAlignment(.leading )
                        
                        Text(exercise.details(model))
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
        .navigationTitle("\(workout.name) Exercises")
        .padding(10)
        Spacer()
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
