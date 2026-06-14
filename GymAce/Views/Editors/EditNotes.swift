import SwiftUI

struct EditNotes: View {
    @Bindable var model: Model
    @Bindable var program: Program
    @State private var editName = ""
    @State private var showAlert = false
    private let help1 = "For styling use **bold**, *italic*, or [text](url). Setting to empty will restore the default text."
    private let help2 = "For styling use **bold**, *italic*, or [text](url). Setting to empty will delete this note."

    var body: some View {
        VStack {
            List {
                Section(header: Text("Notes")) {
                    ForEach(findNames(), id: \.0) {(name, nonDefault) in
                        NavigationLink {
                            EditText(title: "Edit \(name)", help: nonDefault ? help2 : help1, text: currentText(name), onSave: {text in onNewText(name, text)})
                        } label: {
                            if nonDefault {
                                Text(name)
                                    .bold()
                            } else {
                                Text(name)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showAlert = true
                        editName = ""
                    }) {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
            Spacer()
        }
        .alert("New Name", isPresented: $showAlert) {
            // Text fields placed inside the actions closure render natively inside the alert dialog
            TextField("Name", text: $editName)
                .textInputAutocapitalization(.words)
            Button("Save", action: {onNewNote()})
                .disabled(!isNameValid())
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle("Edit Notes")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func currentText(_ name: String) -> String {
        return model.notes.custom[name] ?? model.notes.defaults[name] ?? ""
    }
    
    private func onNewText(_ name: String, _ text: String) {
        if text.isBlankOrEmpty || text == model.notes.defaults[name] {
            model.notes.custom[name] = nil
        } else {
            model.notes.custom[name] = text
        }
        model.dirty = true
    }
    
    private func findNames() -> [(String, Bool)] {
        var names = model.notes.defaults.keys.map {($0, false)}
        
        for name in model.notes.custom.keys {
            if model.notes.defaults[name] == nil {
                names.append((name, true))
            }
        }
        
        return names.sorted {$0.0 < $1.0}
    }
    
    private func nameExists(_ name: String) -> Bool {
        return model.notes.defaults[name] != nil || model.notes.custom[name] != nil
    }

    private func isNameValid() -> Bool {
        return !editName.isBlankOrEmpty && !nameExists(editName)
    }
    
    private func onNewNote() {
        model.notes.custom[editName] = ""
        model.dirty = true
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    NavigationView {
        EditNotes(model: model, program: program)
    }
}
