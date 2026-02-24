import SwiftUI

struct EmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            ZStack {
                Ellipse()
                    .fill(Color.white)
                    .frame(width: 299, height: 258)
                    .blur(radius: 24.2)
                    .opacity(0.77)

                VStack(spacing: 12) {
                    Text("This section is currently empty")
                        .font(.system(size: 23))
                        .lineSpacing(27)
                        .foregroundColor(DesignSystem.Colors.subtitleGray)
                        .multilineTextAlignment(.center)

                    Button(action: onAdd) {
                        Text("+ Add the first route")
                            .font(.system(size: 23, weight: .bold))
                            .lineSpacing(27)
                            .foregroundColor(.black)
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(onAdd: {})
}
