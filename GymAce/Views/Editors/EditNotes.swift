import SwiftUI

fileprivate func onChangeNote(_ model: Model, _ name: String, _ text: String) {
    if text.isBlankOrEmpty || text == model.notes.defaults[name] {
        model.notes.custom[name] = nil
    } else {
        model.notes.custom[name] = text
    }
    model.dirty = true
}

@ViewBuilder
func editNote(_ model: Model, _ name: String) -> some View {
    let currentText = model.notes.custom[name] ?? model.notes.defaults[name] ?? ""
    let help = if model.notes.defaults[name] != nil {
        "For styling use **bold**, *italic*, or [text](url). Setting to empty will restore the default text."
    } else {
        "For styling use **bold**, *italic*, or [text](url). Setting to empty will delete this note."
    }
    EditText(title: "Edit \(name)", help: help, text: currentText, onSave: {text in onChangeNote(model, name, text)})
}

struct EditNotes: View {
    @Bindable var model: Model
    @Bindable var program: Program
    @State private var editName = ""
    @State private var showAlert = false

    var body: some View {
        VStack {
            List {
                Section(header: Text("Notes")) {
                    ForEach(findNames(), id: \.self) {name in
                        NavigationLink {
                            editNote(model, name)
                        } label: {
                            if model.notes.defaults[name] != nil {
                                Text(name)
                            } else {
                                Text(name)
                                    .bold()
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
    
    private func findNames() -> [String] {
        var names = Array(model.notes.defaults.keys)
        
        for name in model.notes.custom.keys {
            if model.notes.defaults[name] == nil {
                names.append(name)
            }
        }
        
        return names.sorted {$0 < $1}
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
