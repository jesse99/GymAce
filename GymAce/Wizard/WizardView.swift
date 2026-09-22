import SwiftUI

let numStages = Wizard.Stage.allCases.max()!.rawValue

struct WizardView: View {
    @Bindable var wizard: Wizard
    @State var stage: Wizard.Stage = .apparatus
    
    var body: some View {
        VStack {
            switch stage {
            case .apparatus: ApparatusView(wizard: wizard)
            case .goals: Text("goals")
            case .fitness: Text("fitness")
            case .schedule: Text("schedule")
            case .exercises: Text("exercises")
            }
            Spacer()
        }
        .navigationTitle("Program Wizard \(stage.rawValue) of \(numStages)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let model = previewModel()
    let wizard = Wizard(model)
    NavigationView {
        WizardView(wizard: wizard)
    }
}
