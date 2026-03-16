import SwiftUI

struct FilterView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Время отправления")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(colorScheme.appPrimaryText)

                checkboxRow("Утро 06:00 - 12:00", isOn: $viewModel.isMorning)
                checkboxRow("День 12:00 - 18:00", isOn: $viewModel.isDay)
                checkboxRow("Вечер 18:00 - 00:00", isOn: $viewModel.isEvening)
                checkboxRow("Ночь 00:00 - 06:00", isOn: $viewModel.isNight)
            }

            VStack(alignment: .leading, spacing: 18) {
                Text("Показывать варианты с пересадками")
                    .font(.title.weight(.bold))
                    .foregroundStyle(colorScheme.appPrimaryText)

                radioRow("Да", selected: viewModel.showTransfers) {
                    viewModel.showTransfers = true
                }

                radioRow("Нет", selected: !viewModel.showTransfers) {
                    viewModel.showTransfers = false
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Применить")
                    .font(.headline)
                    .foregroundStyle(AppTheme.whiteUniversal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(AppTheme.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(16)
        .appScreenBackground(colorScheme)
        .tint(colorScheme.appPrimaryText)
        .toolbar(.hidden, for: .tabBar)
    }

    private func checkboxRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(colorScheme.appPrimaryText)

                Spacer()

                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundStyle(colorScheme.appPrimaryText)
            }
        }
        .buttonStyle(.plain)
    }

    private func radioRow(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(colorScheme.appPrimaryText)

                Spacer()

                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .font(.title2)
                    .foregroundStyle(colorScheme.appPrimaryText)
            }
        }
        .buttonStyle(.plain)
    }
}
