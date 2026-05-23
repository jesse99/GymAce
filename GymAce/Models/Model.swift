import Foundation
import SwiftUI

fileprivate let url: URL = .documentsDirectory.appending(component: "GymAce7").appendingPathExtension("json")

@Observable
final class Model: Codable {
    var notes: Notes = Notes()
    var weightSets: [String: WeightSet] = [:]
    var programs: [Program] = []
    var activeProgram: String = ""
        
    /// Set if the model (and child objects) may be dirty. Note that we don't track this exactly because it's cumbersome to
    /// track each bit of state (and doing something like a crc of the persisted model state is about as expensive as just
    /// doing a save and chews up CPU and battery if state didn't actually change).
    var dirty = false
    
    func fixup() {
//        let plates = [Plate(5.0, 4), Plate(10.0, 4), Plate(25.0, 4), Plate(45.0, 6)]
//        let dual = DualPlates(plates: plates, bar: 60.0, units: .Imperial)
//        weightSets["Trapbar"] = WeightSet.dual(dual)

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
#if targetEnvironment(simulator)
            print("skipping load")
            return Model()
#else
            let data = try Data(contentsOf: url)
            let model = try JSONDecoder().decode(Model.self, from: data)
            model.fixup()
            return model
#endif
        } catch {
            // Note that new fields are OK if they are optionals. Otherwise
            // a cusom init(from decoder: Decoder) method is required to
            // load old models.
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return Model()
            } else {
                fatalError("error loading model: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        do {
            print("saving")
            let data = try JSONEncoder().encode(self)
            try data.write(to: url)
        } catch {
            // TODO show an error to the user? tho dunno what they can do with it...
            fatalError("error saving model: \(error.localizedDescription)")
        }
        dirty = false
    }
}
