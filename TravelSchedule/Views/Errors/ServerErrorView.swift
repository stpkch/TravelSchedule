import SwiftUI

struct ServerErrorView: View {
    let onClose: () -> Void

    var body: some View {
        ErrorTemplateView(
            title: "Ошибка сервера",
            imageName: "errorService",
            onClose: onClose
        )
    }
}
