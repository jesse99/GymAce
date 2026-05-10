import SwiftUI

// TODO might want some canned programs here (instead of a wizard)
// TODO possibly add a way to filter shown programs based on stuff like equipment, days/week, etc
struct EditPrograms: View {
    @Bindable var model: Model
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Programs")) {
                    ForEach($model.programs) { $program in
                        Text(program.name)
                            .foregroundColor(labelColor(program))
                            .onTapGesture {
                                // TODO really should save after edits
                                // not totally sure how to do that in general
                                // maybe maintain an editCount and use something like a timer
                                // to save if it's changed? or onAppear in ProgramView?
                                model.activeProgram = program.name
                            }
                    }
                    .onDelete(perform: deletePrograms)
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addProgram) {
                        Label("Add Program", systemImage: "plus")
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("Edit Programs")
        .navigationBarTitleDisplayMode(.inline)
        
        // TODO show description for the selected program (if not empty)
    }
    
    private func labelColor(_ program: Program) -> Color {
        if program.name == model.activeProgram {
            return .blue
        }
        return .black
    }
    
    private func addProgram() {
        let name = findName()
        let program = Program(name)
        self.model.addProgram(program)
    }
    
    // TODO need to confirm this (maybe in EditProgram too)
    private func deletePrograms(offsets: IndexSet) {
        withAnimation {
            self.model.deletePrograms(offsets)
        }
    }
    
    // TODO do this when adding workouts too
    private func findName() -> String {
        var candidate = "Untitled"
        var n = 2
        while hasName(candidate) {
            candidate = "Untitled \(n)"
            n += 1
        }
        return candidate
    }

    private func hasName(_ name: String) -> Bool {
        return model.programs.contains(where: { $0.name == name })
    }
}

#Preview {
    let model = previewModel()
    NavigationView {
        EditPrograms(model: model)
    }
}
