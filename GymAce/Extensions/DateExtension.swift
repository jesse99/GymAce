import Foundation

extension Date {
    /// Returns the number of days from self to rhs. 0 got today, 1 for tomrrow, -1 for yesterday, etc.
    func daysBetween(_ rhs: Date) -> Int? {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: self, to: rhs).day
    }

    /// Returns a string representing the number of days between two dates, e.g. 0 => "Today",
    /// 1 => "Tomorrow", 2 => "Thursday", 8 => "In 8 days", -1 =? "Yesterday", etc.
    func daysStr(_ days: Int) -> String {
        let calendar = Calendar.current
        let daysInWeek = calendar.weekdaySymbols.count
        if days >= 0 {
            if days == 0 {
                return "Today"
            } else if days == 1 {
                return "Tomorrow"
            } else if days < daysInWeek {
                if let date = calendar.date(byAdding: .day, value: days, to: self) {
                    let day: Int = calendar.component(.weekday, from: date)
                    return calendar.weekdaySymbols[day - 1]
                } else {
                    return "?"
                }
            } else {
                return "In \(days) days"
            }
        } else {
            if days == -1 {
                return "Yesterday"
            } else if -days < daysInWeek {
                if let date = calendar.date(byAdding: .day, value: days, to: self) {
                    let day: Int = calendar.component(.weekday, from: date)
                    return calendar.weekdaySymbols[day - 1]
                } else {
                    return "?"
                }
            } else {
                return "\(-days) ago"
            }
        }
    }
}
