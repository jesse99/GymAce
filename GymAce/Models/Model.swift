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
        
    static func load() -> Model {
        do {
//#if targetEnvironment(simulator)
//            print("skipping load")
//            return Model()
//#else
            let data = try Data(contentsOf: url)
            let model = try JSONDecoder().decode(Model.self, from: data)
            model.fixup()
            return model
//#endif
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
    
    func renameWeightSet(oldName: String, newName: String) {
        if let ws = self.weightSets[oldName] {
            self.weightSets[oldName] = nil
            self.weightSets[newName] = ws
            
            for p in self.programs {
                for e in p.exercises where e.weightSet == oldName {
                    e.weightSet = newName
                }
            }
        }
    }
    
    func addWeightSet(_ name: String, _ ws: WeightSet) {
        self.weightSets[name] = ws
    }
    
    func deleteWeightSets(_ names: [String]) {
        for name in names {
            self.weightSets[name] = nil
        }
    }
    
    func weightSetsInUse(_ name: String) -> Bool {
        if let p = active() {
            for w in p.workouts {
                for entry in w.entries {
                    if let e = p.findExercise(entry.name), let n = e.weightSet, n == name, weightSets[n] != nil {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func weightSetsUsedBy(_ name: String) -> String {
        var exercises: [String] = []
        if let p = active() {
            for w in p.workouts {
                for entry in w.entries {
                    if let e = p.findExercise(entry.name), let n = e.weightSet, n == name, weightSets[n] != nil {
                        exercises.append(e.name)
                    }
                }
            }
        }
        return exercises.joined(separator: ", ")
    }
    
    func addMissingWeightsets() {
        if let p = active() {
            for w in p.workouts {
                for entry in w.entries {
                    if let e = p.findExercise(entry.name), let n = e.weightSet {
                        if weightSets[n] == nil {
                            if let ws = findDefaultWeightSet(n) {
                                weightSets[n] = ws
                                print("added weight set \(n)")
                            } else {
                                print("couldn't find weight set \(n)")  // TODO probably should have a warning somewhere for this
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addProgram(_ program: Program) {
        self.programs.append(program)
    }
    
    func deletePrograms(_ names: [String]) {
        for name in names {
            if name != activeProgram {      // TODO little weird, but w/o this wind up with a blank screen (because parent view is now whacked?)
                if let index = self.programs.firstIndex(where: {$0.name == name}) {
                    self.programs.remove(at: index)
                }
            }
        }
    }
    
    func renameProgram(_ program: Program, _ newName: String) {
        if activeProgram == program.name {
            activeProgram = newName
        }
        program.name = newName
    }
}
