import SwiftUI

// TODO
// save the model (but not the preview program)
//    https://www.swiftjectivec.com/stupid-and-quick-persistency-on-ios-with-swift/
// load the model (add preview, if debug?)
// views should use Bindable for model objects
@main
struct GymAceApp: App {
    var model: Model
    
    init() {
        model = Model.load()
        if model.programs.isEmpty {
            model = previewModel()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
