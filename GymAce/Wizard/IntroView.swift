import SwiftUI

struct IntroView: View {
    @Bindable var wizard: Wizard
    
    var body: some View {
        VStack {
            Text("In this context a program consists of one or more workouts each of which contains exercises to perform. Most programs also have some sort of progression built in, for example if you're able to hit all the requested reps the program may automatically increase the weight. Some programs will also automatically drop weights if you're stuck for too long.\n\nNote that you can create programs from scratch using Edit Programs. You can also fully edit programs using Edit Exercises, Edit Program, etc.")
                .font(.body)
                .padding(.leading, 20)
                .padding(.trailing, 20)
        }
    }
}

#Preview {
    let model = previewModel()
    let wizard = Wizard(model)
    NavigationView {
        IntroView(wizard: wizard)
    }
}
