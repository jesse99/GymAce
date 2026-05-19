import SwiftUI

/// Used for both editing and adding new workouts.
struct EditWorkout: View {
    var model: Model
    @Bindable var program: Program
    @Bindable var workout: Workout
    @State private var showNameHelp = false
    @State private var showScheduleHelp = false
    @State private var showWeeksHelp = false
    @State private var malformedWeeks: String? = nil

    @State private var anySchedule = Schedule.anyDay
    @State private var everySchedule = Schedule.anyDay
    @State private var daysSchedule = Schedule.anyDay

    init(model: Model, program: Program, workout: Workout) {
        self.model = model
        self.program = program
        self.workout = workout
        
        // Save the original schedule state so when the user switches the
        // type back to the original type they don't lose the original
        // settings.
        switch workout.schedule {
        case .anyDay:
            _everySchedule = State(initialValue: .every(2))
            _daysSchedule = State(initialValue: .days(Weekdays(days: [])))
        case .every(let n):
            _everySchedule = State(initialValue: .every(n))
            _daysSchedule = State(initialValue: .days(Weekdays(days: [])))
        case .days(let days):
            _everySchedule = State(initialValue: .every(2))
            _daysSchedule = State(initialValue: .days(days))
        }
    }
    
    private var isNameEmpty: Bool {
        self.workout.name.isEmpty
    }

    private var doesNameExist: Bool {
        self.program.workouts.count(where: {
            $0.id != self.workout.id && $0.name == self.workout.name
        }) > 0
    }

    private var isValid: Bool {
        !isNameEmpty && !doesNameExist
    }

    private func toWeekdays(_ bools: [Bool]) -> Weekdays {
        var days: [Int] = []
        for i in bools.indices {
            if bools[i] { days.append(i) }
        }
        return Weekdays(days: days)
    }
    
    private var pickerBinding: Binding<Int> {
        Binding(
            get: {
                switch workout.schedule {
                    case .anyDay: return 0
                    case .every(_): return 1
                    case .days(_): return 2
                }
            },
            set: {
                let oldSchedule = workout.schedule
                let newSchedule = $0
                switch oldSchedule {
                case .anyDay:
                    self.anySchedule = oldSchedule
                case .every(_):
                    self.everySchedule = oldSchedule
                case .days(_):
                    self.daysSchedule = oldSchedule
                }
                
                switch newSchedule {
                case 0:
                    self.workout.schedule = self.anySchedule
                case 1:
                    self.workout.schedule = self.everySchedule
                case 2:
                    self.workout.schedule = self.daysSchedule
                default:
                    fatalError("bad pickerBinding")
                }
            }
        )
    }

    private var everyNBinding: Binding<Int> {
        Binding(
            get: {
                switch workout.schedule {
                    case .anyDay: return 0
                    case .every(let n): return n
                    case .days(_): return 2
                }
            },
            set: {
                self.workout.schedule = .every($0)
            }
        )
    }
    
    // We will get a runtime error here if the locale has more than seven weekdays.
    // But it's very rare for locales to not have seven days and the few that do tend
    // to have fewer than seven days.
    private var weekdayBindings: [Binding<Bool>] {[
        Binding(
            get: {getWeekday(0)},
            set: {setWeekday(0, $0)}
        ),
        Binding(
            get: {getWeekday(1)},
            set: {setWeekday(1, $0)}
        ),
        Binding(
            get: {getWeekday(2)},
            set: {setWeekday(2, $0)}
        ),
        Binding(
            get: {getWeekday(3)},
            set: {setWeekday(3, $0)}
        ),
        Binding(
            get: {getWeekday(4)},
            set: {setWeekday(4, $0)}
        ),
        Binding(
            get: {getWeekday(5)},
            set: {setWeekday(5, $0)}
        ),
        Binding(
            get: {getWeekday(6)},
            set: {setWeekday(6, $0)}
        ),
        Binding(
            get: {getWeekday(7)},
            set: {setWeekday(7, $0)}
        )]
    }
    
    private func getWeekday(_ i: Int) -> Bool {
        switch workout.schedule {
            case .anyDay: return false
            case .every(_): return false
            case .days(let days): return days.includes(i+1) ? true : false
        }
    }
    
    private func setWeekday(_ i: Int, _ enable: Bool) {
        switch workout.schedule {
            case .anyDay: break
            case .every(_): break
            case .days(let days):
                var days = days.days
                if enable {
                    if !days.contains(i+1) {
                        days.append(i+1)
                        self.workout.schedule = .days(Weekdays(days: days))
                    }
                } else {
                    if let index = days.firstIndex(of: i+1) {
                        days.remove(at: index)
                        self.workout.schedule = .days(Weekdays(days: days))
                    }
                }
        }
    }
    
    private var weeksBinding: Binding<String> {
        Binding(
            get: {
                if let r = workout.weeks {
                    if r.lowerBound == r.upperBound {
                        return "\(r.lowerBound)"
                    } else {
                        return "\(r.lowerBound)-\(r.upperBound)"
                    }
                } else {
                    return ""
                }
            },
            set: {
                let parts = $0.split(separator: "-")
                if parts.count == 0 {
                    let s = $0.trimmingCharacters(in: .whitespaces)
                    if s.isEmpty {
                        workout.weeks = nil
                        malformedWeeks = nil
                    } else {
                        malformedWeeks = "Weeks should be formated as '1-4' or '1'."
                    }
                } else if parts.count == 1 {
                    setWeeks(String(parts[0]), String(parts[0]))
                } else if parts.count == 2 {
                    setWeeks(String(parts[0]), String(parts[1]))
                } else {
                    malformedWeeks = "Weeks should be formated as '1-4' or '1'."
                }
            }
        )
    }
    
    private func setWeeks(_ lower: String, _ upper: String) {
        guard let l = Int(lower), let u = Int(upper) else {
            malformedWeeks = "Weeks should be empty or a 1-based number or range."
            return
        }
        if l < 1 || u < 1 {
            malformedWeeks = "Weeks should be empty or a 1-based number or range."
        } else if l > u {
            malformedWeeks = "First week should be less than or equal to second week."
        } else {
            workout.weeks = l...u
            malformedWeeks = nil
        }
    }

    // TODO use onAppear to make the name textbox the focus?
    var body: some View {
        Form {
            HStack {
                TextField("Name", text: $workout.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showNameHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showNameHelp {
                Text("The name shown in the Program view.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
            if isNameEmpty {
                Text("Workout name cannot be empty.")
                    .foregroundColor(.red)
                    .font(.footnote)
            } else if doesNameExist {
                Text("There is already a workout with that name.")
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            HStack {
                TextField("Weeks, e.g. 1-4", text: weeksBinding)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)
                Spacer()
                Button("", systemImage: "info.circle") {
                    showWeeksHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showWeeksHelp {
                Text("Schedule the workout only for this inclusive range of weeks, e.g. weeks 1-7 for most workouts, and week 8 for a deload or rest week.")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
            if let m = malformedWeeks {
                Text(m)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            HStack {
                Picker("", selection: pickerBinding) {
                    Text("Any Day").tag(0)
                    Text("Every").tag(1)
                    Text("Week Days").tag(2)
                }
                .labelsHidden()
                Spacer()
                Button("", systemImage: "info.circle") {
                    showScheduleHelp.toggle()
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
            }
            if showScheduleHelp {
                switch workout.schedule {
                    case .anyDay:
                    Text("The workout can be done whenever, e.g. cardio.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                    case .every(_):
                    Text("The workout should be done every N days, e.g. 2 for every other day.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                    case .days(_):
                    Text("The workout should be done on specified days, e.g. Mon and Wed.")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
            }
            
            Group {
                switch workout.schedule {
                    case .anyDay:
                        EmptyView()
                    case .every(_):
                        HStack {
                            // I think NumberFormatter requires a number so it prevents
                            // users from deleting the last digit.
                            TextField("", value: everyNBinding, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                            Text("days")
                        }
                    case .days(_):
                        ForEach(0..<Calendar.current.weekdaySymbols.count, id: \.self) { i in
                            Toggle(Calendar.current.standaloneWeekdaySymbols[i], isOn: weekdayBindings[i])
                        }
                }
            }
        }
        .navigationTitle("Edit Workout")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!isValid)
        .onAppear {
            model.dirty = true
        }
    }
}

#Preview {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[0]
    NavigationView {
        EditWorkout(model: model, program: program, workout: workout)
    }
}

#Preview("Two") {
    let model = previewModel()
    let program = model.programs[0]
    let workout = program.workouts[1]
    NavigationView {
        EditWorkout(model: model, program: program, workout: workout)
    }
}

#Preview("Three") {
    let model = previewModel()
    let program = model.programs[9]
    let workout = program.workouts[2]
    NavigationView {
        EditWorkout(model: model, program: program, workout: workout)
    }
}
