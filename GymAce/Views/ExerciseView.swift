import Foundation
import SwiftUI

struct ExerciseView: View {
    var model: Model
    var program: Program
    var exercise: Exercise
    @Bindable var entry: ExerciseEntry
    @Environment(\.dismiss) var dismiss 
    @State private var resting = false
    @State private var targetDate: Date = Date.now

    private var expectedBinding: Binding<Int> {
        Binding(
            get: {return entry.expectedReps(exercise)},
            set: {entry.setActualReps(exercise, $0)}
        )
    }

    var body: some View {
        VStack {
            // Warmup 3 of 3
            Text(entry.headline(exercise))
                .font(Font.headline.bold())
                .padding(2)
            
            // 5 reps @ 225 lbs
            Text(entry.subhead(model, program, exercise))
                .font(Font.subheadline)
            
            // 45x2
            if let s = entry.footer(model, program) {
                Text(s)
                    .font(Font.footnote)
                    .padding(.bottom, 2)
            }
            
            // 90% of 250 lbs
            if let s = entry.subfooter(model, program, exercise) {
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
            if entry.finished(exercise) {
                Button("Finished") {
                    // We won't call done if the user swipes back but it seems to make
                    // sense to call done only when the user presses Finished...
                    entry.completedAll(exercise)
                    model.save()
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
                    .padding(.top, 5)
                    Button("Stop Resting") {
                        entry.completedSet()
                        resting = false
                    }
                    .padding(.top, 5)
                } else {
                    if entry.hasExpected(exercise) {
                        Picker("", selection: expectedBinding) {
                            ForEach(0...entry.maxEpectedReps(exercise), id: \.self) {n in
                                Text("\(n) reps").tag(n)
                            }
                        }
                        .labelsHidden()
                    }
                    Button("Next") {
                        if let rest = entry.rest(exercise) {
                            resting = true
                            targetDate = Date().addingTimeInterval(TimeInterval(rest))
                        } else {
                            entry.completedSet()
                        }
                    }
                    .padding(.top, 20)
                }
            }
            
            // TODO add a ListView? for history
            //      symbol, short date, worksets & weight
            // TODO history should show in progress stats, no symbol? or a special one?
            // TODO use a disclosure group (https://chriswu.com/posts/swiftui/disclosure1/)
            //      or maybe a TabView to also show notes
            // TODO use a nav link to allow worksets to be edited
        }
        .navigationTitle(entry.name)
        .padding(20)
        .onAppear {
            entry.started(exercise)
        }
        Spacer()
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[0]
    let exercise = program.findExercise(entry.name)!
    NavigationStack {
        ExerciseView(model: model, program: program, exercise: exercise, entry: entry)
    }
}

#Preview("second") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[1]
    let entry = workout.entries[0]
    let exercise = program.findExercise(entry.name)!
    NavigationStack {
        ExerciseView(model: model, program: program, exercise: exercise, entry: entry)
    }
}
