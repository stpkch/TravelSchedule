import SwiftUI

struct CitySelectionView: View {
    let field: SelectionField
    let onSelectCity: (City) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredCities: [City] {
        if searchText.isEmpty {
            return MockData.cities
        }

        return MockData.cities.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                if filteredCities.isEmpty {
                    Spacer()
                    Text("Город не найден")
                        .font(.largeTitle.weight(.bold))
                    Spacer()
                } else {
                    List(filteredCities) { city in
                        Button {
                            onSelectCity(city)
                        } label: {
                            HStack {
                                Text(city.name)
                                    .foregroundStyle(Color.primary)
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
            .navigationTitle("Выбор города")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
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
