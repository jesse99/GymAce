import Testing
@testable import GymAce

struct LowerUpperTests {
    @Test("Dual Plates no bar")
    func lu0() {
        let plates = [Plate(5.0, 6), Plate(10.0, 6), Plate(25.0, 4), Plate(45.0, 4)]
        let dual = DualPlates(plates: plates, units: .Metric)
        let ws = WeightSet(name: "OHP", dual: dual)
        
        #expect(compute(ws, 11.0) == ("5", "10"))
        #expect(compute(ws, 14.0) == ("5", "10"))
        #expect(compute(ws, 18.0) == ("5", "10"))
        #expect(compute(ws, 20.0) == ("10", "10 + 5"))
        #expect(compute(ws, 21.0) == ("10", "10 + 5"))
        #expect(compute(ws, 30.0) == ("10 + 5", "10x2"))
        #expect(compute(ws, 40.0) == ("10x2", "25"))
        #expect(compute(ws, 50.0) == ("25", "25 + 5"))
        #expect(compute(ws, 103.0) == ("25x2", "45 + 10"))
        #expect(compute(ws, 120.0) == ("25x2 + 10", "45 + 10x2"))
        #expect(compute(ws, 130.0) == ("45 + 10x2", "45 + 25"))
        #expect(compute(ws, 135.0) == ("45 + 10x2", "45 + 25"))
        #expect(compute(ws, 160.0) == ("45 + 25 + 10", "45 + 25 + 10 + 5"))
        #expect(compute(ws, 205.0) == ("45x2 + 10", "45x2 + 10 + 5"))
        #expect(compute(ws, 230.0) == ("45x2 + 25", "45x2 + 25 + 5"))
        #expect(compute(ws, 240.0) == ("45x2 + 25 + 5", "45x2 + 25 + 10"))
        #expect(compute(ws, 250.0) == ("45x2 + 25 + 10", "45x2 + 25 + 10 + 5"))
        #expect(compute(ws, 260.0) == ("45x2 + 25 + 10 + 5", "45x2 + 25 + 10x2"))
        #expect(compute(ws, 270.0) == ("45x2 + 25 + 10x2", "45x2 + 25x2"))
        #expect(compute(ws, 300.0) == ("45x2 + 25x2 + 10", "45x2 + 25x2 + 10 + 5"))
        #expect(compute(ws, 320.0) == ("45x2 + 25x2 + 10x2", "45x2 + 25x2 + 10x2 + 5"))
        #expect(compute(ws, 340.0) == ("45x2 + 25x2 + 10x3", "45x2 + 25x2 + 10x3 + 5"))
        #expect(compute(ws, 380.0) == ("45x2 + 25x2 + 10x3 + 5x3", "45x2 + 25x2 + 10x3 + 5x3"))
    }
    
    @Test("Dual Plates with bar")
    func lu1() {
        // we'll use a somewhat unusual plate distribution here
        let plates = [Plate(5.0, 3), Plate(10.0, 2), Plate(25.0, 6), Plate(45.0, 2)]
        let dual = DualPlates(plates: plates, bar: 45.0, units: .Metric)
        let ws = WeightSet(name: "OHP", dual: dual)
        
        #expect(compute(ws, 60.0) == ("5", "10"))   // can only add a max of 2 5's
        #expect(compute(ws, 70.0) == ("10", "10 + 5"))
        #expect(compute(ws, 80.0) == ("10 + 5", "25"))
        #expect(compute(ws, 90.0) == ("10 + 5", "25"))
        #expect(compute(ws, 120.0) == ("25 + 10", "25 + 10 + 5"))
        #expect(compute(ws, 150.0) == ("25x2", "45 + 10"))
        #expect(compute(ws, 180.0) == ("25x2 + 10 + 5", "45 + 25"))
        #expect(compute(ws, 200.0) == ("25x3", "45 + 25 + 10"))
        #expect(compute(ws, 230.0) == ("25x3 + 10 + 5", "45 + 25x2"))
        #expect(compute(ws, 260.0) == ("45 + 25x2 + 10", "45 + 25x2 + 10 + 5"))
        #expect(compute(ws, 290.0) == ("45 + 25x3", "45 + 25x3 + 5"))
        #expect(compute(ws, 320.0) == ("45 + 25x3 + 10 + 5", "45 + 25x3 + 10 + 5"))
    }
    
    private func compute(_ ws: WeightSet, _ target: Float) -> (String, String) {
        return (ws.lower(target: target).details()!, ws.upper(target: target).details()!)
    }
}
