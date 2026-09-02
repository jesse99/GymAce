import Foundation

/// Controls how an exercise is performed: rest, reps, progression, etc.
enum Style: Codable {
    /// Reps increase to a max then weight increases and expected reps is set to min.
    case double_progression(DoubleProgressionInfo)
    
    /// Exercise is done for a specified number of seconds up to a target value.
    case durations(DurationsInfo)

    /// Four week blocks with increasing weight but fewer reps each week. Last week
    /// has an AMRAP set which controls whether weight is increased.
    case gzcl(GzclInfo)
    
    /// Uses the exercise's formalName to find an exercise with that same formalName
    /// that also has a baseWeight. That exercise is used as the style except that an
    /// extra percentage is applied to weight. TODO validate needs to verify that there is one match
    case percent(PercentInfo)
    
    /// Exercise is done for an arbitrary amount of time, e.g. jogging.
    case timed
}

// TODO may want an init that takes a string, eg (warmup: "5@70, 3@80, 1@90", workset: "3x8-12")
struct DoubleProgressionInfo: Codable {
    var rest: Int?
}

struct DurationsInfo: Codable {
    var secs: [Int]
    var targetSecs: Int?
    
    init(secs: [Int], targetSecs: Int? = nil) {
        self.secs = secs
        self.targetSecs = targetSecs
    }
}

struct GzclInfo: Codable {
    var rest: Int?
}

struct PercentInfo: Codable {
    var rest: Int?
    var percent: Float
}

extension Exercise {
    /// Seconds to rest after each work set.
    func rest(_ program: Program, _ workout: Workout) -> Int? {   // TODO may also want min/max rest (these would be recommendations)
        guard let style = findStyle(program, workout) else {
            return nil
        }
        switch style {
        case .double_progression(let info): return info.rest
        case .durations(_): return nil
        case .gzcl(let info): return info.rest
        case .percent(let info): return info.rest   // this is an exception: we'll use rest from the exercise style instead of other style
        case .timed: return nil
        }
    }
    
    /// The actual weight to use for a set. This will be adjusted using the percentage for the set
    /// and the baseWeight may be taken from another exercise, e.g. gzcl will use baseWeight
    /// from the Max version of the exercise.
    func weight(_ program: Program, _ workout: Workout) -> Float? {
        // TODO need to use warmup and workset percents
        // TODO for gzcl need to use Max version of the exercise
        //      also assert that baseWeight is nil
        //      will need to search for self.name in workout.entries to figure out the tier
        return self.baseWeight
    }
    
    // The exercise won't really work if this returns nil, but Model.validate
    // will show the user an error message in that case.
    fileprivate func findStyle(_ program: Program, _ workout: Workout) -> Style? {
        return program.findStyle(self.styleName)    // TODO validate needs to catch missing Exercise.styleName
    }
}

