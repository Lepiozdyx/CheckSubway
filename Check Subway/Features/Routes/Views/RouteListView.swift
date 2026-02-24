import SwiftUI

struct RouteListView: View {
    @EnvironmentObject private var store: RoutesStore
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack(spacing: 0) {
            Text("ROUTES")
                .font(.system(size: 19, weight: .bold))
                .lineSpacing(45)
                .foregroundColor(DesignSystem.Colors.pageTitle)
                .padding(.top, 16)
                .padding(.bottom, 20)

            if store.routes.isEmpty {
                EmptyStateView {
                    router.showCreation()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                        ForEach(store.routes) { route in
                            RouteCardView(route: route)
                                .onTapGesture {
                                    router.showDetail(route: route)
                                }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                }
            }

            Spacer()

            Button {
                router.showCreation()
            } label: {
                Text("+ New route")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.Spacing.buttonHeight)
                    .background(DesignSystem.Colors.accentYellow)
                    .cornerRadius(DesignSystem.Spacing.buttonCornerRadius)
            }
            .padding(.horizontal, DesignSystem.Spacing.screenHorizontal + 10)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    RouteListView()
        .environmentObject(RoutesStore())
        .environmentObject(Router())
}
