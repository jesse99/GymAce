import Foundation
import SwiftUI

@main
struct GymAceApp: App {
    var model: Model

    init() {
        model = Model.load()
        
        // TODO how do we handle program updates? add something like v2 to the name?
        //      or use version and install of newer and not active? if active could say what changed
        //      or silently update if not active?
//        if let i = model.programs.firstIndex(where: {$0.name == "Masters GZCL"}) {
//            model.programs.remove(at: i)
//        }
        if model.activeProgram.isEmpty {
            model.activeProgram = "Basic Beginner"
        }
        for p in defaultPrograms {
            if !model.programs.contains(where: {$0.name == p.name}) {
                print("adding \(p.name) program")
                model.programs.append(p)
            }
        }
        
        model.addMissingWeightsets()
        model.validate()   
        
        healthKit.requestPerms()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
