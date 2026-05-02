import Testing
@testable import GymAce

struct AdvanceTests {
    @Test("Some dumbbells")
    func advance0() {
        let weights = DiscreteWeights(weights: [5.0, 10.0, 15.0, 20.0], units: .Imperial)
        let ws = WeightSet(name: "dumbbells", discrete: weights)
        
        var v = ws.advance(target: 0.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.advance(target: 4.0)
        #expect(v.text() == "5 lbs")
        
        v = ws.advance(target: 5.0)
        #expect(v.text() == "10 lbs")
        
        v = ws.advance(target: 6.0)
        #expect(v.text() == "10 lbs")
    }
    
    @Test("Some plates but no bar")
    func advance1() {
        let plates = [Plate(5.0, 6), Plate(10.0, 6), Plate(25.0, 4), Plate(45.0, 4)]
        let dual = DualPlates(plates: plates, units: .Metric)
        let ws = WeightSet(name: "OHP", dual: dual)
        
        var v = ws.advance(target: 0.0)
        #expect(v.details() == "5")
        
        v = ws.advance(target: 4.0)
        #expect(v.details() == "5")
        
        v = ws.advance(target: 11.0)
        #expect(v.details() == "10")
        
        v = ws.advance(target: 20.0)
        #expect(v.details() == "10 + 5")
        
        v = ws.advance(target: 25.0)
        #expect(v.details() == "10 + 5")

        v = ws.advance(target: 27.0)
        #expect(v.details() == "10 + 5")
    }
    
    @Test("Some plates with bar")
    func advance2() {
        let plates = [Plate(5.0, 6), Plate(10.0, 6), Plate(25.0, 4), Plate(45.0, 4)]
        let dual = DualPlates(plates: plates, bar: 45.0, units: .Metric)
        let ws = WeightSet(name: "OHP", dual: dual)
        
        var v = ws.advance(target: 0.0)
        #expect(v.details() == "")
        
        v = ws.advance(target: 45.0)
        #expect(v.details() == "5")
        
        v = ws.advance(target: 50.0)
        #expect(v.details() == "5")
        
        v = ws.advance(target: 55.0)
        #expect(v.details() == "10")
    }
}
