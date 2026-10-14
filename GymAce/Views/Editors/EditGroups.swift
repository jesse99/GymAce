import SwiftUI

struct EditGroups: View {
    @Bindable var model: Model
    @Bindable var program: Program
    @State var selected: String? = nil
    @State private var showAlert = false
    @State private var editName = ""

    var body: some View {
        VStack {
            List {
                Section(header: Text("Groups")) {
                    ForEach(program.groups.keys.sorted() {$0 < $1}, id: \.self) {name in
                        Text(name)
                            .foregroundColor(.black)
                            .onTapGesture {
                                selected = name
                            }
                    }
                    .onDelete(perform: deleteGroups)
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
                    Button(action: {
                        showAlert = true
                        editName = ""
                    }) {
                        Label("Add Group", systemImage: "plus")
                    }
                }
            }
            Spacer()
            
            if let s = selected {
                Text(selectedText(s))
                    .font(.footnote)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
            } else {
                Text("Groups are used by Create Program to allow users to swap in a different version of an exercise and by bodyweight exercises to allow progression to a harder version of the eercise.")
                    .font(.footnote)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
            }
        }
        .alert("New Name", isPresented: $showAlert) {
            // Text fields placed inside the actions closure render natively inside the alert dialog
            TextField("Name", text: $editName)
                .textInputAutocapitalization(.words)
            Button("Save", action: {onNewGroup()})
                .disabled(!isNameValid())
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle("Edit Groups")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func selectedText(_ name: String) -> String {
        var names: [String] = []

        for e in program.exercises {
            if e.group == name {
                names.append(e.name)
            }
        }
        
        if !names.isEmpty {
            let s = names.sorted().joined(separator: ", ")
            return "Used by \(s)."
        } else {
            return "Not used by any exercises."
        }
    }
        
    private func nameExists(_ name: String) -> Bool {
        return program.groups[name] != nil
    }

    private func isNameValid() -> Bool {
        return !editName.isBlankOrEmpty && !nameExists(editName) && editName != "None"
    }
    
    private func onNewGroup() {
        program.groups[editName] = []
    }
    
    private func deleteGroups(offsets: IndexSet) {
        let keys = program.groups.keys.sorted() {$0 < $1}
        let names = offsets.map {keys[$0]}
        withAnimation {
            for name in names {
                program.groups[name] = nil
                
                for e in program.exercises {
                    if e.group == name {
                        e.group = nil
                    }
                }
                
                if selected == name {
                    selected = nil
                }
            }
        }
    }
    
    private func hasName(_ name: String) -> Bool {
        return program.groups[name] != nil
    }
}

#Preview {
    let model = previewModel()
    let program = model.active()!
    NavigationView {
        EditGroups(model: model, program: program)
    }
}
