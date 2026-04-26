import SwiftUI
import SwiftData

/// Lists the exercises within a workout.
struct WorkoutView: View {
    // TODO if we store state like when an exercise was started here then
    // we may want to make this @State (or @Obserable?)
    // TODO or maybe that state can be stored at the top level of the store?
    @Bindable var workout: Workout
    
    private var exercisesBinding: Binding<[Exercise]> {
        Binding(
            get: {
                workout.exercises.sorted {
                    $0.order < $1.order
                }
            },
            set: {_ in 
            }
        )
    }

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
            ForEach(exercisesBinding) { $exercise in
                GridRow {
                    NavigationLink {
                        ExerciseView(exercise: $exercise)
                    } label: {
                        Text(exercise.name)
                    }
                    .navigationLinkIndicatorVisibility(.hidden)
                    .gridColumnAlignment( .leading )

                    Text(exercise.details())
                        .gridColumnAlignment( .leading )

                    Text("-")   // TODO implement this, will also need a footer with total duration
                        .gridColumnAlignment( .leading )
                }
            }
        }
        .navigationTitle("\(workout.name) Exercises")
        .padding(10)
        Spacer()
    }
}

#Preview {
    NavigationStack {
        WorkoutView(workout: PreviewData.shared.defaultProgram.workouts.first!)
            .modelContainer(PreviewData.shared.container)
    }
}

#Preview("second)") {
    NavigationStack {
        WorkoutView(workout: PreviewData.shared.defaultProgram.workouts[1])
            .modelContainer(PreviewData.shared.container)
    }
}

#Preview("third)") {
    NavigationStack {
        WorkoutView(workout: PreviewData.shared.defaultProgram.workouts[2])
            .modelContainer(PreviewData.shared.container)
    }
}
