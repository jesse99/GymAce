import SwiftUI

/// Used for the due column in ContentView (i.e. the program view).
struct WorkoutEntry: Identifiable {
    let workout: Workout
    let label: String
    let color: Color
    let id = UUID()
    
    init(_ workout: Workout, delta: Int, today: Date) {
        self.workout = workout
        
        let calendar = Calendar.current
        let daysInWeek = calendar.weekdaySymbols.count
        if delta == 0 {
            self.label = "Today"
            self.color = .orange
        } else if delta == 1 {
            self.label = "Tomorrow"
            self.color = .blue
        } else if delta < daysInWeek {
            if let date = calendar.date(byAdding: .day, value: delta, to: today) {
                let day: Int = calendar.component(.weekday, from: date)
                self.label = calendar.weekdaySymbols[day - 1]
                self.color = .black
            } else {
                self.label = "?"
                self.color = .black
            }
        } else {
            self.label = "In \(delta) days"
            self.color = .black
        }
    }
}

extension Program {
    /// Return all the workouts that are scheduled to happen on the specified date.
    func findWorkouts(on: Date, today: Date = Date.now) -> [WorkoutEntry] {
        var candidates:[Workout] = []

        let calendar = Calendar.current
        for workout in self.workouts {
            switch workout.schedule {
            case .anyDay:
                // We only schedule anyDay workouts for the current day to avoid clutter.
                if calendar.isDate(on, inSameDayAs: today) {
                    candidates.append(workout)
                }
            case .every(1): // like anyDay
                if calendar.isDate(on, inSameDayAs: today) {
                    candidates.append(workout)
                }
            case .every(_):
                let days = calendar.dateComponents([.day], from: on, to: today).day
                if days == 0 {  // TODO need to use something like workout.days_since_last_completed
                    candidates.append(workout)
                }
            case .days(let days):
                let day: Int = calendar.component(.weekday, from: on)
                if days.includes(day) {
                    candidates.append(workout)
                }
            }
        }
        
        let entries: [WorkoutEntry] = if let delta = calendar.dateComponents([.day], from: today, to: on).day {
            candidates.map { WorkoutEntry($0, delta: delta, today: today) }
        } else {
            []
        }

        return entries
    }
}
