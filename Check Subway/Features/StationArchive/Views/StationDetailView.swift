import SwiftUI
import PhotosUI

struct StationDetailView: View {
    @EnvironmentObject private var stationsStore: StationsStore
    @EnvironmentObject private var router: Router

    private let existingStation: ArchivedStation?
    private var isEditing: Bool { existingStation != nil }

    @State private var name: String
    @State private var notes: String
    @State private var rating: Int
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @FocusState private var focusedField: FormField?

    enum FormField { case name, notes }

    init(station: ArchivedStation?) {
        existingStation = station
        _name = State(initialValue: station?.name ?? "")
        _notes = State(initialValue: station?.notes ?? "")
        _rating = State(initialValue: station?.rating ?? 0)
        _photoData = State(initialValue: station?.photoData)
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
                Text("ADD STATION")
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
        .onChange(of: selectedPhoto) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }


    private var navyCard: some View {
        VStack(spacing: 0) {
            toolbar
                .padding(.horizontal, 20)
                .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    nameSection
                    photoSection
                    notesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }

            Spacer()

            starsRow
                .padding(.bottom, 20)
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
                    if let station = existingStation {
                        stationsStore.delete(station)
                        router.pop()
                    }
                } label: {
                    ZStack {
                        Image("DeleteButton")
                            .resizable()
                            .frame(width: 37, height: 37)
                        
                        Image(systemName: "trash")
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
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DesignSystem.Colors.halfWhite)

            TextField("...", text: $name)
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .frame(height: 55)
                .background(.white)
                .cornerRadius(DesignSystem.Spacing.cardCornerRadius)
                .focused($focusedField, equals: .name)
        }
    }


    private var photoSection: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            ZStack {
                if let data = photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 155)
                        .clipped()
                        .cornerRadius(DesignSystem.Spacing.cardCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Spacing.cardCornerRadius)
                                .inset(by: 1)
                                .stroke(DesignSystem.Colors.backButtonTint, lineWidth: 1)
                        )
                        .overlay {
                            VStack(spacing: 1) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 26.56))
                                    .foregroundColor(.white.opacity(0.5))
                                Text("Upload a new photo")
                                    .font(.system(size: 17))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                } else {
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.cardCornerRadius)
                        .fill(Color(red: 0.87, green: 0.87, blue: 0.87))
                        .frame(height: 155)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Spacing.cardCornerRadius)
                                .inset(by: 1)
                                .stroke(DesignSystem.Colors.backButtonTint, lineWidth: 1)
                        )
                        .overlay {
                            VStack(spacing: 1) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 26.56))
                                    .foregroundColor(Color(red: 0.38, green: 0.31, blue: 0.31))
                                Text("Upload a new photo")
                                    .font(.system(size: 17))
                                    .foregroundColor(.black.opacity(0.5))
                            }
                        }
                }
            }
        }
        .buttonStyle(.plain)
    }


    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Notes")
                .font(.system(size: 15))
                .foregroundColor(DesignSystem.Colors.halfWhite)

            TextEditor(text: $notes)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .frame(height: 94)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(.white)
                .cornerRadius(DesignSystem.Spacing.stationRowCornerRadius)
                .scrollContentBackground(.hidden)
                .focused($focusedField, equals: .notes)
        }
    }


    private var starsRow: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: 28))
                    .foregroundColor(DesignSystem.Colors.accentYellow)
                    .onTapGesture {
                        rating = star
                    }
            }
        }
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
        if let existing = existingStation,
           let current = stationsStore.station(byId: existing.id) {
            var updated = current
            updated.name = name
            updated.notes = notes
            updated.rating = rating
            updated.photoData = photoData
            stationsStore.update(updated)
        } else {
            let station = ArchivedStation(
                name: name,
                rating: rating,
                notes: notes,
                photoData: photoData
            )
            stationsStore.add(station)
        }
        router.pop()
    }
}

#Preview("Empty") {
    StationDetailView(station: nil)
        .environmentObject(StationsStore())
        .environmentObject(Router())
}

#Preview("Filled") {
    StationDetailView(station: ArchivedStation(
        name: "Komsomolskaya",
        lineColorHex: "FFDC04",
        rating: 4,
        notes: "Best exit is No.3\nthere's a coffee shop nearby"
    ))
    .environmentObject(StationsStore())
    .environmentObject(Router())
}
