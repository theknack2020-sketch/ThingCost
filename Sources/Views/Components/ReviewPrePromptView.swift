import SwiftUI

/// The honest in-app review pre-prompt — a warm "Enjoying ThingCost?" card
/// surfaced only at a peak moment (see ``ReviewManager``). A happy tap opens
/// Apple's native rating prompt; an unhappy tap opens private feedback so a
/// gripe reaches us in Mail instead of a public one-star. Never a fake star UI
/// that secretly filters reviews.
struct ReviewPrePromptView: View {
    let onLove: () -> Void
    let onFeedback: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                Image(systemName: "tag.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("Enjoying ThingCost?")
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("A quick word helps others discover the true cost of their things — and if something's off, tell us and we'll fix it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 12) {
                Button {
                    HapticManager.shared.celebrate()
                    onLove()
                    dismiss()
                } label: {
                    Text("I love it")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: .rect(cornerRadius: 14, style: .continuous)
                        )
                }

                Button {
                    HapticManager.shared.selection()
                    onFeedback()
                    dismiss()
                } label: {
                    Text("Could be better")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }
}

#Preview("Review pre-prompt") {
    Color.black.opacity(0.2)
        .sheet(isPresented: .constant(true)) {
            ReviewPrePromptView(onLove: {}, onFeedback: {})
        }
}
