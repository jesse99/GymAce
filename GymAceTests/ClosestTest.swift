import Testing
@testable import GymAce

struct ClosestTests {
    @Test("No dumbbells")
    func closest0() {
        let weights = DiscreteWeights(weights: [], units: .Imperial)
        let ws = WeightSet.discrete(weights)
        let v = ws.closest(target: 10.0)
        #expect(v.text() == "0 lbs")        // not much else we can do here
    }
    
    @Test("Some dumbbells")
    func closest1() {
        let weights = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0], units: .Imperial)
        let ws = WeightSet.discrete(weights)

        var v = ws.closest(target: 0.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.closest(target: 4.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.closest(target: 5.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.closest(target: 6.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.closest(target: 9.0)
        #expect(v.text() == "10 lbs")
        
        v = ws.closest(target: 18.0)
        #expect(v.text() == "20 lbs")
        
        v = ws.closest(target: 30.0)
        #expect(v.text() == "20 lbs")
    }

    @Test("Dumbbells with extra 1")
    func extra1() {
        var weights = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0], units: .Imperial)
        weights.extra1 = 2.5
        let ws = WeightSet.discrete(weights)

        var v = ws.closest(target: 0.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.closest(target: 4.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.closest(target: 5.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.closest(target: 7.0)
        #expect(v.text() == "7.5 lbs")
        
        v = ws.closest(target: 8.0)
        #expect(v.text() == "7.5 lbs")

        v = ws.closest(target: 10.0)
        #expect(v.text() == "10 lbs")
    }

    @Test("Dumbbells with extra 2")
    func extra2() {
        var weights = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0], units: .Imperial)
        weights.extra2 = 2.5
        let ws = WeightSet.discrete(weights)

        var v = ws.closest(target: 0.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.closest(target: 4.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.closest(target: 5.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.closest(target: 7.0)
        #expect(v.text() == "7.5 lbs")
        
        v = ws.closest(target: 8.0)
        #expect(v.text() == "7.5 lbs")

        v = ws.closest(target: 10.0)
        #expect(v.text() == "10 lbs")
    }

    @Test("Dumbbells with extra 1 and 2")
    func extra3() {
        var weights = DiscreteWeights(weights: [10.0, 20.0, 30.0], units: .Imperial)
        weights.extra1 = 2.5
        weights.extra2 = 2.5
        let ws = WeightSet.discrete(weights)

        var v = ws.closest(target: 10.0)
        #expect(v.text() == "10 lbs")
        
        v = ws.closest(target: 12.0)
        #expect(v.text() == "12.5 lbs")
        
        v = ws.closest(target: 14.0)
        #expect(v.text() == "15 lbs")
        
        v = ws.closest(target: 16.0)
        #expect(v.text() == "15 lbs")

        v = ws.closest(target: 20.0)
        #expect(v.text() == "20 lbs")

    }
    
    @Test("Some plates but no bar")
    func closest2() {
        let plates = [Plate(5.0, 6), Plate(10.0, 6), Plate(25.0, 4), Plate(45.0, 4)]
        let dual = PlateWeights(dual: true, plates: plates, units: .Metric)
        let ws = WeightSet.plates(dual)

        var v = ws.closest(target: 0.0)
        #expect(v.details() == "")
        
        v = ws.closest(target: 4.0)
        #expect(v.details() == "")
        
        v = ws.closest(target: 8.0)
        #expect(v.details() == "5")
        
        v = ws.closest(target: 92.0)
        #expect(v.details() == "45")
        
        v = ws.closest(target: 97.0)
        #expect(v.details() == "25x2")

        v = ws.closest(target: 117.0)
        #expect(v.details() == "25x2 + 10")
    }

    @Test("Some plates with bar")
    func closest3() {
        let plates = [Plate(5.0, 6), Plate(10.0, 6), Plate(25.0, 4), Plate(45.0, 4)]
        let dual = PlateWeights(dual: true, plates: plates, bar: 45.0, units: .Metric)
        let ws = WeightSet.plates(dual)

        var v = ws.closest(target: 0.0)
        #expect(v.details() == "")
        
        v = ws.closest(target: 4.0)
        #expect(v.details() == "")
        
        v = ws.closest(target: 47.0)
        #expect(v.details() == "")
        
        v = ws.closest(target: 58.0)
        #expect(v.details() == "5")
        
        v = ws.closest(target: 63.0)
        #expect(v.details() == "10")

        v = ws.closest(target: 225.0)
        #expect(v.details() == "45x2")

        v = ws.closest(target: 235.0)
        #expect(v.details() == "45x2 + 5")
    }
}
