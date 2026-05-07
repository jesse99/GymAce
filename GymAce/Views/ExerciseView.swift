import SwiftUI
import SwiftData

struct ExerciseView: View {
    @Binding var entry: ExerciseEntry
    @Environment(\.dismiss) var dismiss 
    @State private var resting = false
    @State private var targetDate: Date = Date.now

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
                        
            // The way this works is that the user does a set.
            // View will have a Next button (and optionally a picker for actual reps).
            // When that Next is pressed we will show a timer (if there is rest enabled).
            // When resting the button will change to "Stop Resting".
            // If Stop Resting is pressed (or Next with no rest) then the view changes to show the next set.
            // If there are no more sets then the button changes to "Finished".
            
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
                if resting {
                    TimelineView(.periodic(from: .now, by: 1.0)) { context in
                        let remaining = Int(targetDate.timeIntervalSince(context.date))
                        if remaining > 0 {
                            Text(secsToStr(remaining))
                                .font(.largeTitle)
                                .foregroundColor(.red)
                        } else if remaining > -5 {
                            Text("done")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        } else {
                            Text(secsToStr(-remaining) + " over")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        }
                    }
                    Button("Stop Resting") {
                        entry.completedSet()
                        resting = false
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
                        if let rest = entry.rest {
                            resting = true
                            targetDate = Date().addingTimeInterval(TimeInterval(rest))
                        } else {
                            entry.completedSet()
                        }
                    }
                    .padding(.top, 20)
                }
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
