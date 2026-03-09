import SwiftUI

struct CitySelectionView: View {
    let field: SelectionField
    let onSelectCity: (City) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
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
                        .foregroundStyle(colorScheme.appPrimaryText)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredCities) { city in
                                Button {
                                    onSelectCity(city)
                                } label: {
                                    HStack {
                                        Text(city.name)
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
            .navigationTitle("Выбор города")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(colorScheme.appPrimaryText)
                    }
                }
            }
        }
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
