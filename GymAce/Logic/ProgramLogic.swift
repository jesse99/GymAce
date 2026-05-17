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
    /// Return all the workouts that are scheduled to happen on the specified date.
    func findWorkouts(on: Date, today: Date = Date.now) -> [WorkoutEntry] {
        var candidates:[Workout] = []

        let calendar = Calendar.current
        let week = currentWeek(on: on)
//        print("week: \(week!)")
        for workout in self.workouts {
//            print("workout: \(workout.name) weeks: \(workout.weeks!)")
            if let r = workout.weeks, let w = week, !r.contains(w) {
                continue
            }
            switch workout.schedule {
            case .anyDay:
                // We only schedule anyDay workouts for the first available option to avoid clutter.
                if workout.weeks != nil || calendar.isDate(on, inSameDayAs: today) {
                    candidates.append(workout)
                }
            case .every(1): // like anyDay
                if workout.weeks != nil || calendar.isDate(on, inSameDayAs: today) {
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
        
        let entries: [WorkoutEntry] = if let delta = today.daysBetween(on) {
            candidates.map {WorkoutEntry($0, delta: delta, today: today)}
        } else {
            []
        }

        return entries
    }
}
