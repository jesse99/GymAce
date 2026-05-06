import SwiftUI
import SwiftData

struct ExerciseView: View {
    @Binding var entry: ExerciseEntry
    @Environment(\.dismiss) var dismiss 
    @State private var advance = false

    var body: some View {
        VStack {
            // Warmup 3 of 3
            Text(entry.headline())
                .font(Font.headline.bold())
                .padding(2)
            
            // 5 reps @ 225 lbs
            Text(entry.subhead())
                .font(Font.subheadline)
            
            // 45x2
            if let s = entry.footer() {
                Text(s)
                    .font(Font.footnote)
                    .padding(.bottom, 2)
            }
            
            // 90% of 250 lbs
            if let s = entry.subfooter() {
                Text(s)
                    .font(Font.caption2)
                    .padding(2)
            }
            
            // TODO
            // only show reps picker after timer finishes (if there is one)
            
            // Next/Finished button
            if entry.finished() {
                Button("Finished") {
                    // We won't call done if the user swipes back but it seems to make
                    // sense to call done only when the user presses Finished...
                    entry.completedAll()    // TODO this should also save
                    dismiss()
                }
                .padding(.top, 20)
            } else {
                if entry.hasExpected {
                    Picker("", selection: $entry.expectedReps) {
                        ForEach(0...entry.maxEpectedReps, id: \.self) {n in
                            Text("\(n) reps").tag(n)
                        }
                    }
                    .labelsHidden()
                }
                Button("Next") {
                    entry.completedSet()
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(entry.exercise.name)
        .padding(20)
        .onAppear {
            entry.started()
        }
        Spacer()
    }
}

#Preview {
    @Previewable @State var workout = PreviewData.shared.defaultProgram.workouts[0]
    NavigationStack {
        ExerciseView(entry: $workout.entries[0])
            .modelContainer(PreviewData.shared.container)
    }
}

#Preview("second") {
    @Previewable @State var workout = PreviewData.shared.defaultProgram.workouts[1]
    NavigationStack {
        ExerciseView(entry: $workout.entries[0])
            .modelContainer(PreviewData.shared.container)
    }
}
