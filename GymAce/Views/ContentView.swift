import SwiftUI

struct NoProgramView: View {
    var body: some View {
        // TODO make sure these instructions are still correct
        ContentUnavailableView("Use the Programs tab at the bottom of the screen to add a new program.", systemImage: "figure.run.square.stack.fill")
        .padding()
    }
}

struct ContentView: View {
    @Bindable var model: Model
    var today: Date = Date()        // used for custom previews
   
    var body: some View {
        Group {
            if !model.programs.isEmpty {
                ProgramView(model: model)
            } else {
                NoProgramView()
            }
        }
    }
}

#Preview {
    ContentView(model: previewModel())
}

//#Preview("No Programs") {
//    ContentView()
//        .modelContainer(NoPreviewData.shared.modelContainer)
//}
//
//#Preview("Dates") {
//    ScrollView {
//        ContentView(today: Calendar.current.date(byAdding: .day, value: 0, to: Date.now)!)
//            .modelContainer(PreviewData.shared.container)
//        ContentView(today: Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!)
//            .modelContainer(PreviewData.shared.container)
//        ContentView(today: Calendar.current.date(byAdding: .day, value: 2, to: Date.now)!)
//            .modelContainer(PreviewData.shared.container)
//        ContentView(today: Calendar.current.date(byAdding: .day, value: 3, to: Date.now)!)
//            .modelContainer(PreviewData.shared.container)
//        ContentView(today: Calendar.current.date(byAdding: .day, value: 4, to: Date.now)!)
//            .modelContainer(PreviewData.shared.container)
//    }
//}
