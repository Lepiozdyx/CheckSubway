import SwiftUI

struct RouteCardView: View {
    let route: Route

    var body: some View {
        ZStack(alignment: .leading) {
            Image("MaskGroup")
                .resizable()
                .scaledToFill()
                .frame(height: DesignSystem.Spacing.routeCardHeight)
                .clipped()

            Color.black.opacity(0.35)

            VStack(alignment: .leading, spacing: 66) {
                Text(route.name)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .font(.system(size: 17))
                        .foregroundColor(.white)

                    Text("\(route.totalTimeMinutes) min")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
        }
        .frame(height: DesignSystem.Spacing.routeCardHeight)
        .cornerRadius(DesignSystem.Spacing.cardCornerRadius)
        .clipped()
    }
}

#Preview {
    RouteCardView(route: Route(
        name: "Home → Work",
        walkTimeMinutes: 7,
        metroTimeMinutes: 25,
        stationNames: ["Komsomolskaya", "Krasnoselskaya", "Baumanskaya"]
    ))
    .padding()
}
