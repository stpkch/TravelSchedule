import SwiftUI

struct CarrierStubView: View {
    let carrier: Carrier
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("Карточка перевозчика")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(colorScheme.appPrimaryText)

            Text(carrier.name)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppTheme.gray)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appScreenBackground(colorScheme)
        .tint(colorScheme.appPrimaryText)
        .navigationTitle("Перевозчик")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
