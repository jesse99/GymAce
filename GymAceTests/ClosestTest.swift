import Testing
@testable import GymAce

struct ClosestTests {
    @Test("No dumbbells")
    func closest0() {
        let weights = DiscreteWeights(weights: [], units: .Imperial)
        let ws = WeightSet(name: "dumbbells", discrete: weights)
        let v = ws.closest(target: 10.0)
        #expect(v.text() == "0 lbs")        // not much else we can do here
    }
    
    @Test("Some dumbbells")
    func closest1() {
        let weights = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0], units: .Imperial)
        let ws = WeightSet(name: "dumbbells", discrete: weights)
        
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
    
    @Test("Some plates but no bar")
    func closest2() {
        let plates = [Plate(5.0, 6), Plate(10.0, 6), Plate(25.0, 4), Plate(45.0, 4)]
        let dual = DualPlates(plates: plates, units: .Metric)
        let ws = WeightSet(name: "OHP", dual: dual)
        
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
        let dual = DualPlates(plates: plates, bar: 45.0, units: .Metric)
        let ws = WeightSet(name: "OHP", dual: dual)
        
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
