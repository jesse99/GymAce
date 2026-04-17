import SwiftUI
import SwiftData

/// Used to set sheet height to match content size.
private struct ContentHeightSheetModifier: ViewModifier {
    @State private var contentHeight: CGFloat = .zero

    // TODO this didn't show all of the text when it had to wrap around.
    // I'm using presentationDetents now but it kind of sucks because you
    // have to hard code the height.
    private var contentHeightMeasurerView: some View {
        GeometryReader { geometry in
            Color.clear
                .onChange(of: geometry.size.height, initial: true) { _, newHeight in
                    contentHeight = newHeight
                }
        }
    }

    func body(content: Content) -> some View {
        content
            .background(contentHeightMeasurerView)
            .presentationDetents([.height(contentHeight)])
    }
}

extension View {
    func adjustSheetHeightToContent() -> some View {
        self.modifier(ContentHeightSheetModifier())
    }
}
