import SwiftUI

struct CarrierRowView: View {
    let carrier: Carrier
    @Environment(\.colorScheme) private var colorScheme

    private var cardHeight: CGFloat {
        carrier.transferInfo == nil
            ? AppTheme.carrierCompactCardHeight
            : AppTheme.carrierCardHeight
    }

    private var contentSpacing: CGFloat {
        carrier.transferInfo == nil ? 4 : 10
    }

    var body: some View {
        VStack(spacing: contentSpacing) {
            topBlock
            bottomBlock
        }
        .padding(.top, 14)
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(colorScheme.appCardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: AppTheme.carrierCardCornerRadius)
        )
    }

    private var topBlock: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(carrier.logoAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text(carrier.name)
                    .font(.system(size: 17, weight: .regular))
                    .tracking(-0.41)
                    .foregroundStyle(colorScheme.appPrimaryText)
                    .lineLimit(1)

                if let transferInfo = carrier.transferInfo {
                    Text(transferInfo)
                        .font(.system(size: 12, weight: .regular))
                        .tracking(0.4)
                        .foregroundStyle(AppTheme.red)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(carrier.dateText)
                .font(.system(size: 12, weight: .regular))
                .tracking(0.4)
                .foregroundStyle(colorScheme.appPrimaryText)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(height: 38)
    }

    private var bottomBlock: some View {
        HStack(spacing: 5) {
            Text(carrier.departureTime)
                .font(.system(size: 17, weight: .regular))
                .tracking(-0.41)
                .foregroundStyle(colorScheme.appPrimaryText)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Rectangle()
                .fill(colorScheme.appDivider)
                .frame(maxWidth: .infinity)
                .frame(height: 1)

            Text(carrier.duration)
                .font(.system(size: 12, weight: .regular))
                .tracking(0.4)
                .foregroundStyle(colorScheme.appPrimaryText)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Rectangle()
                .fill(colorScheme.appDivider)
                .frame(maxWidth: .infinity)
                .frame(height: 1)

            Text(carrier.arrivalTime)
                .font(.system(size: 17, weight: .regular))
                .tracking(-0.41)
                .foregroundStyle(colorScheme.appPrimaryText)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(height: 20)
    }
}
