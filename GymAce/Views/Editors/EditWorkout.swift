import SwiftUI
import SwiftData

/// Used for both editing and adding new workouts.
struct EditWorkout: View {
    var editing: Bool
    @Bindable var program: Program
    @Bindable var workout: Workout
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var isShowingInfo = false

    var body: some View {
        Form {
            HStack {
                TextField("Name", text: $workout.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                Spacer()
                Button("", systemImage: "info.circle") {
                    isShowingInfo.toggle()
                }
                .sheet(isPresented: $isShowingInfo) {
                    InfoView(text: "The name shown in the Program view.")
                        .presentationDetents([.height(80)])
                        .presentationDragIndicator(.visible)
                }
            }
        }
        .navigationTitle(editing ? "Edit Workout" : "Add Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !editing {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        program.deleteWorkout(workout) // TODO make sure that this works
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        EditWorkout(editing: true, program: PreviewData.shared.defaultProgram, workout: PreviewData.shared.defaultProgram.workouts.first!)
    }
}

#Preview("Add New") {
    NavigationView {
        EditWorkout(editing: false, program: PreviewData.shared.defaultProgram, workout: PreviewData.shared.defaultProgram.workouts.first!)
    }
}
