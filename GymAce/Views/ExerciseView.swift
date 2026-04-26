import SwiftUI
import SwiftData

struct ExerciseView: View {
    @Binding var exercise: Exercise
    @Environment(\.dismiss) var dismiss // Define the environment action

    // TODO
    // need some sort of Exercise.refresh method
    //    call this in onAppear
    //    should reset set state if it's been too long (or it's >= max sets)
    var body: some View {
        VStack {
            // Warmup 3 of 3
            Text(exercise.headline())
                .font(Font.headline.bold())
                .padding(2)
            
            // 5 reps @ 225 lbs
            Text(exercise.subhead())
                .font(Font.subheadline)
            
            // 45x2
            if let s = exercise.footer() {
                Text(s)
                    .font(Font.footnote)
                    .padding(.bottom, 2)
            }
            
            // 90% of 250 lbs
            if let s = exercise.subfooter() {
                Text(s)
                    .font(Font.caption2)
                    .padding(2)
            }
            
            // Next/Finished button
            if exercise.finished() {
                Button("Finished") {
                    exercise.setIndex = 0
                    dismiss()
                }
                .padding(.top, 20)
            } else {
                Button("Next") {
                    exercise.setIndex += 1
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(exercise.name)
        .padding(20)
        Spacer()
    }
}

#Preview {
    @Previewable @State var workout = PreviewData.shared.defaultProgram.workouts[0]
    NavigationStack {
        ExerciseView(exercise: $workout.exercises[0])
            .modelContainer(PreviewData.shared.container)
    }
}

#Preview("second") {
    @Previewable @State var workout = PreviewData.shared.defaultProgram.workouts[1]
    NavigationStack {
        ExerciseView(exercise: $workout.exercises[0])
            .modelContainer(PreviewData.shared.container)
    }
}
