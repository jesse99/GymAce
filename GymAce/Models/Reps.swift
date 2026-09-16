/// Used for warmup and backoff sets.
struct OtherReps: Codable {
    var reps: Int
    var percent: Int
    
    init(reps: Int, percent: Int) {
        self.reps = reps
        self.percent = percent
    }

    /// Parse a string formatted as "5/80".
    init?(_ str: String) {
        let parts = str.split(separator: "/")
        guard parts.count == 2 else {return nil}
        guard let reps = Int(parts[0]) else {return nil}
        guard let percent = Int(parts[1]) else {return nil}
        
        self.reps = reps
        self.percent = percent
    }
    
    func asString() -> String {
        return "\(reps)/\(percent)"
    }
}

/// Similar to OtherReps except that the reps string can omit the percent.
struct PercentReps: Codable {
    var reps: Int
    var percent: Int
    
    init(reps: Int, percent: Int) {
        self.reps = reps
        self.percent = percent
    }

    /// Parse a string formatted as "5" or "5/80".
    init?(_ str: String) {
        let parts = str.split(separator: "/")
        if parts.count == 1 {
            guard let reps = Int(str) else {return nil}
            self.reps = reps
            self.percent = 100
        } else {
            guard parts.count == 2 else {return nil}
            guard let reps = Int(parts[0]) else {return nil}
            guard let percent = Int(parts[1]) else {return nil}
            self.reps = reps
            self.percent = percent
        }
    }
    
    func asString() -> String {
        if percent == 100 {
            return "\(reps)"
        } else {
            return "\(reps)/\(percent)"
        }
    }
}

/// Used for work sets with variable style.
struct VariableReps: Codable {
    var minReps: Int
    var maxReps: Int
    var percent: Int

    init(minReps: Int, maxReps: Int, percent: Int) {
        self.minReps = minReps
        self.maxReps = maxReps
        self.percent = percent
    }

    /// Parse a string formatted as "5" or  "4-8" with an optional percent suffix like "/80".
    init?(_ str: String) {
        var text = str
        var percent = 100
        if str.contains("/") {
            let parts = str.split(separator: "/")
            guard parts.count == 2 else {return nil}
            guard let p = Int(parts[1]) else {return nil}
            text = String(parts[0])
            percent = p
        }
        
        if text.contains("-") {
            let parts = text.split(separator: "-")
            guard parts.count == 2 else {return nil}
            guard let min = Int(parts[0]) else {return nil}
            guard let max = Int(parts[1]) else {return nil}
            guard min <= max else {return nil}
            self.minReps = min
            self.maxReps = max
        } else {
            guard let reps = Int(text) else {return nil}
            self.minReps = reps
            self.maxReps = reps
        }
        self.percent = percent
    }
    
    func asString() -> String {
        if minReps == maxReps {
            if percent == 100 {
                return "\(minReps)"
            } else {
                return "\(minReps)/\(percent)"
            }
        } else {
            if percent == 100 {
                return "\(minReps)-\(maxReps)"
            } else {
                return "\(minReps)-\(maxReps)/\(percent)"
            }
        }
    }
}
