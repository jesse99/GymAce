import SwiftUI
import SwiftData

enum ActiveSheet: Identifiable {
    case first, second
    var id: Int { hashValue }
}

/// Used for both editing and adding new workouts.
struct EditWorkout: View {
    private var editing: Bool
    @Bindable private var program: Program
    @Bindable private var workout: Workout
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var schedule = 0
    @State private var everyN = 2
    @State private var weekdays: [Bool] = []
    @State private var activeSheet: ActiveSheet? = nil
    @FocusState private var isFocused: Bool

    init(editing: Bool, program: Program, workout: Workout) {
        self.program = program
        self.workout = workout
        _schedule = State(initialValue: workout.schedule.id())
        self.editing = editing
        
        let calendar = Calendar.current
        var weekdays = calendar.weekdaySymbols.map {_ in false}
        switch workout.schedule {
        case .anyDay:
            _weekdays = State(initialValue: weekdays)
        case .every(let n):
            _everyN = State(initialValue: n)
            _weekdays = State(initialValue: weekdays)
        case .days(let days):
            for i in days.days {
                weekdays[i] = true
            }
            _weekdays = State(initialValue: weekdays)
        }
    }
    
    var body: some View {
        Form {
            HStack {
                // TODO this seems to be dismissing this view, sometimes anyway...
                // use an explicit (state) name field?
                // or maybe we should have bindings to workout name and schedule
                //    would be nice to preserve old schedule so we can restore it when switching back
                TextField("Name", text: $workout.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                Spacer()
                Button("", systemImage: "info.circle") {
                    activeSheet = .first
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }

            HStack {
                Picker("", selection: $schedule) {
                    Text("Any Day").tag(0)
                    Text("Every").tag(1)
                    Text("Week Days").tag(2)
                }
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    activeSheet = .second
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            
            Group {
                if schedule == 1 {
                    HStack {
                        TextField("", value: $everyN, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        Text("days")
                    }
                } else if schedule == 2 {
                    ForEach(0..<Calendar.current.weekdaySymbols.count, id: \.self) { i in
                        Toggle(Calendar.current.standaloneWeekdaySymbols[i], isOn: $weekdays[i])
                    }
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .first:
                InfoView(text: "The name shown in the Program view.")
                    .presentationDetents([.height(80)]) // TODO review these heights
                    .presentationDragIndicator(.visible)
            case .second:
                if schedule == 0 {
                    InfoView(text: "The workout can be done whenever, e.g. cardio.")
                        .presentationDetents([.height(80)])
                        .presentationDragIndicator(.visible)
                } else if schedule == 1 {
                    InfoView(text: "The workout should be done every N days, e.g. 2 for every other day.")
                        .presentationDetents([.height(80)])
                        .presentationDragIndicator(.visible)
                } else {
                    InfoView(text: "The workout should be done on specified days, e.g. Mon and Wed.")
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
                    // TODO do we want nested save buttons? will they work properly?
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
        // TODO
        // when editing use above to persist schedule
        // otherwise use onDisappear?
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
