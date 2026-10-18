import SwiftUI

struct ApparatusView: View {
    @Bindable var wizard: Wizard
    @State private var showBarbellHelp = false
    @State private var showFullDumbbellsHelp = false
    @State private var showPartialDumbbellsHelp = false
    @State private var showMachineHelp = false
    @State private var showSmithHelp = false
    @State private var showMetricHelp = false
    
    var body: some View {
        VStack {
            // Barbells
            HStack {
                Toggle("Barbells", isOn: $wizard.barbells)
                    .padding()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showBarbellHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showBarbellHelp {
                Text("If this is on then programs may assume you also have access to a bench, a squat rack, and a place to deadlift. Though you can change that up in the Exercises screen of the wizard.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }
            
            // Full Dumbbells
            HStack {
                Toggle("Full Dumbbells", isOn: fullDumbbellsBinding)
                    .padding()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showFullDumbbellsHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showFullDumbbellsHelp {
                Text("Enable this if you have a good selection of dumbbells, e.g. if you're using a commercial gym or have a good set of adjustable dumbbells.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }
            
            // Partial Dumbbells
            HStack {
                Toggle("Partial Dumbbells", isOn: partialDumbbellsBinding)
                    .padding()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showPartialDumbbellsHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showPartialDumbbellsHelp {
                Text("Enable this if you have a limited number of dumbbells.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }

            // Machines
            HStack {
                Toggle("Machines", isOn: $wizard.machines)
                    .padding()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showMachineHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showMachineHelp {
                Text("Enable if you have access to things like cable machines and leg press machines.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }

            // Smith Machine
            HStack {
                Toggle("Smith Machine", isOn: $wizard.smith)
                    .padding()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showSmithHelp.toggle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            if showSmithHelp {
                Text("Note that most programs will prefer to use barbells or dumbbells if those are available.")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }
            
            // Metric units
            // This is a bit annoying: weight sets are part of models not programs so that users can
            // play around with different programs without having to tweak their weight sets for what
            // ever their gym is using. But this does break down a bit if they want to create a different
            // program for home (or another gym) AND they want to use different units. But that should
            // be rare...
            if wizard.model.units == nil {
                HStack {
                    Toggle("Metric Units", isOn: metricBinding)
                        .padding()
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showMetricHelp.toggle()
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 5)
                .padding(.leading, 5)
                .padding(.trailing, 5)
                if showMetricHelp {
                    Text("Use kilograms and meters if Metric is enabled and pounds and feet otherwise.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                }
            }

            Spacer()
            Text("Toggle on the equipment that you have available and that you want to use. For example, if you have access to a full gym but only want to use dumbbells and machines then only enable those two.")
                .font(.footnote)
                .padding(.leading, 20)
                .padding(.trailing, 20)
        }
    }
    
    private var fullDumbbellsBinding: Binding<Bool> {
        Binding(
            get: {return wizard.fullDumbbells},
            set: {
                if $0 {
                    wizard.fullDumbbells = true
                    wizard.partialDumbbells = false
                } else {
                    wizard.fullDumbbells = false
                }
            }
        )
    }

    private var partialDumbbellsBinding: Binding<Bool> {
        Binding(
            get: {return wizard.partialDumbbells},
            set: {
                if $0 {
                    wizard.fullDumbbells = false
                    wizard.partialDumbbells = true
                } else {
                    wizard.partialDumbbells = false
                }
            }
        )
    }

    private var metricBinding: Binding<Bool> {
        Binding(
            get: {
                if case .Metric = wizard.units {true} else {false}
            },
            set: {
                if $0 {
                    wizard.units = .Metric
                } else {
                    wizard.units = .Imperial
                }
            }
        )
    }
}

#Preview {
    let model = previewModel()
    let wizard = Wizard(model)
    NavigationView {
        ApparatusView(wizard: wizard)
    }
}
