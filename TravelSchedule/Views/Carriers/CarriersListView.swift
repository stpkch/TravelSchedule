import SwiftUI

struct CarriersListView: View {
    @EnvironmentObject private var viewModel: AppViewModel
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            if carriers.isEmpty {
                Spacer()
                Text("Вариантов нет")
                    .font(.title2.weight(.semibold))
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(carriers) { carrier in
                            Button {
                                path.append(.carrierStub(carrier))
                            } label: {
                                CarrierRowView(carrier: carrier)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                path.append(.filters)
            } label: {
                Text("Уточнить время")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }
            .background(.ultraThinMaterial)
        }
    }
}
