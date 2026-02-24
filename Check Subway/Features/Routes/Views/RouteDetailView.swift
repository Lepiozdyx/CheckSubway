import SwiftUI

struct RouteDetailView: View {
    @EnvironmentObject private var store: RoutesStore
    @EnvironmentObject private var stationsStore: StationsStore
    @EnvironmentObject private var router: Router
    let route: Route

    private var liveRoute: Route {
        store.route(byId: route.id) ?? route
    }

    var body: some View {
        ZStack {
            GeometryReader { _ in
                Image("Background")
                    .resizable()
                    .scaledToFill()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("ROUTE")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.pageTitle)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                navyCard
            }
        }
        .navigationBarHidden(true)
    }

    private var navyCard: some View {
        VStack(spacing: 0) {
            toolbar
                .padding(.horizontal, 20)
                .padding(.top, 16)

            routeNameRow
                .padding(.horizontal, 20)
                .padding(.top, 12)

            statsRow
                .padding(.top, 14)

            stationsList
                .padding(.horizontal, 20)
                .padding(.top, 18)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.navyCard)
        .cornerRadius(DesignSystem.Spacing.navyCornerRadius)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var toolbar: some View {
        HStack {
            DetailBackButton {
                router.pop()
            }
            Spacer()
            Button {
                store.delete(liveRoute)
                router.pop()
            } label: {
                ZStack {
                    Image("DeleteButton")
                        .resizable()
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "trash.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .frame(width: 44, height: 44)
            }
        }
    }

    private var routeNameRow: some View {
        HStack {
            Text(liveRoute.name)
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            Button {
                router.showRouteEdit(route: liveRoute)
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.clockRed)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(DesignSystem.Spacing.statCardCornerRadius)
    }

    private var statsRow: some View {
        HStack(spacing: 11) {
            statCardArrow(arrow: "→", value: "\(liveRoute.walkTimeMinutes)", label: "Walk time",
                          arrowColor: Color(red: 0.33, green: 0.14, blue: 0.14))
            statCardArrow(arrow: "↑", value: "\(liveRoute.metroTimeMinutes)", label: "Metro time",
                          arrowColor: DesignSystem.Colors.clockRed)
            statCardIcon(icon: "clock", value: "\(liveRoute.totalTimeMinutes)", label: "Total time",
                         iconColor: DesignSystem.Colors.clockRed)
        }
        .padding(.horizontal, 12) // Increased from 10
    }

    private func statCardArrow(arrow: String, value: String, label: String, arrowColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 17) {
            Text(arrow)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(arrowColor)
                .frame(width: 32, height: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 8) {
                Text("\(value) min")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)

                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(.black.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: DesignSystem.Spacing.statCardHeight)
        .padding(.leading, 12)
        .padding(.top, 16)
        .background(DesignSystem.Colors.statCardBg)
        .cornerRadius(DesignSystem.Spacing.statCardCornerRadius)
    }

    private func statCardIcon(icon: String, value: String, label: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 17) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(iconColor)

            VStack(alignment: .leading, spacing: 8) {
                Text("\(value) min")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)

                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(.black.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: DesignSystem.Spacing.statCardHeight)
        .padding(.leading, 12)
        .padding(.top, 16)
        .background(DesignSystem.Colors.statCardBg)
        .cornerRadius(DesignSystem.Spacing.statCardCornerRadius)
    }

    private var stationsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(liveRoute.stationNames.enumerated()), id: \.offset) { index, name in
                    HStack(spacing: 0) {
                        stationDot(isFirst: index == 0, isLast: index == liveRoute.stationNames.count - 1)
                            .frame(width: 30)

                        stationRow(name: name)
                            .onTapGesture {
                                if let station = stationsStore.station(byName: name) {
                                    router.showStationDetail(station: station)
                                }
                            }
                    }
                }
            }
        }
    }

    private func stationDot(isFirst: Bool, isLast: Bool) -> some View {
        GeometryReader { geo in
            let midY = geo.size.height / 2

            Path { path in
                if !isFirst {
                    path.move(to: CGPoint(x: 15, y: 0))
                    path.addLine(to: CGPoint(x: 15, y: midY - 8))
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            .foregroundColor(.white)

            Circle()
                .fill(DesignSystem.Colors.accentYellow)
                .frame(width: 13, height: 13)
                .position(x: 15, y: midY)

            Circle()
                .strokeBorder(DesignSystem.Colors.accentYellow, lineWidth: 1.5)
                .frame(width: 26, height: 26)
                .position(x: 15, y: midY)

            Path { path in
                if !isLast {
                    path.move(to: CGPoint(x: 15, y: midY + 8))
                    path.addLine(to: CGPoint(x: 15, y: geo.size.height))
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            .foregroundColor(.white)
        }
    }

    private func stationRow(name: String) -> some View {
        HStack(spacing: 7) {
            Text(name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "clock")
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.clockRed)

            Text("\(Int.random(in: 2...10)) min")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .frame(height: 57)
        .background(DesignSystem.Colors.stationRowBg)
        .cornerRadius(DesignSystem.Spacing.stationRowCornerRadius)
        .padding(.vertical, 5)
    }
}

#Preview {
    RouteDetailView(route: Route(
        name: "Home → Work",
        walkTimeMinutes: 7,
        metroTimeMinutes: 25,
        stationNames: ["Komsomolskaya", "Krasnoselskaya", "Baumanskaya"]
    ))
    .environmentObject(RoutesStore())
    .environmentObject(Router())
}
