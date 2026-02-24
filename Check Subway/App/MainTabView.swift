import SwiftUI

struct MainTabView: View {
    @StateObject private var router = Router()
    @StateObject private var routesStore = RoutesStore()
    @StateObject private var stationsStore = StationsStore()
    @StateObject private var expensesStore = ExpensesStore()
    @State private var selectedTab: Int = 0

    var body: some View {
        content
            .ignoresSafeArea(.keyboard)
            .environmentObject(router)
            .environmentObject(routesStore)
            .environmentObject(stationsStore)
            .environmentObject(expensesStore)
    }

    private var content: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                tabBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case 0:
                            RouteListView()
                        case 1:
                            StationArchiveView()
                        case 2:
                            ExpensesView()
                        default:
                            RouteListView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    tabBar
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarHidden(true)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .routeDetail(let r):
                    RouteDetailView(route: r)
                case .routeCreation:
                    RouteFormView()
                case .routeEdit(let r):
                    RouteFormView(routeToEdit: r)
                case .stationDetail(let s):
                    StationDetailView(station: s)
                case .stationCreation:
                    StationDetailView(station: nil)
                }
            }
        }
    }

    private var tabBar: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.tabBarItemSpacing) {
            tabItem(index: 0, title: "Home", icon: "TabBarHomeOff", selectedIcon: "TabBarHomeOn")
            tabItem(index: 1, title: "Station Archive", icon: "TabBarArchiveOff", selectedIcon: "TabBarArchiveOn")
            tabItem(index: 2, title: "Expenses", icon: "TabBarExpensesOff", selectedIcon: "TabBarExpensesOn")
        }
        .frame(maxWidth: .infinity)
        .frame(height: DesignSystem.Spacing.tabBarHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func tabItem(index: Int, title: String, icon: String, selectedIcon: String) -> some View {
        let isSelected = selectedTab == index
        return Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(isSelected ? selectedIcon : icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(isSelected ? DesignSystem.Colors.accentYellow : DesignSystem.Colors.tabInactive)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.tabInactive)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(height: 40)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var tabBackground: some View {
        switch selectedTab {
        case 1:
            GeometryReader { _ in
                Image("ArchiveBackground")
                    .resizable()
                    .scaledToFill()
            }
        case 2:
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.57, green: 0.57, blue: 0.57), location: 0.00),
                    Gradient.Stop(color: .white, location: 0.50),
                    Gradient.Stop(color: Color(red: 0.44, green: 0.44, blue: 0.44), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.05, y: -0.02),
                endPoint: UnitPoint(x: 0.95, y: 0.99)
            )
        default:
            GeometryReader { _ in
                Image("Background")
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

#Preview {
    MainTabView()
}
