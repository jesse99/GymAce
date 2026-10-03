import SwiftUI

struct GroupView: View {
    @Bindable var wizard: Wizard
    @State private var showScheduleHelp = false
    
    var body: some View {
        VStack {
            if !wizard.groups.isEmpty {
                Grid(horizontalSpacing: 20, verticalSpacing: 10) {
                    ForEach(wizard.groups.keys.sorted(), id: \.self) {groupName in
                        if let group = wizard.groups[groupName], !group.active.isEmpty {
                            GridRow {
                                Text(groupName)
                                    .gridColumnAlignment(.leading)
                                Picker("", selection: binding(for: groupName)) {
                                    ForEach(Array(group.exercises).enumerated(), id: \.element) {tuple in
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
            } else {
                Text("This program has no exercise groups.")
            }
            
            Spacer()
            Text("You can select alternatives for the defaults for many exercises here. Usually the default is a good choice but if you have an injury or a personal preference you may want to swap in a different exercise. Note that you can also do this later via Edit Program.")
                .font(.footnote)
                .padding(.leading, 20)
                .padding(.trailing, 20)
        }
        .onAppear {
            let builder = wizard.build()
            let program = wizard.make(builder)
            updateGroups(program, wizard)
        }
    }
    
    private func binding(for groupName: String) -> Binding<Int> {
        Binding(
            get: {
                if let group = wizard.groups[groupName] {
                    if let i = group.exercises.firstIndex(where: {$0 == group.active}) {
                        return i
                    }
                }
                assert(false)
                return 0
            },
            set: {
                if let group = wizard.groups[groupName] {
                    group.active = group.exercises[$0]
                    wizard.groups[groupName] = group
                }
            }
        )
    }
}

func updateGroups(_ program: Program, _ wizard: Wizard) {
    var groups: [String: Wizard.Group] = [:]
    
    // Build new groups
    for w in program.workouts {
        for e in w.entries {
            if let groupName = e.group {
                let g = groups[groupName, default: Wizard.Group()]
                if !g.exercises.contains(e.name) {
                    g.exercises.append(e.name)
                    groups[groupName] = g
                }
                if e.enabled {
                    g.active = e.name
                    groups[groupName] = g
                }
            }
        }
    }
                    
    // If the group is in the wizard but not the current program then it'll be dropped
    // when we overwrite the wizard. Ditto if the group is in the current program but
    // not the wizard. But if the group is in both we need to preserve the old state
    // where possible.
    let wizardNames = Set(wizard.groups.keys)
    let programNames = Set(groups.keys)
    let commonNames = programNames.intersection(wizardNames)
    for groupName in commonNames {
        if let oldGroup = wizard.groups[groupName], let newGroup = groups[groupName] {
            if oldGroup.exercises == newGroup.exercises {
                if newGroup.exercises.contains(where: {$0 == oldGroup.active}) {
                    newGroup.active = oldGroup.active
                    groups[groupName] = newGroup
                }
            }
        }
    }
    
    wizard.groups = groups
}

#Preview {
    let model = previewModel()
    let wizard = Wizard(model)
    NavigationView {
        GroupView(wizard: wizard)
    }
}
