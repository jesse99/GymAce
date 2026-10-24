import Foundation

// Public for unit tests
func make(_ name: String, _ formalName: String, _ styleName: String, weights: String? = nil, weight: Float? = nil) -> Exercise {
    let w = if let x = weight {
        BaseWeight.weight(x)
    } else {
        BaseWeight.none
    }
    if let n = weights {
        return Exercise(name: name, formalName: formalName, styleName: styleName, weights: n, weight: w)
    } else {
        return Exercise(name: name, formalName: formalName, styleName: styleName, weight: w)
    }
}

func make(_ name: String, _ formalName: String, _ styleName: String, weights: String? = nil, base: BaseWeight) -> Exercise {
    if let n = weights {
        return Exercise(name: name, formalName: formalName, styleName: styleName, weights: n, weight: base)
    } else {
        return Exercise(name: name, formalName: formalName, styleName: styleName, weight: base)
    }
}

// Public for unit tests
func addCompleted(_ program: Program, _ exercise: Exercise, daysAgo: Int, reps: [Int], weights: [Float]? = nil, note: String? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let b = exercise.findBaseWeight(program)
    let c = Completed(reps: reps, weights: weights, baseWeight: b, units: .Imperial, completed: d!)
    c.note = note
    exercise.history.append(c)
}

// Public for unit tests
func addCompleted(_ program: Program, _ exercise: Exercise, daysAgo: Int, secs: [Int], weights: [Float]? = nil) {
    let calendar = Calendar.current
    let d = calendar.date(byAdding: .day, value: -daysAgo, to: Date())
    let b = exercise.findBaseWeight(program)
    let c = Completed(secs: secs, weights: weights, baseWeight: b, units: .Imperial, completed: d!)
    exercise.history.append(c)
}

// TODO may want to move these to wizard
func amrapStyle(warmup: String, workset: String, rest: String) -> Style {
    if let i = AMRAPInfo(warmup: warmup, workset: workset, rest: rest) {
        return .amrap(i)
    } else {
        fatalError("bad args")
    }
}

func basicStyle(warmup: String, workset: String, rest: String) -> Style {
    if let i = BasicInfo(warmup: warmup, workset: workset, rest: rest) {
        return .basic(i)
    } else {
        fatalError("bad args")
    }
}

func manualStyle(warmup: String, workset: String, rest: String) -> Style {
    if let i = VariableInfo(warmup: warmup, workset: workset, rest: rest) {
        return .manual(i)
    } else {
        fatalError("bad args")
    }
}

func variableStyle(warmup: String, workset: String, rest: String) -> Style {
    if let i = VariableInfo(warmup: warmup, workset: workset, rest: rest) {
        return .variable(i)
    } else {
        fatalError("bad args")
    }
}

func oneRepMaxStyle(warmup: String, workset: String, rest: String) -> Style {
    if let i = OneRepMaxInfo(warmup: warmup, workset: workset, rest: rest) {
        return .oneRepMax(i)
    } else {
        fatalError("bad args")
    }
}

func durationsStyle(secs: String, targetSecs: String) -> Style {
    if let i = DurationsInfo(secs: secs, targetSecs: targetSecs) {
        return .durations(i)
    } else {
        fatalError("bad args")
    }
}

func defaultWeightSets(_ units: Units) -> [String: WeightSet] {
    if case .Metric = units {
        return metricWeights()
    } else {
        return imperialWeights()
    }
}

fileprivate func imperialWeights() -> [String: WeightSet] {
    var sets: [String: WeightSet] = [:]
    
    let upperPlates = [Plate(2.5, 2), Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
    let lowerPlates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]

    var dual = PlateWeights(dual: true, plates: lowerPlates, bar: 45.0, units: .Imperial)
    sets["Dual Lower Plates"] = WeightSet.plates(dual)

    dual = PlateWeights(dual: true, plates: upperPlates, bar: 45.0, units: .Imperial)
    sets["Dual Upper Plates"] = WeightSet.plates(dual)
    
    var single = PlateWeights(dual: false, plates: lowerPlates, bar: 45.0, units: .Imperial)
    sets["Single Lower Plates"] = WeightSet.plates(single)
    
    single = PlateWeights(dual: false, plates: upperPlates, bar: 45.0, units: .Imperial)
    sets["Single Upper Plates"] = WeightSet.plates(single)

    dual = PlateWeights(dual: true, plates: lowerPlates, bar: 0.0, units: .Imperial)
    sets["Dual Lower Plates no bar"] = WeightSet.plates(dual)

    dual = PlateWeights(dual: true, plates: upperPlates, bar: 0.0, units: .Imperial)
    sets["Dual Upper Plates no bar"] = WeightSet.plates(dual)

    single = PlateWeights(dual: false, plates: lowerPlates, bar: 0.0, units: .Imperial)
    sets["Single Lower Plates no bar"] = WeightSet.plates(single)

    single = PlateWeights(dual: false, plates: upperPlates, bar: 0.0, units: .Imperial)
    sets["Single Upper Plates no bar"] = WeightSet.plates(single)
    
    dual = PlateWeights(dual: true, plates: lowerPlates, bar: 60.0, units: .Imperial)
    sets["Trapbar"] = WeightSet.plates(dual)

    let cable = DiscreteWeights(weights: [2.5, 7.5, 12.5, 17.5, 22.5, 27.5, 32.5, 37.5, 42.5, 47.5, 52.5, 57.5, 62.5, 67.5, 72.5, 77.5, 82.5, 87.5, 92.5, 97.5], units: .Imperial)
    sets["Cable Machine"] = WeightSet.discrete(cable)

    var dumbbells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0], units: .Imperial)
    sets["Dumbbells"] = WeightSet.discrete(dumbbells)

    dumbbells = DiscreteWeights(weights: [5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0, 30.0, 40.0, 45.0, 52.5], units: .Imperial)
    sets["Home Dumbbells"] = WeightSet.discrete(dumbbells)

    let kettlebells = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 40.0, 50], units: .Imperial)
    sets["Kettlebells"] = WeightSet.discrete(kettlebells)
    
    return sets
}

fileprivate func metricWeights() -> [String: WeightSet] {
    var sets: [String: WeightSet] = [:]
    
    let upperPlates = [Plate(1.25, 2), Plate(2.5, 4), Plate(5.0, 4), Plate(10.0, 4), Plate(20.0, 6)]
    let lowerPlates = [Plate(2.5, 4), Plate(5.0, 4), Plate(10.0, 4), Plate(20.0, 6)]

    var dual = PlateWeights(dual: true, plates: lowerPlates, bar: 20, units: .Metric)
    sets["Dual Lower Plates"] = WeightSet.plates(dual)

    dual = PlateWeights(dual: true, plates: upperPlates, bar: 20, units: .Metric)
    sets["Dual Upper Plates"] = WeightSet.plates(dual)
    
    var single = PlateWeights(dual: false, plates: lowerPlates, bar: 20, units: .Metric)
    sets["Single Lower Plates"] = WeightSet.plates(single)
    
    single = PlateWeights(dual: false, plates: upperPlates, bar: 20, units: .Metric)
    sets["Single Upper Plates"] = WeightSet.plates(single)

    dual = PlateWeights(dual: true, plates: lowerPlates, bar: 0.0, units: .Metric)
    sets["Dual Lower Plates no bar"] = WeightSet.plates(dual)

    dual = PlateWeights(dual: true, plates: upperPlates, bar: 0.0, units: .Metric)
    sets["Dual Upper Plates no bar"] = WeightSet.plates(dual)

    single = PlateWeights(dual: false, plates: lowerPlates, bar: 0.0, units: .Metric)
    sets["Single Lower Plates no bar"] = WeightSet.plates(single)

    single = PlateWeights(dual: false, plates: upperPlates, bar: 0.0, units: .Metric)
    sets["Single Upper Plates no bar"] = WeightSet.plates(single)
    
    dual = PlateWeights(dual: true, plates: lowerPlates, bar: 25, units: .Metric)
    sets["Trapbar"] = WeightSet.plates(dual)

    let cable = DiscreteWeights(weights: [2.5, 5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0, 27.5, 30.0, 32.5, 35.0, 37.5, 40.0, 42.5, 45.0, 47.5, 50.0], units: .Metric)
    sets["Cable Machine"] = WeightSet.discrete(cable)

    var dumbbells = DiscreteWeights(weights: [2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 30.0, 32.0, 34.0, 36.0, 38.0, 40.0, 42.0, 44.0, 46.0, 48.0, 50.0], units: .Metric)
    sets["Dumbbells"] = WeightSet.discrete(dumbbells)

    dumbbells = DiscreteWeights(weights: [2.5, 5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0, 27.5, 30.0, 32.5, 35.0, 37.5, 40.0, 42.5, 45.0, 47.5, 50.0], units: .Metric)
    sets["Dumbbells2"] = WeightSet.discrete(dumbbells)

    dumbbells = DiscreteWeights(weights: [2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0], units: .Metric)
    sets["Home Dumbbells"] = WeightSet.discrete(dumbbells)

    dumbbells = DiscreteWeights(weights: [2.5, 5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0], units: .Metric)
    sets["Home Dumbbells2"] = WeightSet.discrete(dumbbells)

    let kettlebells = DiscreteWeights(weights: [4, 6, 8, 12, 16, 20, 24, 28], units: .Metric)
    sets["Kettlebells"] = WeightSet.discrete(kettlebells)
    
    return sets
}
