import SwiftUI

struct DiscreteItem: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let weight: Float
    
    init(_ weight: Float) {
        self.label = formatWeight(weight, .None)
        self.weight = weight
    }
}

struct EditDiscrete: View {
    @Bindable var model: Model
    @State var items: [DiscreteItem] = []
    @State private var showUnitsHelp = false
    @State private var showWeight1Help = false
    @State private var showWeight2Help = false
    @State private var showAlert = false
    @State private var from = ""
    @State private var to = ""
    @State private var by = ""
    @State private var addErr: String? = nil
    let name: String
    
    init(model: Model, name: String) {
        self.model = model
        self.name = name
        _items = State(initialValue: getItems())
    }
    
    var body: some View {
        VStack {
            // Units picker
            HStack {                // TODO probably should be in a Form but the spacing is really annoying
                Picker("", selection: unitsBinding) {
                    Text("Imperial").tag(0)
                    Text("Metric").tag(1)
                }
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showUnitsHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(5)
            if showUnitsHelp {
                Text("Imperial will use pounds. Metric will use kilograms.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }

            // Extra 1
            HStack {
                TextField("Extra weight 1", text: extra1Binding)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .padding(.leading, 10)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showWeight1Help.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            .padding(5)
            if showWeight1Help {
                Text("An extra weight the user can add, e.g. a magnet to a dumbbell or a small weight on a cable machine.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .padding(.leading, 15)
                    .padding(.trailing, 5)
            }

            // Extra 2
            HStack {
                TextField("Extra weight 2", text: extra2Binding)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .padding(.leading, 10)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showWeight2Help.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showWeight2Help {
                Text("An extra weight the user can add, e.g. a magnet to a dumbbell or a small weight on a cable machine.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .padding(.leading, 15)
                    .padding(.trailing, 5)
            }
            
            if let s = addErr {
                Text(s)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)

            }

            // Weights
            List {
                Section(header: Text("Weights")) {
                    ForEach($items) { $item in
                        Text(item.label)
                    }
                    .onDelete(perform: deleteWeights)
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("", systemImage: "plus") {
                        showAlert.toggle()
                    }
                }
            }
            Spacer()
        }
        .alert("Add Weights", isPresented: $showAlert) {
            TextField("From", text: $from)
            TextField("To", text: $to)
            TextField("By", text: $by)
            Button("Save", action: addWeights)
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle("Edit \(name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addWeights() {
        guard let from = Float(self.from) else {
            addErr = "Expected a number for From, but found '\(self.from)'."
            return
        }
        if self.to.isBlankEmpty && self.by.isBlankEmpty {
            addWeight(from)
            self.from = ""
            self.to = ""
            self.by = ""
            addErr = nil
        } else {
            if let to = Float(self.to), let by = Float(self.by) {
                var weight = from
                while weight <= to {
                    addWeight(weight)
                    weight += by
                }
                self.from = ""
                self.to = ""
                self.by = ""
                addErr = nil
            } else {
                var err = ""
                if self.to.isBlankEmpty {
                    err += "To must be set if by is set. "
                } else if Float(self.to) == nil {
                    err += "Expected a number for To, but found '\(self.to)'. "
                }
                if self.by.isBlankEmpty {
                    err += "By must be set if to is set. "
                } else if Float(self.by) == nil {
                    err += "Expected a number for By, but found '\(self.by)'. "
                }
                addErr = err
            }
        }
    }
    
    private func addWeight(_ weight: Float) {
        if let ws = model.weightSets[name] {
            if case .discrete(var w) = ws {
                if !w.weights.contains(where: {$0.sameWeight(weight)}) {
                    w.weights.append(weight)
                    w.weights.sort(by: <)
                    model.weightSets[name] = .discrete(w)
                    
                    items.append(DiscreteItem(weight))
                    items.sort {$0.weight < $1.weight}
                }
            }
        }
    }
    
    private var unitsBinding: Binding<Int> {
        Binding(
            get: {
                if let ws = model.weightSets[name] {
                    if case .discrete(let w) = ws {
                        switch w.units {
                        case .Imperial: return 0
                        case .Metric: return 1
                        case .None: return 0        // fatal error?
                        }
                    }
                }
                return 0
            },
            set: {
                if let ws = model.weightSets[name] {
                    if case .discrete(var w) = ws {
                        if $0 == 0 {
                            w.units = .Imperial
                        } else {
                            w.units = .Metric
                        }
                        model.weightSets[name] = .discrete(w)
                    }
                }
                addErr = nil
            }
        )
    }
    
    private var extra1Binding: Binding<String> {
        Binding(
            get: {
                if let ws = model.weightSets[name] {
                    if case .discrete(let w) = ws {
                        if let weight = w.extra1 {
                            return formatWeight(weight, .None)
                        }
                    }
                }
                return ""
            },
            set: {
                if let ws = model.weightSets[name] {
                    if case .discrete(var w) = ws {
                        w.extra1 = Float($0)
                        model.weightSets[name] = .discrete(w)
                    }
                }
                addErr = nil
            }
        )
    }

    private var extra2Binding: Binding<String> {
        Binding(
            get: {
                if let ws = model.weightSets[name] {
                    if case .discrete(let w) = ws {
                        if let weight = w.extra2 {
                            return formatWeight(weight, .None)
                        }
                    }
                }
                return ""
            },
            set: {
                if let ws = model.weightSets[name] {
                    if case .discrete(var w) = ws {
                        w.extra2 = Float($0)
                        model.weightSets[name] = .discrete(w)
                    }
                }
                addErr = nil
            }
        )
    }

    private func getItems() -> [DiscreteItem] {
        if let ws = model.weightSets[name] {
            if case .discrete(let w) = ws {
                let a = w.weights.sorted()
                return a.map {DiscreteItem($0)}
            }
        }
        return []
    }
    
    // TODO need to confirm this
    private func deleteWeights(offsets: IndexSet) {
        if let ws = model.weightSets[name] {
            if case .discrete(var w) = ws {
                for itemIndex in offsets {
                    if let weightIndex = w.weights.firstIndex(where: {$0.sameWeight(items[itemIndex].weight)}) {
                        w.weights.remove(at: weightIndex)
                    }
                }
                model.weightSets[name] = .discrete(w)
            }
        }
        withAnimation {
            items.remove(atOffsets: offsets)
        }
        addErr = nil
    }
}

#Preview {
    let model = previewModel()
    NavigationView {
        EditDiscrete(model: model, name: "Dumbbells")
    }
}
