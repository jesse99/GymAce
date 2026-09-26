import SwiftUI

struct GroupView: View {
    @Bindable var wizard: Wizard
    @State private var builder: Builder
    @State private var program: Program
    @State private var showScheduleHelp = false
    
    init(wizard: Wizard) {
        self.wizard = wizard
        
        let builder = wizard.build()
        _builder = State(initialValue: builder)
        _program = State(initialValue: wizard.make(builder))
    }
    
    var body: some View {
        VStack {
            if let groups = program.groups {
                Grid(horizontalSpacing: 20, verticalSpacing: 10) {
                    ForEach(groups.keys.sorted(), id: \.self) {group in
                        if let exercises = groups[group], isActive(group) {
                            GridRow {
                                Text(group)
                                    .gridColumnAlignment(.leading)
                                Picker("", selection: binding(for: group)) {
                                    ForEach(Array(exercises).enumerated(), id: \.element) {tuple in
                                        Text(tuple.1).tag(tuple.0)
                                    }
                                }
                                .labelsHidden()
                                .gridColumnAlignment(.leading)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            }
                
            Spacer()
            Text("You can select alternatives for the defaults for many exercises here. Usually the default is a good choice but if you have an injury or a personal preference you may want to swap in a different exercise. Note that you can also do this later via Edit Program.")
                .font(.footnote)
                .padding(.leading, 20)
                .padding(.trailing, 20)
        }
        .onAppear {
        }
    }
    
    private func binding(for group: String) -> Binding<Int> {
        Binding(
            get: {
                if let groups = program.groups, let exercises = groups[group] {
                    for (i, e) in exercises.enumerated() {
                        if isEnabled(group, e) {
                            return i
                        }
                    }
                }
                assert(false)
                return 0
            },
            set: {
                if let groups = program.groups, let exercises = groups[group] {
                    for w in program.workouts {
                        for e in w.entries {
                            if e.group == group {
                                e.enabled = e.name == exercises[$0]
                            }
                        }
                    }
                }
            }
        )
    }
    
    private func isActive(_ group: String) -> Bool {
        for w in program.workouts {
            for e in w.entries {
                if e.group == group && e.enabled {
                    return true
                }
            }
        }
        return false
    }

    private func isEnabled(_ group: String, _ exercise: String) -> Bool {
        for w in program.workouts {
            for e in w.entries {
                if e.group == group && e.enabled && e.name == exercise {
                    return true
                }
            }
        }
        return false
    }
}

#Preview {
    let model = previewModel()
    let wizard = Wizard(model)
    NavigationView {
        GroupView(wizard: wizard)
    }
}
