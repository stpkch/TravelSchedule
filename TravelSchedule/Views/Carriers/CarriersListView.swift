import SwiftUI

struct CarriersListView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Binding var path: [AppRoute]

    private var carriers: [Carrier] {
        MockData.carriers.filter { carrier in
            let transferMatch = viewModel.showTransfers || carrier.transferInfo == nil

            let timeMatch =
                selectedRanges.isEmpty ||
                selectedRanges.contains { range in
                    range.contains(carrier.departureTime)
                }

            return transferMatch && timeMatch
        }
    }

    private var selectedRanges: [ClosedRange<String>] {
        var result: [ClosedRange<String>] = []

        if viewModel.isMorning { result.append("06:00"..."11:59") }
        if viewModel.isDay { result.append("12:00"..."17:59") }
        if viewModel.isEvening { result.append("18:00"..."23:59") }
        if viewModel.isNight { result.append("00:00"..."05:59") }

        return result
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(viewModel.routeTitle)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(colorScheme.appPrimaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            if carriers.isEmpty {
                Spacer()
                Text("Вариантов нет")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(colorScheme.appPrimaryText)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(carriers) { carrier in
                            Button {
                                path.append(.carrierStub(carrier))
                            } label: {
                                CarrierRowView(carrier: carrier)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .appScreenBackground(colorScheme)
        .tint(colorScheme.appPrimaryText)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(colorScheme.appDivider)
                    .frame(height: 0.5)

                Button {
                    path.append(.filters)
                } label: {
                    Text("Уточнить время")
                        .font(.headline)
                        .foregroundStyle(AppTheme.whiteUniversal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(AppTheme.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                }
            }
            .background(colorScheme.appBackground)
        }
    }
}
