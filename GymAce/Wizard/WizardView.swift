import SwiftUI

let numStages = Wizard.Stage.allCases.max()!.rawValue

struct WizardView: View {
    @Bindable var wizard: Wizard
    @State var stage: Wizard.Stage = .apparatus
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            switch stage {
            case .apparatus: ApparatusView(wizard: wizard)
            case .goal: GoalView(wizard: wizard)
            case .schedule: ScheduleView(wizard: wizard)
            case .mappings: MappingsView(wizard: wizard)
            }
            Spacer()
            HStack {
                Button("Previous", action: previousStage)
                    .buttonStyle(.borderedProminent)
                    .disabled(stage.rawValue == 1)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                Button("Cancel", role: .cancel) {dismiss()}
                    .buttonStyle(.borderedProminent)
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                Spacer()
                Button(nextTitle(), action: nextStage)
                    .buttonStyle(.borderedProminent)
                    .padding(.trailing, 20)
                    .padding(.top, 20)
            }
        }
        .navigationTitle("Program Wizard \(stage.rawValue) of \(numStages)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func previousStage() {
        switch stage {
        case .apparatus: fatalError("should be disabled")
        case .goal: stage = .apparatus
        case .schedule: stage = .goal
        case .mappings: stage = .schedule
        }
    }

    private func nextStage() {
        switch stage {
        case .apparatus: stage = .goal
        case .goal: stage = .schedule
        case .schedule: stage = .mappings
        case .mappings: addProgram()
        }
    }
    
    private func nextTitle() -> String {
        if stage.rawValue == numStages {
            "Finish"
        } else {
            "Next"
        }
    }
    
    private func addProgram() {
        let builder = wizard.build()
        wizard.generate(builder)
        dismiss()
    }
}

#Preview {
    let model = previewModel()
    let wizard = Wizard(model)
    NavigationView {
        WizardView(wizard: wizard)
    }
}
