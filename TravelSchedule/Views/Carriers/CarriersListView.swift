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
        VStack(spacing: 8) {
            topBar
            routeTitleBlock

            if carriers.isEmpty {
                Spacer()

                Text("Вариантов нет")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(colorScheme.appPrimaryText)

                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(carriers) { carrier in
                            Button {
                                path.append(.carrierStub(carrier))
                            } label: {
                                CarrierRowView(carrier: carrier)
                                    .frame(width: AppTheme.carrierCardWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, AppTheme.carrierBottomButtonHeight + 16)
                }
            }
        }
        .appScreenBackground(colorScheme)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            if !carriers.isEmpty {
                Button {
                    path.append(.filters)
                } label: {
                    Text("Уточнить время")
                        .font(.system(size: 17, weight: .bold))
                        .tracking(0)
                        .foregroundStyle(AppTheme.whiteUniversal)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.carrierBottomButtonHeight)
                        .background(AppTheme.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(colorScheme.appBackground)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                if !path.isEmpty {
                    path.removeLast()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(colorScheme.appPrimaryText)
                    .frame(width: 17, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .frame(height: 42)
    }

    private var routeTitleBlock: some View {
        Text(viewModel.routeTitle)
            .font(.system(size: 24, weight: .bold))
            .tracking(0)
            .foregroundStyle(colorScheme.appPrimaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 87, alignment: .topLeading)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
    }
}
