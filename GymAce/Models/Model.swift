import Foundation
import SwiftUI

fileprivate let url: URL = .documentsDirectory.appending(component: "GymAce5").appendingPathExtension("json")

@Observable
final class Model: Codable {
    var notes: Notes = Notes()
    var weightSets: [String: WeightSet] = [:]
    var programs: [Program] = []
    var activeProgram: String = ""
    
    func fixup() {
//        let plates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
//        let dual = DualPlates(plates: plates, bar: 45.0, units: .Imperial)
//        weightSets["Dual Plates"] = WeightSet.dual(dual)

        let plates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
        let dual = DualPlates(plates: plates, bar: 60.0, units: .Imperial)
        weightSets["Trapbar"] = WeightSet.dual(dual)

        for p in programs {
            p.fixup()
        }
    }
        
    func active() -> Program? {
        return programs.first(where: {$0.name == activeProgram})
    }
    
    func addProgram(_ program: Program) {
        self.programs.append(program)
    }
    
    func deletePrograms(_ offsets: IndexSet) {
        self.programs.remove(atOffsets: offsets)
    }
    
    func renameProgram(_ program: Program, _ newName: String) {
        if activeProgram == program.name {
            activeProgram = newName
        }
        program.name = newName
    }
    
    static func load() -> Model {
        do {
            let data = try Data(contentsOf: url)
            let model = try JSONDecoder().decode(Model.self, from: data)
            model.fixup()
            return model
        } catch {
            return Model()
        }
    }
    
    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: url)
        } catch {
            // TODO show an error to the user? tho dunno what they can do with it...
            fatalError("error saving: \(error.localizedDescription)")
        }
    }
}
