import Foundation
import SwiftData

/// Data associated with every exercise type. Not all of this may be used by a particular exercise, but it all can be.
final class ExerciseData: nonisolated Codable {
    init(name: String, formalName: String) {
        self.name = name
        self.formalName = formalName
    }
    
    /// User name, just for presentation
    private(set) var name: String

    /// Official name, used to lookup notes for an exercise
    private(set) var formalName: String
    
    // TODO also started, finished, enabled, set info, weight info
}

// TODO will there be schema migration issues if new cases are added?
// TODO will have to be careful about associated data, for example arrays seem problematic
enum Exercise: nonisolated Codable {
    case durations(ExerciseData)
}
