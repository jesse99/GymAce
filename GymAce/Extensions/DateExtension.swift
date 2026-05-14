import Foundation

extension Date {
    /// Returns the number of days from self to rhs. 0 got today, 1 for tomrrow, -1 for yesterday, etc.
    func daysBetween(_ rhs: Date) -> Int? {
        let calendar = Calendar.current
        if calendar.component(.year, from: self) == calendar.component(.year, from: rhs) {
            return rhs.julianDay() - self.julianDay()
        } else {
            return nil  // TODO use https://swiftpackageindex.com/sbooth/juliandaynumber/main/documentation/juliandaynumber/juliancalendar so that this works for year changes?
        }
    }
    
    func julianDay() -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self) % 100 // Last two digits of year
        let day = calendar.ordinality(of: .day, in: .year, for: self) ?? 0
        return year * 1000 + day
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
