import Foundation

extension Date {
    /// Returns the number of days from self to rhs. 0 got today, 1 for tomrrow, -1 for yesterday, etc.
    func daysBetween(_ rhs: Date) -> Int? {
        let calendar = Calendar.current
        
        let rhsStart = calendar.startOfDay(for: rhs)
        let todayStart = calendar.startOfDay(for: self)
        
        let components = calendar.dateComponents([.day], from: todayStart, to: rhsStart)
        return components.day

//        let calendar = Calendar.current
//        if calendar.component(.year, from: self) == calendar.component(.year, from: rhs) {
//            return rhs.julianDay() - self.julianDay()
//        } else {
//            return nil  // TODO use https://swiftpackageindex.com/sbooth/juliandaynumber/main/documentation/juliandaynumber/juliancalendar so that this works for year changes?
//        }
    }
    
//    func julianDay() -> Int {
//        let calendar = Calendar.current
//        let year = calendar.component(.year, from: self) % 100 // Last two digits of year
//        let day = calendar.ordinality(of: .day, in: .year, for: self) ?? 0
//        return year * 1000 + day
//    }
    
    ///  Number of weeks since May 3, 2026. Note that this is 1 based.
    func weekNumber() -> Int? {
        if let e = epoch(), let days = e.daysBetween(self) {
            return days/7 + 1
        }
        return nil
    }

    /// We'll compute weeks starting from May 3, 2026.
    private func epoch() -> Date? {
        var components = DateComponents()
        components.year = 2026
        components.month = 5
        components.day = 3          // be sure to start on a Sunday

        return Calendar.current.date(from: components)
    }

    /// Returns a string representing the number of days between two dates, e.g. 0 => "Today",
    /// 1 => "Tomorrow", 2 => "Thursday", 8 => "In 8 days", -1 =? "Yesterday", etc.
    func daysStr(_ days: Int) -> String {
        // Swift does have a RelativeDateTimeFormatter. Not sure that would be
        // quite as good for our purposes...
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
