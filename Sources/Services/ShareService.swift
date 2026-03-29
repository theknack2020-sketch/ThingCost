import SwiftUI

@MainActor
struct ShareService {
    @MainActor
    static func renderShareCard(item: Item, style: ShareCardStyle) -> UIImage? {
        let renderer = ImageRenderer(content:
            ShareCardView(item: item, style: style)
                .frame(width: 390, height: 500))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    static func shareImage(_ image: UIImage) {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController
        else {
            return
        }

        // Find topmost presented controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        // iPad popover
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        topVC.present(activityVC, animated: true)
    }
}
