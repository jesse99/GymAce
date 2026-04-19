import Foundation

/// When to perform a Workout.
enum Schedule: nonisolated Codable {
    /// The user can do the workout whenever is convenient. This would be used for stuff like cardio.
    case anyDay
    
    /// If 2 then the workout should be performed every other day, if 3 then every 3rd day, etc.
    case every(Int)

    /// List of days when the workout should be performed, e.g. Mon and Wed.
    case days(Weekdays)
}

extension Schedule {
    func id() -> Int {
        switch self {
        case .anyDay: return 0
        case .every(_): return 1
        case .days(_): return 2
        }
    }
}

// It'd be simpler if Schedule.days simply had an [Int], but SwiftData is still flaky in
// handling enums with associated data and I was getting runtime errors doing that.
struct Weekdays: Codable {
    /// Explicit enumeration of when the workout should be done, e.g. Mon and Wed. To support
    /// localization these are ints from 1 to N where N depends on the current locale. For
    /// the Gregorian calendar it'll be:
    /// Sun  Mon  Tue  Wed  Thu  Fri  Sat    these are the calendar.shortWeekdaySymbols names for Gregorian
    /// 1    2    3    4    5    6    7
    let days: [Int]
    
    func includes(_ day: Int) -> Bool {
        days.contains(day)
    }
}
