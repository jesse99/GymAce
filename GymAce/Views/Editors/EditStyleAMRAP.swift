import SwiftUI

struct EditAMRAP: View {
    var model: Model
    var program: Program
    var name: String

    @State private var showWarmupHelp = false
    @State private var showWorksetHelp = false
    @State private var showBackoffHelp = false
    @State private var showRestHelp = false

    @State private var warmupErr: String? = nil
    @State private var worksetErr: String? = nil
    @State private var backoffErr: String? = nil
    @State private var restErr: String? = nil
    
    init(model: Model, program: Program, name: String) {
        self.model = model
        self.program = program
        self.name = name
    }
    
    var body: some View {
        VStack {
            Form {
                // Warmup
                HStack {
                    repsTextField("Warmups", warmupBinding)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showWarmupHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showWarmupHelp {
                    Text("Sets to do before the work sets. Formated as 5/80, i.e. 5 reps at 80% of the base weight.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = warmupErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                // Workset
                HStack {
                    repsTextField("Worksets", worksetBinding)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showWorksetHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showWorksetHelp {
                    Text("Sets to do after warming up. Formatted as \"5 5\" for two sets of five reps or \"5/80 3/90\" for two sets at an increasing percentage of the exercise's base weight.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = worksetErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                // Backoff
                HStack {
                    repsTextField("Backoff", backoffBinding)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showBackoffHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showBackoffHelp {
                    Text("Sets to do after the work sets. Formated as 5/80, i.e. 5 reps at 80% of the base weight.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = backoffErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                // Rest
                HStack {
                    durationsTextField("Rest", restBinding)
                    Spacer()
                    Button("", systemImage: "info.circle") {
                        showRestHelp.toggle()
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                }
                if showRestHelp {
                    Text("The amount of time to do rest after each work set. Suffixes can be used, s for seconds, m for minutes, and h for hours. Seconds are assumed if there is no suffix.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                if let e = restErr {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            Spacer()
            Text("AMRAP: " + Style.amrap(findInfo()).description())
                .padding(.leading, 10)
        }
        .navigationTitle("Edit \(name)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!isValid)
    }

    private var warmupBinding: Binding<String> {
        Binding(
            get: {
                let info = findInfo()
                return info.warmup.map {$0.asString()}.joined(separator: " ")
            },
            set: {
                var a: [OtherReps] = []
                for s in $0.split(separator: " ") {
                    if let r = OtherReps(String(s)) {
                        a.append(r)
                    } else {
                        warmupErr = "Expected a number for reps and a percent, e.g. 5/80, not '\(s)'."
                        return
                    }
                }
                var info = findInfo()
                info.warmup = a
                program.styles[name] = .amrap(info)
                warmupErr = nil
            }
        )
    }
    
    private var worksetBinding: Binding<String> {
        Binding(
            get: {
                let info = findInfo()
                return info.workset.map {$0.asString()}.joined(separator: " ")
            },
            set: {
                var a: [PercentReps] = []
                for s in $0.split(separator: " ") {
                    if let r = PercentReps(String(s)) {
                        a.append(r)
                    } else {
                        worksetErr = "Expected a number for reps with an optional percent, e.g. 5 or 5/80, not '\(s)'."
                        return
                    }
                }
                var info = findInfo()
                info.workset = a
                program.styles[name] = .amrap(info)
                worksetErr = nil
            }
        )
    }

    private var backoffBinding: Binding<String> {
        Binding(
            get: {
                let info = findInfo()
                return info.backoff.map {$0.asString()}.joined(separator: " ")
            },
            set: {
                var a: [OtherReps] = []
                for s in $0.split(separator: " ") {
                    if let r = OtherReps(String(s)) {
                        a.append(r)
                    } else {
                        warmupErr = "Expected a number for reps and a percent, e.g. 5/80, not '\(s)'."
                        return
                    }
                }
                var info = findInfo()
                info.backoff = a
                program.styles[name] = .amrap(info)
                warmupErr = nil
            }
        )
    }

    private var restBinding: Binding<String> {
        Binding(
            get: {
                let info = findInfo()
                if let r = info.rest {
                    return secsToShortStr(r)
                } else {
                    return ""
                }
            },
            set: {
                if let s = parseShortSecs($0) {
                    restErr = nil
                    var info = findInfo()
                    info.rest = s
                    program.styles[name] = .amrap(info)
                } else if $0.isBlankOrEmpty {
                    restErr = nil
                    var info = findInfo()
                    info.rest = nil
                    program.styles[name] = .amrap(info)
                } else {
                    restErr = "Expected nothing or a number with an optional time suffix, not '\($0)'."
                }
            }
        )
    }

    private func findInfo() -> AMRAPInfo {
        let style = program.findStyle(name)
        if case .amrap(let info) = style {
            return info
        }
        fatalError("Expected \(name) to be amrap style")
    }
    
    private var isValid: Bool {
        return warmupErr == nil && worksetErr == nil && backoffErr == nil && restErr == nil
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    NavigationView {
        EditAMRAP(model: model, program: program, name: "AMRAP")
    }
}
