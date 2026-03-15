import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let store: StoreService

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "lock.open.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue.gradient)

                VStack(spacing: 8) {
                    Text("paywall_title")
                        .font(.title.bold())

                    Text("paywall_desc")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 12) {
                    featureRow(icon: "infinity", text: String(localized: "paywall_unlimited"))
                    featureRow(icon: "square.and.arrow.up", text: String(localized: "paywall_share"))
                    featureRow(icon: "widget.small", text: String(localized: "paywall_widget"))
                    featureRow(icon: "heart.fill", text: String(localized: "paywall_support"))
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        Task { await store.purchase() }
                    } label: {
                        Group {
                            if case .purchasing = store.purchaseState {
                                ProgressView()
                                    .tint(.white)
                            } else if let product = store.product {
                                Text("paywall_unlock \(product.displayPrice)")
                                    .font(.headline)
                            } else {
                                Text("paywall_loading")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(store.product == nil || isPurchasing)

                    Button("paywall_restore") {
                        Task { await store.restore() }
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                if case .failed(let message) = store.purchaseState {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.bottom, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
            }
            .onChange(of: store.isUnlimited) { _, isUnlimited in
                if isUnlimited { dismiss() }
            }
        }
    }

    private var isPurchasing: Bool {
        if case .purchasing = store.purchaseState { return true }
        return false
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.body)
        }
    }
}
