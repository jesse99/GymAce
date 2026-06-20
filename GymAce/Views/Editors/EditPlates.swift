import SwiftUI

struct PlateItem: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let weight: Float
    
    init(_ plate: Plate) {
        self.label = plate.description(.None)
        self.weight = plate.weight
    }
}

struct EditPlates: View {
    @Bindable var model: Model
    @State var items: [PlateItem] = []
    @State private var showNameHelp = false
    @State private var showUnitsHelp = false
    @State private var showBarHelp = false
    @State private var showAlert = false
    @State private var pweight = ""
    @State private var pcount = ""
    @State private var nameErr: String? = ""
    @State private var addErr: String? = nil
    @State var name: String

    init(model: Model, name: String) {
        self.model = model
        _name = State(initialValue: name)
        _items = State(initialValue: getItems())
    }
    
    var body: some View {
        VStack {
            // Name
            HStack {
                TextField("Name", text: nameBinding)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                    .padding(.leading, 10)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showNameHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            .padding(5)
            if showNameHelp {
                Text("The name of the weight set.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }
            if let s = nameErr {
                Text(s)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }

            // Bar
            HStack {
                TextField("Bar", text: barBinding)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.leading, 10)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showBarHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            .padding(5)
            if showBarHelp {
                Text("Optional weight for something like a barbell (which are usually 45 pounds).")
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
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showUnitsHelp {
                Text("Imperial will use pounds. Metric will use kilograms.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }

            // Weights
            List {
                Section(header: Text("Weights")) {
                    ForEach(items) {item in
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
            TextField("Weight", text: $pweight)
            TextField("Count", text: $pcount)
            Button("Save", action: addWeights)
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle("Edit Plates")
        .navigationBarBackButtonHidden(!isValid)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var nameBinding: Binding<String> {
        Binding(
            get: {return name},
            set: {
                if $0.isBlankOrEmpty {
                    nameErr = "The name cannot be empty."
                    return
                }
                if $0 == name {
                    self.nameErr = nil
                    return
                }
                if model.weightSets[$0] != nil {
                    nameErr = "There is already a weight set named \($0)."
                    return
                }
                let oldName = self.name
                self.name = $0
                self.nameErr = nil
                model.renameWeightSet(oldName: oldName, newName: $0)
            }
        )
    }

    private var isValid: Bool {
        nameErr == nil      // note that addErr isn't a blocker
    }

    private func addWeights() {
        guard let weight = Float(self.pweight) else {
            addErr = "Expected a number for Weight, but found '\(self.pweight)'."
            return
        }
        guard let count = Int(self.pcount) else {
            addErr = "Expected a number for Count, but found '\(self.pcount)'."
            return
        }

        if let ws = model.weightSets[name] {
            let p = Plate(weight, count)
            if case .plates(let w) = ws {
                if !w.plates.contains(where: {$0.weight.sameWeight(weight)}) {
                    w.plates.append(p)
                    w.plates.sort(by: >)
                    w.combos = []
                    model.weightSets[name] = .plates(w)

                    items.append(PlateItem(p))
                    items.sort {$0.weight < $1.weight}
                }
            }
        }
    
        self.pweight = ""
        self.pcount = ""
        addErr = nil
    }
    
    private var unitsBinding: Binding<Int> {
        Binding(
            get: {
                if let ws = model.weightSets[name] {
                    if case .plates(let w) = ws {
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
                    if case .plates(let w) = ws {
                        if $0 == 0 {
                            w.units = .Imperial
                        } else {
                            w.units = .Metric
                        }
                        w.combos = []
                        model.weightSets[name] = .plates(w)
                    }
                }
                addErr = nil
            }
        )
    }
    
    private var barBinding: Binding<String> {
        Binding(
            get: {
                if let ws = model.weightSets[name] {
                    if case .plates(let w) = ws {
                        if let weight = w.bar {
                            return formatWeight(weight, .None)
                        }
                    }
                }
                return ""
            },
            set: {
                if let ws = model.weightSets[name] {
                    if case .plates(let w) = ws {
                        w.bar = Float($0)
                        w.combos = []
                        model.weightSets[name] = .plates(w)
                    }
                }
                addErr = nil
            }
        )
    }

    private func getItems() -> [PlateItem] {
        if let ws = model.weightSets[name] {
            if case .plates(let w) = ws {
                let a = w.plates.sorted {$0.weight < $1.weight}
                return a.map {PlateItem($0)}
            }
        }
        return []
    }
    
    // TODO need to confirm this
    private func deleteWeights(offsets: IndexSet) {
        if let ws = model.weightSets[name] {
            if case .plates(let w) = ws {
                for itemIndex in offsets {
                    if let weightIndex = w.plates.firstIndex(where: {$0.weight.sameWeight(items[itemIndex].weight)}) {
                        w.plates.remove(at: weightIndex)
                    }
                }
                model.weightSets[name] = .plates(w)
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
        EditPlates(model: model, name: "Dual Plates")
    }
}
