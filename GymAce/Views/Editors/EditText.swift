import SwiftUI

/// Edits arbitrary multi-line text.
struct EditText: View {
    var title: String
    var help: String? = nil
    @State var text: String
    var onSave: (String) -> Void
    @Environment(\.dismiss) var dismiss

    // It might be better to use an alert for stuff like this, but alerts are not allowed to have multi-line text.
    // It's possible to create a custom view that looks kind of like an alert but that's a bit janky and is smaller
    // than a full blown view which is annoying here.
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .textInputAutocapitalization(.sentences)
            
            if let s = help {
                Text(s)
                    .font(.footnote)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            }
            
            HStack(spacing: 15) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 20)
                
                Button("Save") {
                    onSave(text)
                    dismiss()
                }
                .bold()
                .frame(maxWidth: .infinity)
            }
            .frame(height: 44)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)        // we'll use the buttons to dismiss this
    }
}

#Preview {
    let text = "The quick brown fox jumped over the lazy dog.\nAnd landed in a puddle."
    let help = "For children 12 and below."
    let onSave: (String) -> Void = {s in print(s)}
    NavigationView {
        EditText(title: "Edit Rhyme", help: help, text: text, onSave: onSave)
    }
}
