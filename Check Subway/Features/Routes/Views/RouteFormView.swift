import SwiftUI

struct RouteFormView: View {
    @EnvironmentObject private var store: RoutesStore
    @EnvironmentObject private var router: Router

    @State private var name: String
    @State private var walkTimeText: String
    @State private var metroTimeText: String
    @State private var selectedStations: [String]
    @State private var showStationPicker = false
    @FocusState private var focusedField: FormField?

    private let editingRoute: Route?
    private var isEditing: Bool { editingRoute != nil }

    enum FormField { case name, walkTime, metroTime }

    init(routeToEdit: Route? = nil) {
        editingRoute = routeToEdit
        _name = State(initialValue: routeToEdit?.name ?? "")
        _walkTimeText = State(initialValue: routeToEdit.map { "\($0.walkTimeMinutes)" } ?? "")
        _metroTimeText = State(initialValue: routeToEdit.map { "\($0.metroTimeMinutes)" } ?? "")
        _selectedStations = State(initialValue: routeToEdit?.stationNames ?? [])
    }

    private var totalTime: Int {
        (Int(walkTimeText) ?? 0) + (Int(metroTimeText) ?? 0)
    }

    private var stationsDisplayText: String {
        selectedStations.isEmpty ? "Stations" : selectedStations.joined(separator: ", ")
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
                Text("CREATE/EDIT ROUTE")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.pageTitle)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                navyCard

                saveButton
                    .padding(.horizontal, 30)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard)
        .onTapGesture { focusedField = nil }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
            }
        }
        .sheet(isPresented: $showStationPicker) {
            StationPickerView(selectedNames: $selectedStations)
                .presentationDetents([.large])
        }
    }

    private var navyCard: some View {
        VStack(spacing: 0) {
            toolbar
                .padding(.horizontal, 20)
                .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    nameSection
                    stationsButton
                    timesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            Spacer()

            totalTimeDisplay
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.navyCard)
        .cornerRadius(DesignSystem.Spacing.navyCornerRadius)
        .padding(.horizontal, 16)
    }

    private var toolbar: some View {
        HStack {
            DetailBackButton {
                router.pop()
            }
            Spacer()
            if isEditing {
                Button {
                    if let route = editingRoute {
                        store.delete(route)
                        router.popToRoot()
                    }
                } label: {
                    ZStack {
                        Image("DeleteButton")
                            .resizable()
                            .frame(width: 37, height: 37)
                        
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .frame(width: 37, height: 37)
                }
            }
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Name:")
                .font(.system(size: 18))
                .foregroundColor(DesignSystem.Colors.inputPlaceholder)

            TextField("...", text: $name)
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .frame(height: DesignSystem.Spacing.inputHeight)
                .background(Color.white)
                .cornerRadius(DesignSystem.Spacing.statCardCornerRadius)
                .focused($focusedField, equals: .name)
        }
    }

    private var stationsButton: some View {
        Button {
            showStationPicker = true
        } label: {
            HStack {
                Text(stationsDisplayText)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.clockRed)
            }
            .padding(.horizontal, 14)
            .frame(height: DesignSystem.Spacing.inputHeight)
            .background(Color.white)
            .cornerRadius(DesignSystem.Spacing.statCardCornerRadius)
        }
    }

    private var timesSection: some View {
        HStack(spacing: 34) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Walk time")
                    .font(.system(size: 18))
                    .foregroundColor(DesignSystem.Colors.inputPlaceholder)

                TextField("...", text: $walkTimeText)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(.black)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 14)
                    .frame(width: 130, height: DesignSystem.Spacing.inputHeight)
                    .background(Color.white)
                    .cornerRadius(DesignSystem.Spacing.statCardCornerRadius)
                    .shadow(color: Color(red: 0.69, green: 0.73, blue: 0.81).opacity(0.25), radius: 6, y: 4)
                    .focused($focusedField, equals: .walkTime)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Metro time")
                    .font(.system(size: 18))
                    .foregroundColor(DesignSystem.Colors.inputPlaceholder)

                TextField("...", text: $metroTimeText)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(.black)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 14)
                    .frame(width: 130, height: DesignSystem.Spacing.inputHeight)
                    .background(Color.white)
                    .cornerRadius(DesignSystem.Spacing.statCardCornerRadius)
                    .shadow(color: Color(red: 0.69, green: 0.73, blue: 0.81).opacity(0.25), radius: 6, y: 4)
                    .focused($focusedField, equals: .metroTime)
            }
        }
    }

    private var totalTimeDisplay: some View {
        VStack(spacing: 4) {
            HStack(spacing: 7) {
                Image(systemName: "clock")
                    .font(.system(size: 18))
                    .foregroundColor(DesignSystem.Colors.clockRed)

                Text("Calculates total time")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text("\(totalTime) min")
                .font(.system(size: 27, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.backButtonTint)
        }
        .frame(width: 226, height: 94)
        .background(DesignSystem.Colors.totalTimeBg)
        .cornerRadius(DesignSystem.Spacing.stationRowCornerRadius)
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Text("Save")
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.Spacing.buttonHeight)
                .background(DesignSystem.Colors.accentYellow)
                .cornerRadius(DesignSystem.Spacing.buttonCornerRadius)
        }
    }

    private func save() {
        let walk = Int(walkTimeText) ?? 0
        let metro = Int(metroTimeText) ?? 0
        if var existing = editingRoute {
            existing.name = name
            existing.walkTimeMinutes = walk
            existing.metroTimeMinutes = metro
            existing.stationNames = selectedStations
            store.update(existing)
        } else {
            let route = Route(
                name: name,
                walkTimeMinutes: walk,
                metroTimeMinutes: metro,
                stationNames: selectedStations
            )
            store.add(route)
        }
        router.popToRoot()
    }
}

#Preview {
    RouteFormView()
        .environmentObject(RoutesStore())
        .environmentObject(Router())
}
