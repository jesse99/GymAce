import SwiftUI

struct ContentView: View {
    @Bindable var model: Model
   
    var body: some View {
        ProgramView(model: model)
    }
}

#Preview {
    ContentView(model: previewModel())
}

#Preview("No Programs") {
    ContentView(model: Model())
}
