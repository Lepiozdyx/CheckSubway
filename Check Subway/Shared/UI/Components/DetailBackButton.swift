import SwiftUI

struct DetailBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17))
                Text("Back")
                    .font(.system(size: 17))
            }
            .foregroundColor(DesignSystem.Colors.backButtonTint)
        }
    }
}
