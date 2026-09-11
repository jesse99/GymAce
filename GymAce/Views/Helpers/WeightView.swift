import SwiftUI

// Base weight picker, weight set picker, weight editor.
struct WeightView: View {
    var model: Model
    @Bindable var exercise: Exercise
    
    @State private var weight = Float(0.0)
    @State private var showBaseWeightHelp = false
    @State private var showWeightPickerHelp = false
    @State private var showWeightHelp = false
    @State private var showWeightSetHelp = false
    private let weightDelta = 10
    private let weightSets: [String]
    
    init(model: Model, exercise: Exercise) {
        self.model = model
        self.exercise = exercise
        self.weightSets = model.weightSets.keys.sorted()
        
        // We save this state off so it isn't lost if the user changes type.
        if case .weight(let w) = exercise.baseWeight {
            _weight = State(initialValue: w)
        }
    }
    
    var body: some View {
        // Base weight type
        HStack {
            Picker("Base weight type", selection: baseWeightBinding) {
                Text("No Weight").tag(0)
                Text("Other Weight").tag(1)
                Text("Has Weight").tag(2)
            }
            .pickerStyle(.menu)
            .labelsHidden()
            Spacer()
            Button("", systemImage: "info.circle") {
                showBaseWeightHelp.toggle()
            }
            .buttonStyle(.plain)
            .padding(.leading, 5)
        }
        if showBaseWeightHelp {
            switch exercise.baseWeight {
            case .none:
                Text("The exercise doesn't have a weight.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            case .other:
                Text("The exercise uses the weight of another exercise found using the formal name.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            case .weight:
                Text("The exercise has a weight.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
        }
        
        if hasWeight() {
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
        }
        
        if case .weight = exercise.baseWeight {
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
                    weightTextField("Weight", weightBinding)
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
        }
    }
    
    private var baseWeightBinding: Binding<Int> {
        Binding(
            get: {
                switch exercise.baseWeight {
                case .none:
                    return 0
                case .other:
                    return 1
                case .weight:
                    return 2
                }
            },
            set: {
                if $0 == 0 {
                    exercise.baseWeight = .none
                } else if $0 == 1 {
                    exercise.baseWeight = .other
                } else {
                    exercise.baseWeight = .weight(self.weight)
                }
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
    
    private var weightBinding: Binding<String> {
        Binding(
            get: {
                if case .weight(let w) = exercise.baseWeight, w > 0.0 {
                    return formatWeight(w, .None)
                } else {
                    return ""   // this will show the placeholder text
                }
            },
            set: {
                if let w = Float($0) {
                    exercise.baseWeight = .weight(w)
                    self.weight = w
                } else {
                    exercise.baseWeight = .none
                }
            }
        )
    }
    
    private var weightsBinding: Binding<Int> {
        Binding(
            get: {
                // Current value is always the current exercise weight.
                let w = if case .weight(let w) = exercise.baseWeight {
                    w
                } else {
                    Float(0.0)
                }
                return Int(1000*w)
            },
            set: {
                let w = Float($0)/1000.0
                exercise.baseWeight = .weight(w)
                self.weight = w
            }
        )
    }
    
    // Return a friendly label for the weight along with an arbitrary tag.
    private func getWeightLabels(_ ws: WeightSet) -> [(String, Int)] {
        var labels: [(String, Int)] = []
        
        let w = if case .weight(let w) = exercise.baseWeight {
            w
        } else {
            Float(0.0)
        }
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
    
    private func hasWeight() -> Bool {
        switch exercise.baseWeight {
        case .none:
            return false
        case .other, .weight:
            return true
        }
    }

}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[0]
    WeightView(model: model, exercise: program.findExercise(entry.name)!)
}

#Preview("Two") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[1]
    WeightView(model: model, exercise: program.findExercise(entry.name)!)
}

#Preview("Three") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    let entry = workout.entries[2]
    WeightView(model: model, exercise: program.findExercise(entry.name)!)
}
