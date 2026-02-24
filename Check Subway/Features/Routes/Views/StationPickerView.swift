import SwiftUI

struct StationPickerView: View {
    @Binding var selectedNames: [String]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var stationsStore: StationsStore

    var body: some View {
        VStack(spacing: 0) {
            handleBar
                .padding(.top, 8)
                .padding(.bottom, 12)

            header
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            ScrollView {
                LazyVStack(spacing: 0) {
                    let stationNames = Array(Set(stationsStore.stations.map(\.name))).sorted()
                    if stationNames.isEmpty {
                        Text("No stations available. Add some in the Archive first.")
                            .font(.system(size: 15))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            .padding(.top, 40)
                    } else {
                        ForEach(stationNames, id: \.self) { name in
                            stationRow(name: name)
                        }
                    }
                }
            }
        }
        .background(.white)
    }

    private var handleBar: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color(red: 0.16, green: 0.16, blue: 0.29))
            .frame(width: 167, height: 4)
    }

    private var header: some View {
        HStack {
            Text("Stations")
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 1, green: 0.22, blue: 0.24))
                .onTapGesture { dismiss() }
        }
    }

    private func stationRow(name: String) -> some View {
        let isSelected = selectedNames.contains(name)
        return Button {
            if isSelected {
                selectedNames.removeAll { $0 == name }
            } else {
                selectedNames.append(name)
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.20, green: 0.78, blue: 0.35))
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .strokeBorder(Color(red: 0.78, green: 0.78, blue: 0.78), lineWidth: 1.5)
                            .frame(width: 24, height: 24)
                    }
                }

                Text(name)
                    .font(.system(size: 17))
                    .foregroundColor(Color(red: 0.19, green: 0.19, blue: 0.19))

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color(red: 1, green: 0.22, blue: 0.24).opacity(0.5))
                    .frame(height: 0.5)
                    .padding(.leading, 56)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StationPickerView(selectedNames: .constant(["Komsomolskaya"]))
        .environmentObject(StationsStore())
}
