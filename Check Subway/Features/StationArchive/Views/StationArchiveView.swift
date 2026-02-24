import SwiftUI

enum StationSortOrder {
    case ratingDescending
    case ratingAscending
}

struct StationArchiveView: View {
    @EnvironmentObject private var stationsStore: StationsStore
    @EnvironmentObject private var router: Router
    @State private var onlyWithNotes = false
    @State private var sortOrder: StationSortOrder = .ratingDescending

    private var filteredStations: [ArchivedStation] {
        var result = stationsStore.stations
        if onlyWithNotes {
            result = result.filter { !$0.notes.isEmpty }
        }
        switch sortOrder {
        case .ratingDescending:
            result.sort { $0.rating > $1.rating }
        case .ratingAscending:
            result.sort { $0.rating < $1.rating }
        }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("STATION ARCHIVE")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(DesignSystem.Colors.pageTitle)
                .padding(.top, 16)
                .padding(.bottom, 12)

            filterBar
                .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                .padding(.bottom, 16)

            if stationsStore.stations.isEmpty {
                emptyState
            } else if filteredStations.isEmpty {
                filteredEmptyState
            } else {
                stationsList
            }

            Spacer()

            addButton
                .padding(.horizontal, 30)
                .padding(.bottom, 16)
        }
    }


    private var filterBar: some View {
        HStack {
            Button {
                onlyWithNotes.toggle()
            } label: {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(onlyWithNotes ? DesignSystem.Colors.clockRed : .clear)
                        .frame(width: 25, height: 25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(DesignSystem.Colors.clockRed, lineWidth: 0.75)
                        )
                        .overlay {
                            if onlyWithNotes {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

                    Text("Only with notes")
                        .font(.system(size: 15, weight: onlyWithNotes ? .bold : .regular))
                        .foregroundColor(DesignSystem.Colors.pageTitle)
                }
            }
            .contentShape(Rectangle())
            .buttonStyle(.plain)

            Spacer()

            averageStars

            sortButton
        }
    }

    private var averageStars: some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(DesignSystem.Colors.accentYellow)
            }
        }
    }

    private var sortButton: some View {
        Button {
            sortOrder = sortOrder == .ratingDescending ? .ratingAscending : .ratingDescending
        } label: {
            Image(systemName: sortOrder == .ratingDescending ? "arrow.down" : "arrow.up")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.clockRed)
                .frame(width: 25, height: 25)
        }
        .buttonStyle(.plain)
    }


    private var emptyState: some View {
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

                    Text("+ Add the first station")
                        .font(.system(size: 23, weight: .bold))
                        .lineSpacing(27)
                        .foregroundColor(.black)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var filteredEmptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Text("No stations with notes")
                .font(.system(size: 23))
                .foregroundColor(DesignSystem.Colors.subtitleGray)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }


    private var stationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredStations) { station in
                    stationCard(station)
                        .onTapGesture {
                            router.showStationDetail(station: station)
                        }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
        }
    }

    private func stationCard(_ station: ArchivedStation) -> some View {
        ZStack(alignment: .leading) {
            if let data = station.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 108)
                    .clipped()

                Color.black.opacity(0.45)
            } else {
                Color(red: 0.16, green: 0.16, blue: 0.29)
            }

            VStack(alignment: .leading, spacing: 11) {
                HStack(spacing: 7) {
                    ZStack {
                        Circle()
                            .fill(station.lineColor)
                            .frame(width: 13, height: 13)
                        Circle()
                            .strokeBorder(station.lineColor, lineWidth: 1.09)
                            .frame(width: 26, height: 26)
                    }

                    Text("\(station.name)")
                        .font(.system(size: 14.86, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= station.rating ? "star.fill" : "star")
                            .font(.system(size: 13))
                            .foregroundColor(DesignSystem.Colors.accentYellow)
                    }
                }

                if !station.notes.isEmpty {
                    let firstLine = station.notes.components(separatedBy: "\n").first ?? station.notes
                    Text("\"\(firstLine)\"")
                        .font(.system(size: 11))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .frame(height: 24)
                        .background(.white)
                        .cornerRadius(76)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(height: 108)
        .background(Color(red: 0.16, green: 0.16, blue: 0.29))
        .cornerRadius(DesignSystem.Spacing.stationRowCornerRadius)
        .clipped()
    }


    private var addButton: some View {
        Button {
            router.showStationCreation()
        } label: {
            Text("+ Add Station")
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.Spacing.buttonHeight)
                .background(DesignSystem.Colors.accentYellow)
                .cornerRadius(DesignSystem.Spacing.buttonCornerRadius)
        }
    }
}

#Preview {
    StationArchiveView()
        .environmentObject(StationsStore())
        .environmentObject(Router())
}
