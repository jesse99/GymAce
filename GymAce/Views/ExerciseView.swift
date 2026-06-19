import AudioToolbox
import Foundation
import SwiftUI

fileprivate var heartRates: [String] = []
fileprivate var lastSecs = -1

func getHeartRate(_ secs: Int) -> String? {
    if healthKit.enabled && healthKit.inProgress {
        if secs != lastSecs {
            if abs(secs) % 5 == 0 || lastSecs < 0 {  // fetch often so we should always have a sample
                healthKit.fetchHeartRate()
            }
            if abs(secs) % 10 == 0 {                // sample less because it's beats per minute...
                if let hr = healthKit.popHeartRate() {
                    heartRates.append("\(Int(hr))")
                }
            }
            lastSecs = secs
        }
        if !heartRates.isEmpty {
            return joinLabels(heartRates) + " bpm"
        }
    }
    return nil
}

@ViewBuilder
func createRestingTimerView(_ remaining: Int) -> some View {
    let title: String = if remaining > 0 {  // was getting compiler errors trying to destructure a tuple of (title, color)
        secsToLongStr(remaining)
    } else if remaining > -5 {
        "Done"
    } else {
        secsToLongStr(-remaining) + " over"
    }
    let color: Color = if remaining > 0 {
        .red
    } else if remaining > -5 {
        .green
    } else {
        .green
    }

    Text(title)
        .font(.largeTitle)
        .foregroundColor(color)
}

struct ExerciseView: View { // TODO can use @Environment(\.dynamicTypeSize) to scale font sizes
    var model: Model        // see https://www.swiftyplace.com/blog/swiftui-font-and-texts
    var program: Program
    var workout: Workout
    var exercise: Exercise
    @Bindable var entry: ExerciseEntry
    @State var showHeartRate = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            // Warmup 3 of 3
            Text(entry.headline(exercise))
                .font(.headline)
                .padding(2)
            
            // 5 reps @ 225 lbs
            Text(entry.subhead(model, program, exercise))
                .font(Font.body)
            
            // 45x2
            if let s = entry.footer(model, program, exercise) {
                Text(s)
                    .font(.body)
                    .padding(.bottom, 2)
            }
            
            // 90% of 250 lbs
            if let s = entry.subfooter(model, program, exercise) {
                Text(s)
                    .font(Font.footnote)
                    .padding(2)
            }
            
            if let t = workout.type, t == 24 || t == 37 || t == 46 || t == 52 { // hiking, running, swimming, or walking
                if let value = healthKit.distance {
                    let s = String(format: "%.2f", value*0.000621371)
                    Text("distance: \(s) miles")    // TODO should have a distance to str function? do need to use km if metric tho
                        .font(.body)
                        .padding(.top, 10)
                }
            }
            if showHeartRate {
                TimelineView(.periodic(from: .now, by: 1.0)) {context in
                    if let hr = getHeartRate(Int(context.date.timeIntervalSince1970)) {
                        Text(hr)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.body)
                            .padding(.top, 10)
                    } else {
                        Text("sampling heart rate")
                            .font(.body)
                            .padding(.top, 10)
                    }
                }
            }

            // The way this works is that the user does a set.
            // View will have a Next button (and optionally a picker for actual reps).
            // When that Next is pressed we will show a timer (if there is rest enabled).
            // When resting the button will change to "Stop Resting".
            // If Stop Resting is pressed (or Next with no rest) then the view changes to show the next set.
            // If there are no more sets then the button changes to "Finished".
            
            // Next/Finished button
            if case .finished = entry.mode {
                if canSetWeight() {             // user has done all sets
                    Stepper("Weight", onIncrement: advanceWeight, onDecrement: dropWeight)
                    .fixedSize()
                }
                Button("Finished") {
                    entry.finishedExercise()
                    if healthKit.enabled && healthKit.inProgress && workout.allFinished(program) {
                        healthKit.stop(workout.name)
                    }
                    model.save()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
            } else {
                if case .resting(let target) = entry.mode { // user has finished a set and is now resting
                    TimelineView(.periodic(from: .now, by: 1.0)) { context in
                        let remaining = remainingSecs(now: context.date, target: target)
                        createRestingTimerView(remaining)
                    }
                    .padding(.top, 5)
                    Button(stopTitle()) {
                        entry.completedSet(exercise)
                        if entry.isFinished(exercise) {
                            gotoFinished()
                        } else {
                            entry.mode = .performing
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 5)
                } else if case .manualTimer(let start, let oldMode) = entry.mode {   // user has explicitly started a timer
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
                    if entry.hasExpected(exercise) {    // user is in the middle of a set
                        Picker("", selection: expectedBinding) {
                            ForEach(0...entry.maxEpectedHint(exercise), id: \.self) {n in
                                Text("\(n) reps").tag(n)
                            }
                        }
                        .labelsHidden()
                    }
                    if case .timing = entry.mode, let working = entry.working {
                        TimelineView(.periodic(from: .now, by: 1.0)) { context in
                            let elapsed = Int(context.date.timeIntervalSince(working.started))
                            Text(secsToLongStr(elapsed))
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        }
                        .padding(.top, 5)
                    }
                    Button(nextTitle()) {
                        if let rest = entry.rest(workout, exercise) {
                            entry.mode = .resting(Date().addingTimeInterval(TimeInterval(rest)))
                        } else if case .timed = exercise.data {
                            if case .timing = entry.mode {
                                gotoFinished()
                            } else {
                                entry.mode = .timing
                            }
                        } else {
                            entry.completedSet(exercise)
                            
                            // Note that we don't go to picking here because if there's no rest
                            // we always show the picker.
                            if entry.isFinished(exercise) {
                                gotoFinished()
                            } else {
                                entry.mode = .performing
                            }
                        }
                        recordWorkout()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20)
                }
            }
            if let s = findIssues() {
                Text(s)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.top, 10)
            }
        }
        .navigationTitle(entry.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {   
                Menu {
                    NavigationLink(destination: EditExercise(model: model, program: program, exercise: program.findExercise(entry.name)!)) {
                        Text("Edit Exercise")
                    }
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
            ToolbarItem {
                Button {
                    showHeartRate.toggle()
                    if showHeartRate {
                        heartRates = []
                        lastSecs = -1
                        healthKit.resetHeartRate()
                    }
                } label: {
                    Image(systemName: showHeartRate ? "bolt.heart.fill" : "heart.fill")
                        .foregroundStyle(healthKit.enabled && healthKit.inProgress ? .red : .gray)
                }
            }
        }
        .padding(20)
        .onAppear {
            entry.started(model, program, workout, exercise)
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
            }
            .tabItem {Label("Notes", systemImage: "book.pages")}
        }
    }
    
    private var expectedBinding: Binding<Int> {
        Binding(
            get: {return entry.expectedReps(exercise)},
            set: {entry.setActualReps(exercise, $0)}
        )
    }

    private func findIssues() -> String? {
        var issues = ""
        
        if let wn = exercise.weightSet {
            if model.weightSets[wn] == nil {
                issues += "There is no weight set named '\(wn)'. "
            }
        }
        if case .percent(let d) = exercise.data {
            if program.findExercise(d.other) == nil {
                issues += "Couldn't find a base exercise named '\(d.other)'. "
            }
        }
        if exercise.name != entry.name {
            issues += "The exercise is named \(exercise.name) but the entry is named \(entry.name). "  // shouldn't happen
        }

        return issues.isEmpty ? nil : issues
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
        if case .timed = exercise.data {
            if case .timing = entry.mode {
                return "Stop"
            } else {
                return "Start"
            }
        }
        return "Next"
    }
    
    private func stopTitle() -> String {
        if case .durations = exercise.data {
            return "Stop"
        }
        if case .timed = exercise.data {
            return "Stop"
        }
        return "Stop Resting"
    }
    
    private func resetExercise() {
        entry.mode = .performing
        entry.reset(model, program, exercise)
    }

    private func startTimer(_ oldMode: Int) {
        entry.mode = .manualTimer(Date(), oldMode)
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
    
    private func recordWorkout() {
        if let wt = workout.type, healthKit.enabled && !workout.allFinished(program) && !healthKit.inProgress {
            Task {
                await healthKit.start(wt)
            }
        }
    }
    
    private func gotoFinished() {
        // We want to do this before the user presses the Finished button so that the user can
        // edit the Completed he just did.
        entry.completedLast(workout, exercise)
        program.didExercise()
        entry.mode = .finished
    }
}

// View for a line in the history tab.
@ViewBuilder
private func completedView(_ model: Model, _ exercise: Exercise,_ snapshot: Snapshot) -> some View {
    VStack {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        if let n = snapshot.current.note {
            Text(n)
                .frame(maxWidth: .infinity, alignment: .leading)
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
