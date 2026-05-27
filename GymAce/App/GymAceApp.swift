import Foundation
import SwiftUI

@main
struct GymAceApp: App {
    var model: Model
    
    init() {
        model = Model.load()
        
        // TODO for now add Preview and My programs if they are not present
        //      don't include My program?
        //      Programs will need a defaultPrograms list
        //      also add program if debug?
        // TODO if a program is added grovel thru it and add any weight sets that are missing
        // TODO how do we handle program updates? add something like v2 to the name?
        //      or hijack version and install newer versions? can include a top of what changed
        //      or silently update if not active?
        
        
        if model.programs.isEmpty {
            model.notes.addDefaults()
        }
        
        for p in defaultPrograms {
            if !model.programs.contains(where: {$0.name == p.name}) {
                print("adding \(p.name) program")
                model.programs.append(p)
            }
        }
        
        if model.activeProgram.isEmpty {
            model.activeProgram = "Preview" // TODO pick something else, or even better go directly to EditPrograms
        }
        model.updateWeightsets()

        // TODO install missing weight sets for the active program
        //      also need to do this when changing the active program
        //      don't install weight sets elsewhere
        // TODO may want a warning somewhere if weight set is missing
    }

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
