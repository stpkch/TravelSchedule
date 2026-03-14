import SwiftUI
import UIKit

struct CarrierStubView: View {
    let carrier: Carrier

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private let horizontalInset: CGFloat = 24
    private let logoCardCornerRadius: CGFloat = 24
    private let logoCardHeight: CGFloat = 104

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    carrierLogoCard
                        .padding(.top, 24)

                    Text(displayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(colorScheme.appPrimaryText)
                        .padding(.top, 24)

                    infoBlock(title: "E-mail", value: "-")
                        .padding(.top, 24)

                    infoBlock(title: "Телефон", value: "-")
                        .padding(.top, 24)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, horizontalInset)
                .padding(.bottom, 24)
            }
        }
        .appScreenBackground(colorScheme)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    private var topBar: some View {
        ZStack {
            Text("Информация о перевозчике")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(colorScheme.appPrimaryText)
                .lineLimit(1)
                .padding(.horizontal, 44) // резерв под кнопку слева и симметрию справа

            HStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(colorScheme.appPrimaryText)
                        .frame(width: 44, height: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Color.clear
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, horizontalInset)
        .frame(height: 56)
    }

    private var carrierLogoCard: some View {
        RoundedRectangle(cornerRadius: logoCardCornerRadius, style: .continuous)
            .fill(Color.white)
            .frame(height: logoCardHeight)
            .overlay {
                carrierLogo
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
            }
    }

    private var carrierLogo: some View {
        Group {
            if let image = UIImage(named: cardLogoAssetName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(carrier.logoAssetName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func infoBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(colorScheme.appPrimaryText)

            Text(value)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(AppTheme.gray)
        }
    }

    private var displayName: String {
        switch normalizedCarrierName {
        case "ржд":
            return "ОАО «РЖД»"
        case "фгк":
            return "ФГК"
        case "урал логистика":
            return "Урал Логистика"
        default:
            return carrier.name
        }
    }

    private var cardLogoAssetName: String {
        switch normalizedCarrierName {
        case "ржд":
            return "RZDCard"
        case "фгк":
            return "FGK"
        case "урал логистика":
            return "URAL"
        default:
            return carrier.logoAssetName
        }
    }

    private var normalizedCarrierName: String {
        carrier.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
