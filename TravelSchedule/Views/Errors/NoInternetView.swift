import SwiftUI

struct NoInternetView: View {
    let onClose: () -> Void

    var body: some View {
        ErrorTemplateView(
            title: "Нет интернета",
            imageName: "noInternet",
            onClose: onClose
        )
    }
}
