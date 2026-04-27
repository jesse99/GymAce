import Testing
@testable import GymAce

struct EnumerateTests {
    @Test("No plates")
    func enumerate0() {
        let plates: [Plate] = []
        let v = enumeratePlates(plates)
        #expect(v.count == 0)
    }
    
    @Test("One weight x2")
    func enumerate1() {
        let plates: [Plate] = [Plate(45.0, 2)]
        let v = enumeratePlates(plates)
        #expect(v.count == 1)
        #expect(v[0] == [Plate(45.0, 1)])
    }
    
    @Test("One weight x4")
    func enumerate2() {
        let plates: [Plate] = [Plate(45.0, 4)]
        let v = enumeratePlates(plates)
        #expect(v.count == 2)
        #expect(v[0] == [Plate(45.0, 1)])
        #expect(v[1] == [Plate(45.0, 2)])
    }

    @Test("Two weights")
    func enumerate3() {
        let plates: [Plate] = [Plate(45.0, 2), Plate(25.0, 2)]
        let v = enumeratePlates(plates)
        #expect(v.count == 3)
        #expect(v[0] == [Plate(25.0, 1)])
        #expect(v[1] == [Plate(45.0, 1)])
        #expect(v[2] == [Plate(45.0, 1), Plate(25.0, 1)])
    }

    @Test("Two weights - different counts")
    func enumerate4() {
        let plates: [Plate] = [Plate(45.0, 2), Plate(25.0, 4)]
        let v = enumeratePlates(plates)
//        print("\(v)")
        #expect(v.count == 5)
        #expect(v[0] == [Plate(25.0, 1)])
        #expect(v[1] == [Plate(45.0, 1)])
        #expect(v[2] == [Plate(25.0, 2)])
        #expect(v[3] == [Plate(45.0, 1), Plate(25.0, 1)])
        #expect(v[4] == [Plate(45.0, 1), Plate(25.0, 2)])
    }

    @Test("Two weights x4")
    func enumerate5() {
        let plates: [Plate] = [Plate(45.0, 4), Plate(25.0, 4)]
        let v = enumeratePlates(plates)
        #expect(v.count == 8)
        #expect(v[0] == [Plate(25.0, 1)])
        #expect(v[1] == [Plate(45.0, 1)])
        #expect(v[2] == [Plate(25.0, 2)])
        #expect(v[3] == [Plate(45.0, 1), Plate(25.0, 1)])
        #expect(v[4] == [Plate(45.0, 2)])
        #expect(v[5] == [Plate(45.0, 1), Plate(25.0, 2)])
        #expect(v[6] == [Plate(45.0, 2), Plate(25.0, 1)])
        #expect(v[7] == [Plate(45.0, 2), Plate(25.0, 2)])
    }

    @Test("Many weights")
    func enumerate6() {
        let plates: [Plate] = [
            Plate(100.0, 4),        // 6074 before pruning
            Plate(45.0, 4),
            Plate(25.0, 2),
            Plate(10.0, 2),
            Plate(5.0, 2),
            Plate(2.5, 2),
            Plate(1.25, 2),
        ]
        let v = enumeratePlates(plates)
        #expect(v.count == 247)
    }
}
