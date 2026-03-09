import SwiftUI

struct CarrierRowView: View {
    let carrier: Carrier
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.red.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("ЛОГО")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.red)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(carrier.name)
                        .font(.headline)
                        .foregroundStyle(colorScheme.appPrimaryText)

                    if let transferInfo = carrier.transferInfo {
                        Text(transferInfo)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.red)
                    }
                }

                Spacer()

                Text(carrier.dateText)
                    .font(.caption)
                    .foregroundStyle(AppTheme.gray)
            }

            HStack {
                Text(carrier.departureTime)
                    .font(.title3)
                    .foregroundStyle(colorScheme.appPrimaryText)

                Spacer()

                VStack(spacing: 4) {
                    Rectangle()
                        .fill(colorScheme.appDivider)
                        .frame(height: 1)

                    Text(carrier.duration)
                        .font(.caption)
                        .foregroundStyle(AppTheme.gray)
                }
                .frame(maxWidth: 90)

                Spacer()

                Text(carrier.arrivalTime)
                    .font(.title3)
                    .foregroundStyle(colorScheme.appPrimaryText)
            }
        }
        .padding(14)
        .background(colorScheme.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
