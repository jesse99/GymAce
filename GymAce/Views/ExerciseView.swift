import AudioToolbox
import Foundation
import SwiftUI

struct ExerciseView: View { // TODO can use @Environment(\.dynamicTypeSize) to scale font sizes
    var model: Model        // see https://www.swiftyplace.com/blog/swiftui-font-and-texts
    var program: Program
    var workout: Workout
    var exercise: Exercise
    @Bindable var entry: ExerciseEntry
    @Environment(\.dismiss) var dismiss 

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
                .font(Font.headline)
                .padding(2)
            
            // 5 reps @ 225 lbs
            Text(entry.subhead(model, program, exercise))
                .font(Font.body)
            
            // 45x2
            if let s = entry.footer(model, program, exercise) {
                Text(s)
                    .font(Font.body)
                    .padding(.bottom, 2)
            }
            
            // 90% of 250 lbs
            if let s = entry.subfooter(model, program, exercise) {
                Text(s)
                    .font(Font.footnote)
                    .padding(2)
            }
            
            // The way this works is that the user does a set.
            // View will have a Next button (and optionally a picker for actual reps).
            // When that Next is pressed we will show a timer (if there is rest enabled).
            // When resting the button will change to "Stop Resting".
            // If Stop Resting is pressed (or Next with no rest) then the view changes to show the next set.
            // If there are no more sets then the button changes to "Finished".
            
            // Next/Finished button
            if case .finished = entry.mode {
                if canSetWeight() {
                    Stepper("Weight", onIncrement: advanceWeight, onDecrement: dropWeight)
                    .fixedSize()
                }
                Button("Finished") {
                    // We won't call done if the user swipes back but it seems to make
                    // sense to call done only when the user presses Finished...
                    entry.completedAll(workout, exercise)
                    program.didExercise()
                    model.save()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
            } else {
                if case .resting(let target) = entry.mode {
                    TimelineView(.periodic(from: .now, by: 1.0)) { context in
                        let remaining = remainingSecs(now: context.date, target: target)
                        if remaining > 0 {
                            Text(secsToLongStr(remaining))
                                .font(.largeTitle)
                                .foregroundColor(.red)
                        } else if remaining > -5 {
                            Text("Done")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        } else {
                            Text(secsToLongStr(-remaining) + " over")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.top, 5)
                    Button(stopTitle()) {
                        entry.completedSet(exercise)
                        if entry.finished(exercise) {
                            entry.mode = .finished
                        } else {
                            entry.mode = .performing
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 5)
                } else if case .timing(let start, let oldMode) = entry.mode {
                    TimelineView(.periodic(from: .now, by: 1.0)) { context in
                        let remaining = elapsedSecs(now: context.date, start: start)
                        Text(secsToLongStr(remaining))
                            .font(.largeTitle)
                            .foregroundColor(.red)
                    }
                    .padding(.top, 5)
                    Button("Stop Timer") {
                        if oldMode == 2 {
                            entry.mode = .finished
                        } else {
                            entry.mode = .performing
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 5)
                } else {
                    if entry.hasExpected(exercise) {
                        Picker("", selection: expectedBinding) {
                            ForEach(0...entry.maxEpectedHint(exercise), id: \.self) {n in
                                Text("\(n) reps").tag(n)
                            }
                        }
                        .labelsHidden()
                    }
                    Button(nextTitle()) {
                        if let rest = entry.rest(workout, exercise) {
                            entry.mode = .resting(Date().addingTimeInterval(TimeInterval(rest)))
                        } else {
                            entry.completedSet(exercise)
                            
                            // Note that we don't go to picking here because if there's no rest
                            // we always show the picker.
                            if entry.finished(exercise) {
                                entry.mode = .finished
                            } else {
                                entry.mode = .performing
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle(entry.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {    // TODO add Edit Exercise? or minor edits?
                Menu {
                    Button("Reset Exercise", action: resetExercise)
                    if case .performing = entry.mode {
                        Button("Start Timer") {startTimer(0)}
                    } else if case .finished = entry.mode {
                        Button("Start Timer") {startTimer(2)}
                    }
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(20)
        .onAppear {
            entry.started(model, program, workout, exercise)
            print(model.notes.find(exercise.formalName))
        }
        TabView {
            List {
                ForEach(entry.history(exercise), id: \.index) {
                    completedView(model, exercise, $0)
                }
            }
            .listStyle(.plain)
            .tabItem {Label("History", systemImage: "figure.run")}
            
            ScrollView {
                Text(LocalizedStringKey(model.notes.find(exercise.formalName))) // localized so that markdown works
                    .padding(.leading, 5)
            }
            .tabItem {Label("Notes", systemImage: "book.pages")}
        }
    }
    
    private func canSetWeight() -> Bool {
        if case .percent = exercise.data {
            return false
        }
        return exercise.weight != nil && exercise.weightSet != nil && model.weightSets[exercise.weightSet!] != nil
    }
    
    private func advanceWeight() {
        if let w = exercise.weight {
            if let wn = exercise.weightSet {
                if let ws = model.weightSets[wn] {
                    exercise.weight = ws.advance(target: w).value()
                }
            }
        }
    }

    private func dropWeight() {
        if let w = exercise.weight {
            if let wn = exercise.weightSet {
                if let ws = model.weightSets[wn] {
                    exercise.weight = ws.lower(target: w - 0.001).value()
                }
            }
        }
    }
    
    private func nextTitle() -> String {
        if case .durations = exercise.data {
            return "Start"
        }
        return "Next"
    }
    
    private func stopTitle() -> String {
        if case .durations = exercise.data {
            return "Stop"
        }
        return "Stop Resting"
    }
    
    private func resetExercise() {
        entry.mode = .performing
        entry.reset(model, program, exercise)
    }

    private func startTimer(_ oldMode: Int) {
        entry.mode = .timing(Date(), oldMode)
    }
    
    private func remainingSecs(now: Date, target: Date) -> Int {
        let remaining = Int(target.timeIntervalSince(now))
        if remaining == 0 { // can't just drop logic into a view so we'll use a lame side effect
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)    // this version works in the background
        }
        return remaining
    }

    private func elapsedSecs(now: Date, start: Date) -> Int {
        return Int(now.timeIntervalSince(start))
    }
}

// View for a line in the history tab.
@ViewBuilder
private func completedView(_ model: Model, _ exercise: Exercise,_ snapshot: Snapshot) -> some View {
    HStack {
        // icon labeling how well the user did compared to prior workout
        if snapshot.finished {
            if let prior = snapshot.prior {
                let better = snapshot.current.better(prior)
                if better == 1 {
                    Image(systemName: "hand.thumbsup.fill")   // current is better
                        .foregroundColor(.green)
                } else if better == 0 {
                    Image(systemName: "staroflife.fill")   // current is same as prior
                } else {
                    Image(systemName: "hand.thumbsdown.fill")   // current is worse
                        .foregroundColor(.red)
                }
            } else {
                Image(systemName: "staroflife.fill")
            }
        } else {
            Image(systemName: "questionmark.square.dashed")   // in progress
        }
        
        // the date the workout happened
        if let days = Date().daysBetween(snapshot.current.completed) {
            Text(Date().daysStr(days))
        } else {
            Text("?")
        }
        
        // details for the workout
        if snapshot.finished {
            NavigationLink {
                EditCompleted(model: model, exercise: exercise, snapshot: snapshot)
            } label: {
                Text(snapshot.current.details())
            }
            .navigationLinkIndicatorVisibility(.hidden)
            .gridColumnAlignment(.leading)
            .foregroundColor(.blue)
        } else {
            Text(snapshot.current.details())
        }
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[0]
    let exercise = program.findExercise(entry.name)!
    NavigationStack {
        ExerciseView(model: model, program: program, workout: workout, exercise: exercise, entry: entry)
    }
}

#Preview("second") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[1]
    let exercise = program.findExercise(entry.name)!
    NavigationStack {
        ExerciseView(model: model, program: program, workout: workout, exercise: exercise, entry: entry)
    }
}

#Preview("third") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[1]
    let entry = workout.entries[0]
    let exercise = program.findExercise(entry.name)!
    NavigationStack {
        ExerciseView(model: model, program: program, workout: workout, exercise: exercise, entry: entry)
    }
}
