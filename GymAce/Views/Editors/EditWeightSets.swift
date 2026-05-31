import SwiftUI

struct EditWeightSets: View {
    @Bindable var model: Model
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Weight Sets")) {
                    ForEach(model.weightSets.keys.sorted(), id: \.self) { name in
                        NavigationLink {
                            let tag = self.tag(name)
                            if tag == 0 {
                                EditDiscrete(model: model, name: name)
                            } else if tag == 1 {
                                EditPlates(model: model, name: name)
                            } else if tag == 2 {
                                EditPlates(model: model, name: name)
                            }
                        } label: {
                            Text(name)
                        }
                    }
                    .onDelete(perform: deleteWeightSets)
                }
            }
            .listStyle(.plain)
            .onAppear {
                model.dirty = true
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Menu {
                        // TODO use current region to figure out default units
                        Button("Add Discrete", action: {addWeightSet(.discrete(DiscreteWeights(weights: [], units: .Imperial)))})
                        Button("Add Dual Plates", action: {addWeightSet(.plates(PlateWeights(dual: true, plates: [], units: .Imperial)))})
                        Button("Add Single Plates", action: {addWeightSet(.plates(PlateWeights(dual: false, plates: [], units: .Imperial)))})
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            Spacer()
            Text("Discrete weights are for dumbbells, cable machines, etc. Dual Plates are plates that are added in pairs, as in a barbell squat. Single plates are plates that are added one at a time, as in a T-bar row machine.")
                .font(.footnote)
                .padding(.leading, 20)
                .padding(.trailing, 20)
        }
        .navigationTitle("Edit Weight Sets")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func tag(_ name: String) -> Int {
        if let ws = model.weightSets[name] {
            switch ws {
            case .discrete(_): return 0
            case .plates(let d): return d.dual ? 1 : 2
            }
        } else {
            return -1
        }
    }
    
    private func description(_ name: String) -> String {
        if let ws = model.weightSets[name] {
            return ws.description()
        } else {
            return "No weight set?"
        }
    }
    
    private func addWeightSet(_ ws: WeightSet) {
        let name = findName(hasName)
        self.model.addWeightSet(name, ws)
    }
    
    // TODO need to confirm this, mention if any exercises are using it
    private func deleteWeightSets(offsets: IndexSet) {
        let keys = model.weightSets.keys.sorted()
        let names = offsets.map {keys[$0]}
        withAnimation {
            self.model.deleteWeightSets(names)
        }
    }
    
    private func hasName(_ name: String) -> Bool {
        return model.weightSets[name] != nil
    }
}

#Preview {
    let model = previewModel()
    NavigationView {
        EditWeightSets(model: model)
    }
}
