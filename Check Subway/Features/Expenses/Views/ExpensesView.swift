import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject private var expensesStore: ExpensesStore

    @State private var selectedMonth: Int
    @State private var selectedYear: Int
    @State private var showMonthPicker = false

    private let barColors: [Color] = [
        Color(red: 1.0, green: 0.80, blue: 0.0),
        Color(red: 1.0, green: 0.93, blue: 0.51),
        Color(red: 0.33, green: 0.14, blue: 0.14),
        Color(red: 0.28, green: 0.28, blue: 0.28)
    ]

    init() {
        let now = Calendar.current.dateComponents([.year, .month], from: Date())
        _selectedMonth = State(initialValue: now.month ?? 1)
        _selectedYear = State(initialValue: now.year ?? 2025)
    }

    private var monthExpenses: [MonthlyExpense] {
        expensesStore.expensesForMonth(selectedMonth, year: selectedYear)
    }

    private var monthTotal: Int {
        expensesStore.totalForMonth(selectedMonth, year: selectedYear)
    }

    private var selectedMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = 1
        guard let date = Calendar.current.date(from: comps) else { return "" }
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
                .padding(.top, 8)

            if !monthExpenses.isEmpty {
                Text(selectedMonthString)
                    .font(.system(size: 17, weight: .heavy))
                    .tracking(0.2)
                    .foregroundColor(DesignSystem.Colors.navyCard)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                    .padding(.top, 4)
            }

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(monthExpenses.enumerated()), id: \.element.id) { index, expense in
                        ExpenseCardView(
                            expense: expense,
                            isFirst: index == 0,
                            onSave: { updated in expensesStore.update(updated) },
                            onDelete: { expensesStore.delete(expense) }
                        )
                    }

                    greenPlusButton
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    if monthExpenses.isEmpty {
                        emptyState
                    }

                    if !monthExpenses.isEmpty {
                        weeklyChart
                    }

                    weekLabels
                }
                .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                .padding(.bottom, 12)
            }
            .scrollDismissesKeyboard(.immediately)

            totalCard
                .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                .padding(.bottom, 16)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .overlay {
            if showMonthPicker {
                monthPickerOverlay
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
            }
        }
    }

    private var headerBar: some View {
        ZStack {
            Text("EXPENSES")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(DesignSystem.Colors.pageTitle)

            HStack {
                Spacer()
                Button { showMonthPicker = true } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundColor(showMonthPicker ? DesignSystem.Colors.backButtonTint : DesignSystem.Colors.navyCard)
                        .frame(width: 44, height: 44)
                        .background(
                            Image("CalendarButton")
                                .resizable()
                                .frame(width: 44, height: 44)
                        )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
        }
    }


    private var greenPlusButton: some View {
        Button {
            let newExpense = MonthlyExpense(month: selectedMonth, year: selectedYear)
            expensesStore.add(newExpense)
        } label: {
            Text("+")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 44, height: 40)
                .background(Color(red: 0.56, green: 1, blue: 0.57))
                .cornerRadius(8)
        }
    }


    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 40)
            ZStack {
                Ellipse()
                    .fill(Color.white)
                    .frame(width: 299, height: 258)
                    .blur(radius: 24.2)
                    .opacity(0.77)

                Text("This section is currently empty")
                    .font(.system(size: 23))
                    .foregroundColor(DesignSystem.Colors.subtitleGray)
                    .multilineTextAlignment(.center)
            }
            Spacer().frame(height: 40)
        }
    }


    private var weeklyChart: some View {
        VStack(spacing: 8) {
            Text(selectedMonthString)
                .font(.system(size: 17, weight: .bold))
                .tracking(0.2)
                .foregroundColor(DesignSystem.Colors.navyCard)
                .frame(maxWidth: .infinity, alignment: .leading)

            chartBars
        }
        .padding(.top, 12)
    }

    private var chartBars: some View {
        let weeklyTotals = aggregatedWeeklyTotals
        let maxVal = max(weeklyTotals.max() ?? 1, 1)
        let maxHeight: CGFloat = 150

        return HStack(alignment: .bottom, spacing: 12) {
            ForEach(0..<4, id: \.self) { i in
                let val = weeklyTotals[i]
                let barH = maxVal > 0 ? CGFloat(val) / CGFloat(maxVal) * maxHeight : 0

                VStack(spacing: 4) {
                    Text("\(val)$")
                        .font(.system(size: 22))
                        .foregroundColor(DesignSystem.Colors.pageTitle)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(barColors[i])
                        .frame(width: 65, height: max(barH, 8))

                    Text("\(i + 1) week")
                        .font(.system(size: 16))
                        .foregroundColor(DesignSystem.Colors.pageTitle)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var aggregatedWeeklyTotals: [Int] {
        var weeks = [0, 0, 0, 0]
        for expense in monthExpenses {
            let breakdown = expense.weeklyBreakdown
            for i in 0..<4 { weeks[i] += breakdown[i] }
        }
        return weeks
    }


    private var weekLabels: some View {
        Group {
            if monthExpenses.isEmpty {
                HStack(spacing: 26) {
                    ForEach(1...4, id: \.self) { w in
                        Text("\(w) week")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.pageTitle)
                            .opacity(0.5)
                    }
                }
                .padding(.top, 8)
            }
        }
    }


    private var totalCard: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.system(size: 22))
                    .foregroundColor(DesignSystem.Colors.backButtonTint)
                Text("Total amount")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.backButtonTint)
            }
            Spacer()
            Text("\(monthTotal)$")
                .font(.system(size: 36))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 25)
        .frame(height: 80)
        .background(DesignSystem.Colors.navyCard)
        .cornerRadius(DesignSystem.Spacing.navyCornerRadius)
    }


    private var monthPickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { showMonthPicker = false }

            VStack(spacing: 16) {
                Text("Select a Month")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.white)
                    .cornerRadius(12)

                HStack(spacing: 32) {
                    Button {
                        decrementMonth()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.navyCard)
                            .frame(width: 25, height: 24)
                            .background(DesignSystem.Colors.backButtonTint)
                            .cornerRadius(3)
                    }

                    Text(selectedMonthString)
                        .font(.system(size: 17, weight: .semibold))
                        .tracking(0.2)
                        .foregroundColor(.white)

                    Button {
                        incrementMonth()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.navyCard)
                            .frame(width: 25, height: 24)
                            .background(DesignSystem.Colors.backButtonTint)
                            .cornerRadius(3)
                    }
                }
                .padding(13)
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .background(DesignSystem.Colors.navyCard)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 0.25)
                        .stroke(DesignSystem.Colors.accentYellow, lineWidth: 0.25)
                )

                Button {
                    showMonthPicker = false
                } label: {
                    Text("Ok")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.pageTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(DesignSystem.Colors.accentYellow)
                        .cornerRadius(12)
                }
            }
            .padding(20)
            .background(.white)
            .cornerRadius(DesignSystem.Spacing.navyCornerRadius)
            .padding(.horizontal, 12)
        }
    }

    private func decrementMonth() {
        if selectedMonth == 1 {
            selectedMonth = 12
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
    }

    private func incrementMonth() {
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
    }
}


struct ExpenseCardView: View {
    let expense: MonthlyExpense
    let isFirst: Bool
    let onSave: (MonthlyExpense) -> Void
    let onDelete: () -> Void

    @State private var passCost: String
    @State private var ridesUsed: String
    @State private var totalRides: String
    @State private var singleTicketPrice: String

    enum Field: Hashable {
        case pass, used, price, remaining
    }
    @FocusState private var focusedField: Field?
    @State private var dragOffset: CGFloat = 0

    init(expense: MonthlyExpense, isFirst: Bool,
         onSave: @escaping (MonthlyExpense) -> Void,
         onDelete: @escaping () -> Void) {
        self.expense = expense
        self.isFirst = isFirst
        self.onSave = onSave
        self.onDelete = onDelete
        _passCost = State(initialValue: expense.passCost)
        _ridesUsed = State(initialValue: expense.ridesUsed)
        _totalRides = State(initialValue: expense.totalRides)
        _singleTicketPrice = State(initialValue: expense.singleTicketPrice)
    }

    private var remaining: Int {
        max(0, (Int(totalRides) ?? 0) - (Int(ridesUsed) ?? 0))
    }

    private var total: Int {
        let pass = Int(passCost) ?? 0
        let used = Int(ridesUsed) ?? 0
        let price = Int(singleTicketPrice) ?? 0
        return pass + (used * price)
    }

    private var avgPerWeek: Int {
        total > 0 ? total / 4 : 0
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                Spacer()
                Button {
                    withAnimation { onDelete() }
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
                .frame(width: 82)
                .frame(maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
            .background(DesignSystem.Colors.clockRed)
            .cornerRadius(DesignSystem.Spacing.navyCornerRadius)

            cardContent
                .offset(x: dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 30, coordinateSpace: .local)
                        .onChanged { value in
                            if value.translation.width < 0 {
                                dragOffset = max(value.translation.width, -82)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3)) {
                                dragOffset = value.translation.width < -40 ? -82 : 0
                            }
                        }
                )
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            if isFirst {
                HStack(alignment: .bottom, spacing: 8) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 20))
                        .foregroundColor(DesignSystem.Colors.clockRed)
                        .frame(width: 24, height: 24)
                    Text("Expenses")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.backButtonTint)
                }
                .padding(.bottom, 2)
            }

            editableFieldRow(label: "Pass", text: $passCost, field: .pass,
                             labelColor: .white.opacity(0.5), labelWeight: .medium)
            editableFieldRow(label: "Rides used", text: $ridesUsed, field: .used,
                             labelColor: DesignSystem.Colors.inputPlaceholder.opacity(0.5))
            editableFieldRow(label: "Single tickets", text: $singleTicketPrice, field: .price,
                             labelColor: DesignSystem.Colors.inputPlaceholder.opacity(0.5))

            let remainingBinding = Binding<String>(
                get: { "\(remaining)" },
                set: { newVal in
                    if let newRemaining = Int(newVal), let used = Int(ridesUsed) {
                        totalRides = "\(used + newRemaining)"
                    } else if let newRemaining = Int(newVal) {
                        totalRides = "\(newRemaining)"
                    }
                }
            )

            editableFieldRow(label: "Remaining", text: remainingBinding, field: .remaining,
                             labelColor: DesignSystem.Colors.inputPlaceholder.opacity(0.5))

            averageRow
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Colors.navyCard)
        .cornerRadius(DesignSystem.Spacing.navyCornerRadius)
    }

    private func editableFieldRow(label: String, text: Binding<String>, field: Field,
                                   labelColor: Color, labelWeight: Font.Weight = .regular) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 20, weight: labelWeight))
                .foregroundColor(labelColor)
                .frame(width: 120, alignment: .leading)

            HStack {
                Spacer()
                ZStack(alignment: .trailing) {
                    if text.wrappedValue.isEmpty && focusedField != field {
                        Text("...")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(.black.opacity(0.3))
                    }

                    if focusedField != field && !text.wrappedValue.isEmpty {
                        Text(formattedValue(for: field, rawValue: text.wrappedValue))
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }

                    TextField("", text: text)
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(focusedField == field ? .black : .clear)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: field)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(Capsule())
        }
    }

    private func formattedValue(for field: Field, rawValue: String) -> String {
        if rawValue.isEmpty { return "..." }
        switch field {
        case .pass:
            return "\(rawValue)$"
        case .used:
            return "\(rawValue) out of \(totalRides) times"
        case .price:
            return "\(rawValue)$"
        case .remaining:
            return "\(rawValue) trips"
        }
    }

    private var averageRow: some View {
        HStack(spacing: 12) {
            Text("Average spending")
                .font(.system(size: 20))
                .foregroundColor(DesignSystem.Colors.inputPlaceholder.opacity(0.5))
                .frame(width: 120, alignment: .leading)

            HStack {
                Spacer()
                Text(avgPerWeek > 0 ? "\(avgPerWeek)$/week" : "...")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 16)
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(Capsule())

            Button {
                save()
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 40)
                    .background(DesignSystem.Colors.accentYellow)
                    .cornerRadius(7)
            }
        }
    }

    private func save() {
        var updated = expense
        updated.passCost = passCost
        updated.ridesUsed = ridesUsed
        updated.totalRides = totalRides
        updated.singleTicketPrice = singleTicketPrice
        onSave(updated)
    }
}

#Preview {
    ExpensesView()
        .environmentObject(ExpensesStore())
}
