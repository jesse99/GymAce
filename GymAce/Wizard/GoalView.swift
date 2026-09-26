import SwiftUI

struct GoalView: View {
    @Bindable var wizard: Wizard
    @State private var showGoalHelp = false
    @State private var showFitnessHelp = false
    @State private var showAgeHelp = false
    @State private var showSexHelp = false
    
    var body: some View {
        VStack {
            // Goal picker
            HStack {
                Picker("", selection: goalBinding) {
                    Text("Strength").tag(0)
                    Text("Hypertrophy").tag(1)
                    Text("Glute Focused").tag(2)
                    Text("Conditioning").tag(3)
                }
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showGoalHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showGoalHelp {
                let s = switch wizard.goal {
                case .strength: "Will build a program with a focus on gaining strength."
                case .hypertrophy: "Will build a program with more of a bodybuilding emphasis."
                case .glute: "Will build a program with more of an emphasis on lower body and glute exercises."
                case .conditioning: "Will build a program with a focus on endurance."
                }
                Text(s)
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }
            
            // Fitness picker
            HStack {
                Picker("", selection: fitnessBinding) {
                    Text("Beginner").tag(0)
                    Text("Intermediate").tag(1)
                    Text("Advanced").tag(2)
                }
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showFitnessHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showFitnessHelp {
                let s = switch wizard.fitness {
                case .beginner: "Use this if you are new to lifting weights, have only been lifting for a month or two, or have been lifting without focusing on progression. Typically you'll want to jump to an intermediate program after running one of these programs for a few months."
                case .intermediate: "Use this if you have been seriously lifting for more than a few months. These programs use techniques to better manage recovery or provide better support for hypertrophy."
                case .advanced: "Use this if you've been seriously lifting for years. Similar to intermediate but even more so."
                }
                Text(s)
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }
            
            // Age picker
            HStack {
                Picker("", selection: ageBinding) {
                    Text("Under 30").tag(0)
                    Text("30 to 50").tag(1)
                    Text("51 to 70").tag(2)
                    Text("Over 70").tag(3)
                }
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showAgeHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showAgeHelp {
                Text("Some programs (especially intermediate and advanced) will make changes to ease recovery for older lifters. For example they may reduce exercise volume or add additional rest days.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }

            // Male/Female toggle
            HStack {
                Toggle("Male", isOn: $wizard.male)
                    .padding()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showSexHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showSexHelp {
                Text("Initial weights for males will be somewhat higher though, in general, most users will want to use Edit Exercise to adjust the weights.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }

            Spacer()
        }
    }
    
    private var goalBinding: Binding<Int> {
        Binding(
            get: {
                switch wizard.goal {
                case .strength: return 0
                case .hypertrophy: return 1
                case .glute: return 2
                case .conditioning: return 3
                }
            },
            set: {
                switch $0 {
                case 0: wizard.goal = .strength
                case 1: wizard.goal = .hypertrophy
                case 2: wizard.goal = .glute
                case 3: wizard.goal = .conditioning
                default: fatalError("bad goal")
                }
            }
        )
    }

    private var fitnessBinding: Binding<Int> {
        Binding(
            get: {
                switch wizard.fitness {
                case .beginner: return 0
                case .intermediate: return 1
                case .advanced: return 2
                }
            },
            set: {
                switch $0 {
                case 0: wizard.fitness = .beginner
                case 1: wizard.fitness = .intermediate
                case 2: wizard.fitness = .advanced
                default: fatalError("bad fitness")
                }
            }
        )
    }

    private var ageBinding: Binding<Int> {
        Binding(
            get: {
                if wizard.age < 30 {
                    0
                } else if wizard.age <= 50 {
                    1
                } else if wizard.age <= 70 {
                    2
                } else {
                    3
                }
            },
            set: {
                switch $0 {
                case 0: wizard.age = 20
                case 1: wizard.age = 40
                case 2: wizard.age = 60
                case 3: wizard.age = 80
                default: fatalError("bad age")
                }
            }
        )
    }
}

#Preview {
    let model = previewModel()
    let wizard = Wizard(model)
    NavigationView {
        GoalView(wizard: wizard)
    }
}
