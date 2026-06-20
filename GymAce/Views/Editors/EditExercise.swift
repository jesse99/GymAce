import SwiftUI

struct MenuItem: Identifiable, Hashable {
    let id = UUID() // Identifiable requirement
    var name: String
}

struct EditExercise: View {
    var model: Model
    var program: Program
    @Bindable var exercise: Exercise
    @State private var showNameHelp = false
    @State private var showFormalHelp = false
    @State private var showWeightPickerHelp = false
    @State private var showWeightHelp = false
    @State private var showWeightSetHelp = false
    @State private var showTypePickerHelp = false
    @State private var formalNames: [MenuItem] = []
    private let weightDelta = 10
    private let weightSets: [String]
    private var workoutsLabel: String = ""

    @State private var durationsData: DurationsData
    @State private var durationsText = ""
    @State private var showDurationsHelp = false
    @State private var durationsErr: String? = nil

    @State private var percentData: PercentData
    @State private var percentOther: Int = -1
    @State private var percentOthers: [String] = []
    @State private var percent: String = ""
    @State private var percentWarmupText = ""
    @State private var percentWorksetsText = ""
    @State private var percentRestText = ""
    @State private var percentErr: String? = nil
    @State private var percentWarmupErr: String? = nil
    @State private var percentWorksetsErr: String? = nil
    @State private var percentRestErr: String? = nil
    @State private var showPercentOtherHelp = false
    @State private var showPercentHelp = false
    @State private var showPercentWarmupHelp = false
    @State private var showPercentWorksetsHelp = false
    @State private var showPercentRestHelp = false

    @State private var repsData: RepsData
    @State private var repsWarmupText = ""
    @State private var repsWorksetsText = ""
    @State private var repsBackoffText = ""
    @State private var repsRestText = ""
    @State private var repsWarmupErr: String? = nil
    @State private var repsWorksetsErr: String? = nil
    @State private var repsBackoffErr: String? = nil
    @State private var repsRestErr: String? = nil
    @State private var showRepsWarmupHelp = false
    @State private var showRepsWorksetsHelp = false
    @State private var showRepsBackoffHelp = false
    @State private var showRepsRestHelp = false

    init(model: Model, program: Program, exercise: Exercise) {
        self.model = model
        self.program = program
        self.exercise = exercise
        self.weightSets = model.weightSets.keys.sorted()
        
        var workouts: [String] = []
        for w in program.workouts {
            if w.entries.contains(where: { $0.name == exercise.name }) {
                workouts.append(w.name)
            }
        }
        if workouts.isEmpty {
            self.workoutsLabel = "This exercise is not part of any workout."
        } else if workouts.count == 1{
            self.workoutsLabel = "Part of the \(workouts[0]) workout."
        } else {
            self.workoutsLabel = "Part of \(workouts.sorted().joined(separator: " and ")) workouts."
        }

        let warmup = [FixedReps(reps: 5, percent: 0), FixedReps(reps: 5, percent: 60), FixedReps(reps: 3, percent: 80), FixedReps(reps: 1, percent: 90)]
        let reps3: [VariableRep] = [.variable(3, 5), .variable(3, 5), .variable(3, 5)]
        switch exercise.data {
        case .durations(let d):
            _durationsData = State(initialValue: d)   // we save this state off so it isn't lost if the user changes type
            _percentData = State(initialValue: PercentData(other: "Missing Exercise", percent: 90, warmups: warmup, workset: reps3, rest: 3*60))
            _repsData = State(initialValue: RepsData(warmups: warmup, worksets: reps3, backoff: [], rest: 3*60))
        case .percent(let d):
            _durationsData = State(initialValue: DurationsData(secs: [30]))
            _percentData = State(initialValue: d)
            _repsData = State(initialValue: RepsData(warmups: warmup, worksets: reps3, backoff: [], rest: 3*60))
        case .reps(let d):
            _durationsData = State(initialValue: DurationsData(secs: [30]))
            _percentData = State(initialValue: PercentData(other: "Missing Exercise", percent: 90, warmups: warmup, workset: reps3, rest: 3*60))
            _repsData = State(initialValue: d)
        case .timed:
            _durationsData = State(initialValue: DurationsData(secs: [30]))
            _percentData = State(initialValue: PercentData(other: "Missing Exercise", percent: 90, warmups: warmup, workset: reps3, rest: 3*60))
            _repsData = State(initialValue: RepsData(warmups: warmup, worksets: reps3, backoff: [], rest: 3*60))
        }
        
        _durationsText = State(initialValue: durationsData.secs.map {secsToShortStr($0)}.joined(separator: " "))

        var names: [String] = []
        for e in program.exercises where e.name != exercise.name {
            names.append(e.name)
        }
        if percentData.other != "Missing Exercise" && !names.contains(percentData.other) {
            names.append(percentData.other)
        }
        names.sort()
        names.append("Missing Exercise")    // TODO don't allow an exercise to be named "Missing Exercise"
        _percentOthers = State(initialValue: names)
        _percent = State(initialValue: "\(percentData.percent)")
        if let index = names.firstIndex(of: percentData.other) {
            _percentOther = State(initialValue: index)
        } else {
            _percentOther = State(initialValue: -1)
        }
        _percentWarmupText = State(initialValue: percentData.warmups.map {$0.asString()}.joined(separator: " "))
        _percentWorksetsText = State(initialValue: percentData.workset.map {$0.asString()}.joined(separator: " "))
        if let s = percentData.rest {
            _percentRestText = State(initialValue: secsToShortStr(s))
        } else {
            _percentRestText = State(initialValue: "")
        }

        _repsWarmupText = State(initialValue: repsData.warmups.map {$0.asString()}.joined(separator: " "))
        _repsWorksetsText = State(initialValue: repsData.workset.map {$0.asString()}.joined(separator: " "))
        _repsBackoffText = State(initialValue: repsData.backoff.map {$0.asString()}.joined(separator: " "))
        if let s = repsData.rest {
            _repsRestText = State(initialValue: secsToShortStr(s))
        } else {
            _repsRestText = State(initialValue: "")
        }
    }
    
    // TODO use onAppear to make the name textbox the focus?
    var body: some View {
        Form {
            // Name
            HStack {
                TextField("Name", text: nameBinding)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showNameHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showNameHelp {
                Text("The name shown in the Workout view.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
            if isNameEmpty {
                Text("Exercise name cannot be empty.")
                    .foregroundColor(.red)
                    .font(.footnote)
            } else if dupeName {
                Text("There is already a exercise with that name.")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            // Formal name
            HStack {
                TextField("Formal Name", text: formalBinding)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                    .foregroundStyle(formalColor(formalBinding.wrappedValue))   // TODO not 100% reliable when editing
                //                    .id(exercise.formalName.hashValue) // think this causes the text field to lose focus when typing
                Menu("", systemImage: "chevron.up.chevron.down") {
                    ForEach($formalNames) {$item in
                        Button(action: {setFormalName(item.name)}, label: {
                            Text(item.name)
                        })
                    }
                }
                .id(formalNames.hashValue) // force redraw if the list changes
                Spacer()
                Button("", systemImage: "info.circle") {
                    showFormalHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showFormalHelp {
                Text("The name used to lookup notes for the exercise.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
            
            // Weight set
            HStack {
                Picker("Weight Set", selection: weightSetBinding) {
                    Text("No Weight Set").tag(-1)
                    ForEach(Array(weightSets.enumerated()), id: \.element) {tuple in
                        Text(tuple.1).tag(tuple.0)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showWeightSetHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showWeightSetHelp {
                if let n = exercise.weightSet {
                    if let ws = model.weightSets[n] {
                        Text(ws.description())
                            .foregroundColor(.blue)
                            .font(.footnote)
                    } else {
                        Text("\(n) has no associated weight set.")
                            .foregroundColor(.blue)
                            .font(.footnote)
                    }
                } else {
                    Text("This exercise has no weights associated with it.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
            }
            
            // Weight
            if let n = exercise.weightSet, let ws = model.weightSets[n] {
                HStack {
                    Picker("", selection: weightsBinding) {
                        ForEach(getWeightLabels(ws), id: \.0) {tuple in
                            Text(tuple.0).tag(tuple.1)  // TODO why is the selection dimmed?
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showWeightPickerHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showWeightPickerHelp {
                    Text("The weight the user should do next using the \(n) weight set.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
            } else {
                HStack {
                    TextField("Weight", text: weightBinding)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showWeightHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showWeightHelp {
                    Text("The weight the user should do next (with no weight set).")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
            }
            
            // Type picker
            HStack {
                Picker("", selection: typeBinding) {
                    Text("Durations").tag(0)
                    Text("Percent").tag(1)
                    Text("Reps").tag(2)
                    Text("Timed").tag(3)
                }
                .pickerStyle(.menu)
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showTypePickerHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showTypePickerHelp {
                if typeBinding.wrappedValue == 0 {
                    Text("Each set is done for a specified amount of time.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                } else if typeBinding.wrappedValue == 1 {
                    Text("Each set is done using weights that are a percentage of another exercise.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                } else if typeBinding.wrappedValue == 1 {
                    Text("Each work set is done using fixed reps, min-max reps, or As Many Reps As Possible (AMRAP).")
                        .foregroundColor(.blue)
                        .font(.footnote)
                } else {
                    Text("The exercise is done for an indefinite amount of time, e.g. jogging.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
            }

            if typeBinding.wrappedValue == 0 {
                // Durations type
                HStack {
                    TextField("Durations", text: durationsBinding)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showDurationsHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showDurationsHelp {
                    Text("The amount of time to do each set. Suffixes can be used, s for seconds, m for minutes, and h for hours. Seconds are assumed if there is no suffix.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = durationsErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
            } else if typeBinding.wrappedValue == 1 {
                // Percent type
                HStack {
                    Picker("Other exercise", selection: percentOtherBinding) {
                        ForEach(Array(percentOthers.enumerated()), id: \.element) {tuple in
                            Text(tuple.1).tag(tuple.0)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showPercentOtherHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showPercentOtherHelp {
                    Text("This name of the exercise to use for the base weight of this exercise.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if program.findExercise(percentOthers[percentOther]) == nil {
                    Text("There is no exercise named '\(percentOthers[percentOther])'.")
                        .foregroundColor(.orange)
                        .font(.footnote)

                }
                
                HStack {
                    TextField("Percent", text: percentBinding)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showPercentHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showPercentHelp {
                    Text("The percentage of the other exercise weight to use for work sets.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = percentErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                HStack {
                    TextField("Warmups", text: percentWarmupBinding)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numbersAndPunctuation)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showPercentWarmupHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showPercentWarmupHelp {
                    Text("Sets to do before the work sets. Formated as 5/80, i.e. 5 reps at 80% of the work set weight.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = percentWarmupErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                HStack {
                    TextField("Worksets", text: percentWorksetsBinding)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numbersAndPunctuation)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showPercentWorksetsHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showPercentWorksetsHelp {
                    Text("Sets to do using the maximum weight. Formated as 5 for five reps, 8-12 for eight to twelve reps, or 3+ for three or more reps.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = percentWorksetsErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                HStack {
                    TextField("Rest", text: percentRestBinding)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showPercentRestHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showPercentRestHelp {
                    Text("The amount of time to do rest after each set. Suffixes can be used, s for seconds, m for minutes, and h for hours. Seconds are assumed if there is no suffix.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = percentRestErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

            } else if typeBinding.wrappedValue == 2 {
                // Reps type
                HStack {
                    TextField("Warmups", text: repsWarmupBinding)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numbersAndPunctuation)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showRepsWarmupHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showRepsWarmupHelp {
                    Text("Sets to do before the work sets. Formated as 5/80, i.e. 5 reps at 80% of the work set weight.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = repsWarmupErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                HStack {
                    TextField("Worksets", text: repsWorksetsBinding)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numbersAndPunctuation)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showRepsWorksetsHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showRepsWorksetsHelp {
                    Text("Sets to do using the maximum weight. Formated as 5 for five reps, 8-12 for eight to twelve reps, or 3+ for three or more reps.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = repsWorksetsErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                HStack {
                    TextField("Backoff", text: repsBackoffBinding)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numbersAndPunctuation)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showRepsBackoffHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showRepsBackoffHelp {
                    Text("Sets to do after the work sets.  Formated as 5/80, i.e. 5 reps at 80% of the work set weight.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = repsBackoffErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                HStack {
                    TextField("Rest", text: repsRestBinding)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showRepsRestHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showRepsRestHelp {
                    Text("The amount of time to do rest after each set. Suffixes can be used, s for seconds, m for minutes, and h for hours. Seconds are assumed if there is no suffix.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = repsRestErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            Text(workoutsLabel)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!isValid)
        .onAppear {
            model.dirty = true
        }
    }
    
    private var typeBinding: Binding<Int> {
        Binding(
            get: {
                switch exercise.data {
                case .durations(_): return 0
                case .percent(_): return 1
                case .reps(_): return 2
                case .timed: return 3
                }
            },
            set: {
                if $0 == 0 {
                    exercise.data = .durations(durationsData)
                } else if $0 == 1 {
                    exercise.data = .percent(percentData)
                } else if $0 == 2 {
                    exercise.data = .reps(repsData)
                } else {
                    exercise.data = .timed
                }
            }
        )
    }
    
    private var durationsBinding: Binding<String> {
        Binding(
            get: {
                return durationsText
            },
            set: {
                var a: [Int] = []
                durationsText = $0
                for s in $0.split(separator: " ") {
                    if let s = parseShortSecs(String(s)) {
                        a.append(s)
                    } else {
                        durationsErr = "Expected a number with an optional time suffix, not '\(s)'."
                        return
                    }
                }
                if a.isEmpty {
                    durationsErr = "Need at least one set."
                } else {
                    durationsErr = nil
                    durationsData.secs = a
                    exercise.data = .durations(durationsData)
                }
            }
        )
    }

    private var percentOtherBinding: Binding<Int> {
        Binding(
            get: {
                return percentOther
            },
            set: {
                percentOther = $0
                percentData.other = percentOthers[$0]
                exercise.data = .percent(percentData)
            }
        )
    }
    
    private var percentBinding: Binding<String> {
        Binding(
            get: {
                return percent
            },
            set: {
                percent = $0
                if let n = Int($0) {
                    percentErr = nil
                    percentData.percent = n
                    exercise.data = .percent(percentData)
                } else {
                    percentErr = "Expected a number for percent, not '\($0)'."
                }
            }
        )
    }

    private var percentWarmupBinding: Binding<String> {
        Binding(
            get: {
                return percentWarmupText
            },
            set: {
                var a: [FixedReps] = []
                percentWarmupText = $0
                for s in $0.split(separator: " ") {
                    if let r = FixedReps(String(s)) {
                        a.append(r)
                    } else {
                        percentWarmupErr = "Expected a number for reps and a percent, e.g. 5/80, not '\(s)'."
                        return
                    }
                }
                percentWarmupErr = nil
                percentData.warmups = a
                exercise.data = .percent(percentData)
            }
        )
    }

    private var percentWorksetsBinding: Binding<String> {
        Binding(
            get: {
                return percentWorksetsText
            },
            set: {
                var a: [VariableRep] = []
                percentWorksetsText = $0
                for s in $0.split(separator: " ") {
                    if let r = VariableRep(String(s)) {
                        a.append(r)
                    } else {
                        percentWorksetsErr = "Expected a rep, rep range, or As Many Reps As Possible, not '\(s)'."
                        return
                    }
                }
                if a.isEmpty {
                    percentWorksetsErr = "Need at least one set."
                } else {
                    percentWorksetsErr = nil
                    percentData.workset = a
                    exercise.data = .percent(percentData)
                }
            }
        )
    }
    
    private var percentRestBinding: Binding<String> {
        Binding(
            get: {
                return percentRestText
            },
            set: {
                percentRestText = $0
                if let s = parseShortSecs($0) {
                    percentRestErr = nil
                    percentData.rest = s
                    exercise.data = .percent(percentData)
                } else if $0.isBlankOrEmpty {
                    percentRestErr = nil
                    percentData.rest = nil
                    exercise.data = .percent(percentData)
                } else {
                    percentRestErr = "Expected nothing or a number with an optional time suffix, not '\($0)'."
                }
            }
        )
    }

    private var repsWarmupBinding: Binding<String> {
        Binding(
            get: {
                return repsWarmupText
            },
            set: {
                var a: [FixedReps] = []
                repsWarmupText = $0
                for s in $0.split(separator: " ") {
                    if let r = FixedReps(String(s)) {
                        a.append(r)
                    } else {
                        repsWarmupErr = "Expected a number for reps and a percent, e.g. 5/80, not '\(s)'."
                        return
                    }
                }
                repsWarmupErr = nil
                repsData.warmups = a
                exercise.data = .reps(repsData)
            }
        )
    }

    private var repsWorksetsBinding: Binding<String> {
        Binding(
            get: {
                return repsWorksetsText
            },
            set: {
                var a: [VariableRep] = []
                repsWorksetsText = $0
                for s in $0.split(separator: " ") {
                    if let r = VariableRep(String(s)) {
                        a.append(r)
                    } else {
                        repsWorksetsErr = "Expected a rep, rep range, or As Many Reps As Possible, not '\(s)'."
                        return
                    }
                }
                if a.isEmpty {
                    repsWorksetsErr = "Need at least one set."
                } else {
                    repsWorksetsErr = nil
                    repsData.workset = a
                    exercise.data = .reps(repsData)
                }
            }
        )
    }
    
    private var repsBackoffBinding: Binding<String> {
        Binding(
            get: {
                return repsBackoffText
            },
            set: {
                var a: [FixedReps] = []
                repsBackoffText = $0
                for s in $0.split(separator: " ") {
                    if let r = FixedReps(String(s)) {
                        a.append(r)
                    } else {
                        repsBackoffErr = "Expected a number for reps and a percent, e.g. 5/80, not '\(s)'."
                        return
                    }
                }
                repsBackoffErr = nil
                repsData.backoff = a
                exercise.data = .reps(repsData)
            }
        )
    }

    private var repsRestBinding: Binding<String> {
        Binding(
            get: {
                return repsRestText
            },
            set: {
                repsRestText = $0
                if let s = parseShortSecs($0) {
                    repsRestErr = nil
                    repsData.rest = s
                    exercise.data = .reps(repsData)
                } else if $0.isBlankOrEmpty {
                    repsRestErr = nil
                    repsData.rest = nil
                    exercise.data = .reps(repsData)
                } else {
                    repsRestErr = "Expected nothing or a number with an optional time suffix, not '\($0)'."
                }
            }
        )
    }

    private var nameBinding: Binding<String> {
        Binding(
            get: {return exercise.name},
            set: {program.setExerciseName(exercise, $0)}
        )
    }

    private var formalBinding: Binding<String> {
        Binding(
            get: {return exercise.formalName},
            set: {
                exercise.formalName = $0
                formalNames = []
                for n in model.notes.defaults.keys {
                    if n.lowercased().contains($0.lowercased()) {   // only show formal names that match current formal name
                        let item = MenuItem(name: n)
                        formalNames.append(item)
                        if formalNames.count > 30 {
                            formalNames.append(MenuItem(name: "…"))
                            break
                        }
                    }
                }
                for n in model.notes.custom.keys {
                    if n.lowercased().contains($0.lowercased()) && model.notes.defaults[n] == nil {
                        let item = MenuItem(name: n)
                        formalNames.append(item)
                        if formalNames.count > 30 {
                            formalNames.append(MenuItem(name: "…"))
                            break
                        }
                    }
                }
                formalNames.sort() {$0.name < $1.name}
            }
        )
    }
    
    private var weightSetBinding: Binding<Int> {
        Binding(
            get: {
                if let n = exercise.weightSet {
                    return weightSets.firstIndex(of: n) ?? 0
                } else {
                    return -1
                }
            },
            set: {
                if $0 == -1 {
                    exercise.weightSet = nil
                } else {
                    exercise.weightSet = weightSets[$0]
                }
            }
        )
    }

    private func formalColor(_ name: String) -> Color {
        if model.notes.defaults[name] != nil || model.notes.custom[name] != nil {
            return .black
        } else {
            return .red
        }
    }

    private func setFormalName(_ name: String) {
        exercise.formalName = name
        formalNames = []
    }

    // Return a friendly label for the weight along with an arbitrary tag.
    private func getWeightLabels(_ ws: WeightSet) -> [(String, Int)] {
        var labels: [(String, Int)] = []
        
        let w = exercise.weight ?? 0.0
        var actual = ActualWeight(discrete: w, ws.units)
        for _ in 1...weightDelta {
            let old = actual.text()
            actual = ws.lower(target: actual.value() - 0.001)
            if actual.text() != old {
                labels.append((actual.text(), Int(1000*actual.value())))
            } else {
                break
            }
        }
        labels.reverse()

        actual = ActualWeight(discrete: w, ws.units)
        labels.append((actual.text(), Int(1000*actual.value())))

        for _ in 1...weightDelta {
            let old = actual.text()
            actual = ws.advance(target: actual.value() + 0.001)
            if actual.text() != old && actual.value() != Float.greatestFiniteMagnitude {    // TODO ugh
                labels.append((actual.text(), Int(1000*actual.value())))
            } else {
                break
            }
        }
        return labels
    }
    
    private var weightBinding: Binding<String> {
        Binding(
            get: {
                if let w = exercise.weight, w > 0.0 {
                    return formatWeight(w, .None)
                } else {
                    return ""   // this will show the placeholder text
                }
            },
            set: {exercise.weight = Float($0)}
        )
    }

    private var weightsBinding: Binding<Int> {
        Binding(
            get: {
                // Current value is always the current exercise weight.
                let w = exercise.weight ?? 0.0
                return Int(1000*w)
            },
            set: {exercise.weight = Float($0)/1000.0}
        )
    }

    private var isNameEmpty: Bool {
        self.exercise.name.isEmpty
    }

    private var dupeName: Bool {
        self.program.exercises.count(where: {
            $0 !== self.exercise && $0.name == self.exercise.name
        }) > 0
    }

    private var isValid: Bool {
//        print("isNameEmpty: \(isNameEmpty) dupeName: \(dupeName)")
        guard !isNameEmpty && !dupeName else {
            return false
        }
        switch exercise.data {
        case .durations(_):
            return durationsErr == nil
        case .percent(_):
            return percentErr == nil // TODO make sure this is up to date
        case .reps(_):
            return repsWarmupErr == nil && repsWorksetsErr == nil && repsBackoffErr == nil && repsRestErr == nil
        case .timed:
            return true
        }

    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[0]
    NavigationView {
        EditExercise(model: model, program: program, exercise: program.findExercise(entry.name)!)
    }
}

#Preview("Two") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[1]
    NavigationView {
        EditExercise(model: model, program: program, exercise: program.findExercise(entry.name)!)
    }
}

#Preview("Three") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[2]
    NavigationView {
        EditExercise(model: model, program: program, exercise: program.findExercise(entry.name)!)
    }
}
