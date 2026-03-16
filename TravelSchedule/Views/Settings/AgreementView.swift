import SwiftUI
import Combine

struct AgreementView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = AgreementViewModel()

    var body: some View {
        ScrollView {
            Text(viewModel.agreementText)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(colorScheme.appPrimaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
        }
        .appScreenBackground(colorScheme)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
