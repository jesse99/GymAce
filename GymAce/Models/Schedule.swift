import Foundation

/// When to perform a Workout.
enum Schedule: nonisolated Codable {
    /// The user can do the workout whenever is convenient. This would be used for stuff like cardio.
    case anyDay
    
    /// If 2 then the workout should be performed every other day, if 3 then every 3rd day, etc.
    case every(Int)
    
    /// Explicit enumeration of when the workout should be done, e.g. Mon and Wed.
    case days([Locale.Weekday])
}
