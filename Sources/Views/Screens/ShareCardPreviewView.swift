import SwiftUI

struct ShareCardPreviewView: View {
    let item: Item
    @State private var selectedStyle: ShareCardStyle = .bold
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Picker("Style", selection: $selectedStyle) {
                    ForEach(ShareCardStyle.allCases) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ShareCardView(item: item, style: selectedStyle)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                    .padding(.horizontal, 24)
                    .animation(.easeInOut(duration: 0.3), value: selectedStyle)

                Spacer()

                Button {
                    shareCard()
                } label: {
                    Label("share", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            }
            .navigationTitle("share_card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("done") { dismiss() }
                }
            }
        }
    }

    @MainActor
    private func shareCard() {
        guard let image = ShareService.renderShareCard(item: item, style: selectedStyle) else { return }
        ShareService.shareImage(image)
    }
}
