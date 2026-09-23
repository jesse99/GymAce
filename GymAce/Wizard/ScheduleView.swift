import SwiftUI

struct ScheduleView: View {
    @Bindable var wizard: Wizard
    @State private var builder: Builder
    @State private var showScheduleHelp = false
    let scheduleNames: [String]
    
    init(wizard: Wizard) {
        self.wizard = wizard
        
        let builder = wizard.build()
        _builder = State(initialValue: builder)
        scheduleNames = builder.schedules.map {$0.toString()}
    }
    
    var body: some View {
        VStack {
            // Schedule picker
            HStack {
                Picker("", selection: scheduleBinding) {
                    ForEach(Array(scheduleNames.enumerated()), id: \.element) {tuple in
                        Text(tuple.1).tag(tuple.0)
                    }
                }
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showScheduleHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showScheduleHelp {
                let s = switch wizard.schedule {
                case .weekly: "Workouts are scheduled on specific week days."
                case .cycle: "Workouts are done one after another and then repeated. Typically this includes explicit rest day workouts."
                case .block: "Workouts are arranged into weekly blocks, e.g. an intermediate program might start with low weights but high volume and then ramp up to high weights with low volume."
                }
                Text(s)
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }
            
            Spacer()
            Text("Select how you want to schedule your workouts. Note that you can change this later by using Edit Program.")
                .font(.footnote)
                .padding(.leading, 20)
                .padding(.trailing, 20)
        }
        .onAppear {
            let schedules = builder.schedules
            if !schedules.contains(wizard.schedule) && !schedules.isEmpty {
                wizard.schedule = schedules[0]
            }
        }
    }
    
    private var scheduleBinding: Binding<Int> {
        Binding(
            get: {
                let name = wizard.schedule.toString()
                return builder.schedules.firstIndex(where: {$0.toString() == name}) ?? 0
            },
            set: {
                let name = scheduleNames[$0]
                let schedules = builder.schedules
                let index = schedules.firstIndex(where: {$0.toString() == name}) ?? 0
                wizard.schedule = schedules[index]
            }
        )
    }
}

#Preview {
    let model = previewModel()
    let wizard = Wizard(model)
    NavigationView {
        ScheduleView(wizard: wizard)
    }
}
