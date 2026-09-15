import SwiftUI

struct EditDurations: View {
    var model: Model
    var program: Program

    @State private var name = ""
    @State private var showNameHelp = false
    @State private var showSecsHelp = false
    @State private var showTargetHelp = false

    @State private var nameErr: String? = nil
    @State private var secsErr: String? = nil
    @State private var targetErr: String? = nil
    private let badNames: [String]

    init(model: Model, program: Program, name: String) {
        self.model = model
        self.program = program
        self.name = name
        self.badNames = program.styles.filter {$0.key != name}.map {$0.key}
        _name = State(initialValue: name)
    }
    
    var body: some View {
        VStack {
            Form {
                // Name
                HStack {
                    nameTextField("Name", nameBinding)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showNameHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showNameHelp {
                    Text("Edit Exercise uses this to pick a style for the exercise.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = nameErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                // Durations
                HStack {
                    durationsTextField("Durations", durationsBinding)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showSecsHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showSecsHelp {
                    Text("Space separated list of times. An s suffix can be used for seconds, m for minutes, and h for hours. Seconds are assumed if there is no suffix.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = secsErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                // Target
                HStack {
                    durationsTextField("Target", targetBinding)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showTargetHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showTargetHelp {
                    Text("Optional goal time. This can be used as a trigger to switch to a more advanced form of the exercise, e.g. planks to feet elevated planks.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = targetErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            Spacer()
            Text(Style.durations(findInfo()).description())
                .padding(.leading, 10)
        }
        .navigationTitle("Edit Durations")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!isValid)
    }

    private var nameBinding: Binding<String> {
        Binding(
            get: {
                return name
            },
            set: {
                if $0.isBlankOrEmpty {
                    nameErr = "The name cannot be empty."
                } else if badNames.contains($0) {
                    nameErr = "Another style is already using that name."
                } else {
                    let oldName = name
                    name = $0
                    program.setStyleName(oldName: oldName, newName: $0)
                    nameErr = nil
                }
            }
        )
    }
    
    private var durationsBinding: Binding<String> {
        Binding(
            get: {
                let info = findInfo()
                return info.secs.map {secsToShortStr($0)}.joined(separator: " ")
            },
            set: {
                var a: [Int] = []
                for s in $0.split(separator: " ") {
                    if let r = parseShortSecs(String(s)) {
                        a.append(r)
                    } else {
                        secsErr = "Expected a number followed by optional s, m, or h suffixes, not '\(s)'."
                        return
                    }
                }
                var info = findInfo()
                info.secs = a
                program.styles[name] = .durations(info)
                secsErr = nil
            }
        )
    }
    
    private var targetBinding: Binding<String> {
        Binding(
            get: {
                let info = findInfo()
                if let s = info.targetSecs {
                    return "\(s)"
                } else {
                    return ""
                }
            },
            set: {
                if $0.isBlankOrEmpty {
                    var info = findInfo()
                    info.targetSecs = nil
                    program.styles[name] = .durations(info)
                    targetErr = nil
                } else if let r = parseShortSecs($0) {
                    var info = findInfo()
                    info.targetSecs = r
                    program.styles[name] = .durations(info)
                    targetErr = nil
                } else {
                    targetErr = "Expected a number followed by optional s, m, or h suffixes, not '\($0)'."
                    return
                }
            }
        )
    }

    private func findInfo() -> DurationsInfo {
        let style = program.findStyle(name)
        if case .durations(let info) = style {
            return info
        }
        fatalError("Expected \(name) to be a durations style")
    }
    
    private var isValid: Bool {
        return nameErr == nil && secsErr == nil && targetErr == nil
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    NavigationView {
        EditDurations(model: model, program: program, name: "Stretch")
    }
}
