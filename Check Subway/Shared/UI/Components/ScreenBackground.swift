import SwiftUI

struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            GeometryReader { _ in
                Image("Background")
                    .resizable()
                    .scaledToFill()
            }
            .ignoresSafeArea()

            content
        }
    }
}

extension View {
    func screenBackground() -> some View {
        modifier(ScreenBackground())
    }
}
