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
        
        healthKit.requestPerms()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
