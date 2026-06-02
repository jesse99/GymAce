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
        
        // Defaults always get added because we always want the most up to date version.
        model.notes.addDefaults()
        
        for p in defaultPrograms {
            if !model.programs.contains(where: {$0.name == p.name}) {
                print("adding \(p.name) program")
                model.programs.append(p)
            }
        }
        
        if model.activeProgram.isEmpty {
            model.activeProgram = "Preview" // TODO pick something else, or even better go directly to EditPrograms
        }
        model.addMissingWeightsets()
        // TODO may want a warning somewhere if weight set is missing
        
        healthKit.requestPerms()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
