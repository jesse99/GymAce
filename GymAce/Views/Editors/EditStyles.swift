import SwiftUI

struct EditStyles: View {
    @Bindable var model: Model
    @Bindable var program: Program
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Styles")) {
                    ForEach(program.styles.sorted(by: {$0.key < $1.key}), id: \.key) {key, value in
                        NavigationLink {
                            switch value {
                                case .basic:
                                    EditBasic(model: model, program: program, name: key)
                                case .amrap:
                                    EditAMRAP(model: model, program: program, name: key)
                                case .durations:
                                    Text("TODO durations")
                                case .oneRepMax:
                                    Text("TODO oneRepMax")
                                case .timed:
                                    Text("TOD timed")
                                case .variable:
                                    Text("TODO variable")
                                case .missing:
                                    Text("TODO missing")
                            }
                        } label: {
                            Text(key)
                        }
                    }
                    .onDelete(perform: deleteStyles)
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
                        Button("Add Basic", action: addBasic)
                        Button("Add AMRAP", action: addAMRAP)
                        Button("Add Durations", action: addDurations)
                        Button("Add One Rep Max", action: addOneRepMax)
                        Button("Add Timed", action: addTimed)
                        Button("Add Variable", action: addVariable)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("Edit Styles")
        .navigationBarTitleDisplayMode(.inline)
    }
        
    private func addBasic() {
        let name = findName(hasName, prefix: "Basic")
        self.program.styles[name] = Style.basic(BasicInfo(warmup: "5/60 3/80 1/90", workset: "5 5 5", rest: "2.5m")!)
    }
    
    private func addAMRAP() {
        let name = findName(hasName, prefix: "AMRAP")
        self.program.styles[name] = Style.amrap(AMRAPInfo(warmup: "5/60 3/80 1/90", workset: "5 5 5", rest: "2.5m")!)
    }
    
    private func addDurations() {
        let name = findName(hasName, prefix: "Durations")
        self.program.styles[name] = Style.durations(DurationsInfo(secs: "30s 30s 30s", targetSecs: "")!)
    }
    
    private func addOneRepMax() {
        let name = findName(hasName, prefix: "One Rep Max")
        self.program.styles[name] = Style.oneRepMax(OneRepMaxInfo(warmup: "5/60 3/80 1/90", workset: 3, rest: "3m")!)
    }
    
    private func addTimed() {
        let name = findName(hasName, prefix: "Timed")
        self.program.styles[name] = Style.timed
    }
    
    private func addVariable() {
        let name = findName(hasName, prefix: "Variable")
        self.program.styles[name] = Style.variable(VariableInfo(warmup: "5/60 3/80 1/90", workset: "8-12 8-12 8-12", rest: "2.5m")!)
    }
    
    // TODO need to confirm this
    private func deleteStyles(offsets: IndexSet) {
        let styles = program.styles.sorted(by: {$0.key < $1.key})
        let names = offsets.map {styles[$0].0}
        withAnimation {
            for name in names {
                self.program.styles[name] = nil
            }
        }
    }
    
    private func hasName(_ name: String) -> Bool {
        return program.styles[name] != nil
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    NavigationView {
        EditStyles(model: model, program: program)
    }
}
