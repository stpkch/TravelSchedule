import SwiftUI

struct ErrorTemplateView: View {
    let title: String
    let imageName: String
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 32))

                Text(title)
                    .font(.largeTitle.weight(.bold))
                    .padding(.top, 16)

                Spacer()

                Button("Закрыть") {
                    onClose()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
        }
    }
}
