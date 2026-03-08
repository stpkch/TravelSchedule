import SwiftUI

struct StationSelectionView: View {
    let city: City
    let field: SelectionField

    @EnvironmentObject private var viewModel: AppViewModel
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
                Spacer()
            } else {
                List(filteredStations) { station in
                    Button {
                        viewModel.selectStation(station, for: field)
                    } label: {
                        HStack {
                            Text(station.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.primary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Выбор станции")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Введите запрос", text: $searchText)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }
}
