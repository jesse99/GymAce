import SwiftUI

/// Typically used to show a help sheet within editors.
struct InfoView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.body)
            .multilineTextAlignment(.leading)
            .textSelection(.enabled)
            //.padding()
    }
}

#Preview {
    InfoView(text:
"""
      Twas brillig, and the slithy toves
            Did gyre and gimble in the wabe:
      All mimsy were the borogoves,
            And the mome raths outgrabe.

      Beware the Jabberwock, my son!
            The jaws that bite, the claws that catch!
      Beware the Jubjub bird, and shun
            The frumious Bandersnatch!
"""
    )
}
