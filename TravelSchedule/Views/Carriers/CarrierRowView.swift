import SwiftUI

struct CarrierRowView: View {
    let carrier: Carrier

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("ЛОГО")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(carrier.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let transferInfo = carrier.transferInfo {
                        Text(transferInfo)
                            .font(.subheadline)
                            .foregroundStyle(.red.opacity(0.7))
                    }
                }

                Spacer()

                Text(carrier.dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(carrier.departureTime)
                    .font(.title3)

                Spacer()

                VStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 1)
                    Text(carrier.duration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 90)

                Spacer()

                Text(carrier.arrivalTime)
                    .font(.title3)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
