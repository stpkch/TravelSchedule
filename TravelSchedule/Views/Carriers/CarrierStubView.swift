import SwiftUI

struct CarrierStubView: View {
    let carrier: Carrier

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("Карточка перевозчика")
                .font(.title.weight(.bold))

            Text(carrier.name)
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Перевозчик")
        .navigationBarTitleDisplayMode(.inline)
    }
}
