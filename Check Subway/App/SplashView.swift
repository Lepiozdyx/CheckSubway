import SwiftUI

struct SplashView: View {
    let onComplete: () -> Void

    @State private var progress: CGFloat = 0.0

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.57, green: 0.57, blue: 0.57), location: 0.00),
                    Gradient.Stop(color: .white, location: 0.50),
                    Gradient.Stop(color: Color(red: 0.44, green: 0.44, blue: 0.44), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.05, y: -0.02),
                endPoint: UnitPoint(x: 0.95, y: 0.99)
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                Image("LogoLoading")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)

                Spacer()

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 27)
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 204.5, height: 10)

                    RoundedRectangle(cornerRadius: 27)
                        .fill(DesignSystem.Colors.clockRed)
                        .frame(width: 59 + (145.5 * progress), height: 10)
                }
                .padding(.bottom, 100)
            }
        }
        .task {
            withAnimation(.linear(duration: 2.0)) {
                progress = 1.0
            }
            onComplete()
        }
    }
}

#Preview {
    SplashView(onComplete: {})
}
