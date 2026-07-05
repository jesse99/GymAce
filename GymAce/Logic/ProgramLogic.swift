import SwiftUI

/// Used for the due column in ContentView (i.e. the program view).
struct WorkoutEntry: Identifiable {
    let workout: Workout
    let label: String
    let color: Color
    let id = UUID()
    
    init(_ workout: Workout, delta: Int, today: Date) {
        self.workout = workout
        self.label = today.daysStr(delta)
        if delta == 0 {
            self.color = .orange
        } else if delta == 1 {
            self.color = .blue
        } else {
            self.color = .black
        }
    }
}

extension Program {
    /// Returns the workouts that are scheduled for today, tomorrow, etc. Note that this can return empty
    /// lists if no workouts are scheduled for a day.
    func findScheduledWorkouts(today: Date = Date.now) -> [[WorkoutEntry]] {
        let N = 30
        var entries: [[WorkoutEntry]] = Array(repeating: [], count: N)

        // TODO this gets a little weird when starting out, e.g. if workouts are scheduled
        // for workdays AND today is Sat or Sun AND weeks are being used then we'll show
        // week 2 workouts as due next. Though this should be fixed up when Monday rolls
        // around.
        let calendar = Calendar.current
        for i in 0..<entries.count {
            if let on = calendar.date(byAdding: .day, value: i, to: today) {
                let week = currentWeek(on: on)
                for workout in self.workouts {
                    if let r = workout.weeks, let w = week, !r.contains(w) {
                        continue
                    }
                    switch workout.schedule {
                    case .anyDay:
                        // We only schedule anyDay workouts for the first available option to avoid clutter.
                        if workout.weeks != nil || calendar.isDate(on, inSameDayAs: today) {
                            let entry = WorkoutEntry(workout, delta: i, today: today)
                            entries[i].append(entry)  // show these after the others
                        }
                    case .cyclic: // we'll special case this below
                        break
                    case .days(let days):
                        let day: Int = calendar.component(.weekday, from: on)
                        if days.includes(day) {
                            let entry = WorkoutEntry(workout, delta: i, today: today)
                            entries[i].insert(entry, at: 0)
                        }
                    }
                }
            }
        }
        
        if let cyclic = findCyclicWorkouts() {
            var i = 0
            while i < entries.count {
                for workout in cyclic {
                    if let on = calendar.date(byAdding: .day, value: i, to: today) {
                        let week = currentWeek(on: on)
                        if let r = workout.weeks, let w = week, !r.contains(w) {
                            // skip this one
                        } else {
                            let entry = WorkoutEntry(workout, delta: i, today: today)
                            entries[i].insert(entry, at: 0)
                        }
                        
                        i += 1
                        if i >= entries.count {
                            break
                        }
                    }
                }
            }
        }

        return entries
    }
    
    /// Returns the cyclic workouts starting with the one that should be performed first.
    private func findCyclicWorkouts() -> [Workout]? {
        if var i = findLatestCyclic() {
            var cyclic: [Workout] = []
            for _ in 0..<workouts.count {
                if case .cyclic = workouts[i].schedule {
                    cyclic.append(workouts[i])
                }
                i = (i + 1) % workouts.count
            }
            return cyclic
        }
        
        return nil
    }
    
    private func findLatestCyclic() -> Int? {
        var latest: Int? = nil
        var latestDate: Date = Date.distantPast
        
        for (i, workout) in workouts.enumerated() {
            if case .cyclic = workout.schedule {
                if let started = workout.started {
                    if started > latestDate {
                        latest = i
                        latestDate = started
                    }
                } else if latest == nil {
                    latest = i
                }
            }
        }
        
        return latest
    }
}
