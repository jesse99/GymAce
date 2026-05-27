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
        
        
        if model.programs.isEmpty { // TODO only do this if DEBUG?
            model.activeProgram = "Preview"
            model.notes.addDefaults()
            addPreviewWeightSets(model) // TODO get rid of this: instead on activate insert weight sets if they are missing
            model.programs.append(previewProgram())
            model.programs.append(myProgram())
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
