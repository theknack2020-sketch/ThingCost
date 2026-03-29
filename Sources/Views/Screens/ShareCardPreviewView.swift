import SwiftUI

struct ShareCardPreviewView: View {
    let item: Item
    @State private var selectedStyle: ShareCardStyle = .minimal
    @State private var showingPaywall = false
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreService.self) private var store

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Style picker with Pro lock indicators
                HStack(spacing: 8) {
                    ForEach(ShareCardStyle.allCases) { style in
                        let isLocked = !store.isShareStyleAvailable(style)
                        Button {
                            if isLocked {
                                showingPaywall = true
                            } else {
                                HapticManager.shared.selection()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedStyle = style
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(style.displayName)
                                    .font(.subheadline.weight(.medium))
                                if isLocked {
                                    Image(systemName: "lock.fill")
                                        .font(.caption2)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                selectedStyle == style && !isLocked
                                    ? Color.accentColor
                                    : Color(.systemGray5),
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                            .foregroundStyle(
                                selectedStyle == style && !isLocked
                                    ? .white
                                    : isLocked ? .secondary : .primary
                            )
                        }
                        .accessibilityLabel("\(String(localized: style.displayName)) share card style")
                    }
                }
                .padding(.horizontal)

                // Card preview — show lock overlay for Pro styles when not unlocked
                ZStack {
                    ShareCardView(item: item, style: selectedStyle)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)

                    if !store.isShareStyleAvailable(selectedStyle) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                VStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundStyle(.secondary)
                                    Text("Pro Style")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    Button("Unlock") {
                                        showingPaywall = true
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                }
                            }
                            .accessibilityLabel("Pro feature, unlock required")
                    }
                }
                .padding(.horizontal, 24)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedStyle)

                Spacer()

                Button {
                    HapticManager.shared.tap()
                    shareCard()
                } label: {
                    Label("share", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!store.isShareStyleAvailable(selectedStyle))
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                .accessibilityLabel("Share card image")
            }
            .navigationTitle("share_card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        HapticManager.shared.tap()
                        dismiss()
                    } label: {
                        Label("Close share preview", systemImage: "xmark")
                            .labelStyle(.titleOnly)
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView(store: store)
            }
        }
    }

    @MainActor
    private func shareCard() {
        guard store.isShareStyleAvailable(selectedStyle) else { return }
        guard let image = ShareService.renderShareCard(item: item, style: selectedStyle) else { return }
        Analytics.shareCardCreated(style: selectedStyle.rawValue)
        AchievementManager.shared.markShared()
        ShareService.shareImage(image)
    }
}
