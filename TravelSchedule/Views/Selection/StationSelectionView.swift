import SwiftUI

struct StationSelectionView: View {
    let city: City
    let field: SelectionField

    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""

    private var filteredStations: [Station] {
        if searchText.isEmpty {
            return city.stations
        }

        return city.stations.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if filteredStations.isEmpty {
                Spacer()
                Text("Станция не найдена")
                    .font(.title.weight(.bold))
                    .foregroundStyle(colorScheme.appPrimaryText)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredStations) { station in
                            Button {
                                viewModel.selectStation(station, for: field)
                                dismiss()
                            } label: {
                                HStack {
                                    Text(station.name)
                                        .foregroundStyle(colorScheme.appPrimaryText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(colorScheme.appPrimaryText)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 56)
                            }
                            .buttonStyle(.plain)

                            Rectangle()
                                .fill(colorScheme.appDivider)
                                .frame(height: 0.5)
                                .padding(.leading, 16)
                        }
                    }
                }
            }
        }
        .appScreenBackground(colorScheme)
        .tint(colorScheme.appPrimaryText)
        .navigationTitle("Выбор станции")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.gray)

            TextField("Введите запрос", text: $searchText)
                .foregroundStyle(colorScheme.appPrimaryText)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(colorScheme.appFieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }
}
