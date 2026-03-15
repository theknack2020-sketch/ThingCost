import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let store: StoreService

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Icon
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue.gradient)

                // Title
                VStack(spacing: 8) {
                    Text("Unlock Unlimited Items")
                        .font(.title.bold())

                    Text("You've added 3 items for free.\nUnlock unlimited tracking with a one-time purchase.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    featureRow(icon: "infinity", text: "Unlimited items")
                    featureRow(icon: "square.and.arrow.up", text: "All share card styles")
                    featureRow(icon: "widget.small", text: "Widget support")
                    featureRow(icon: "heart.fill", text: "Support indie development")
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)

                Spacer()

                // Purchase button
                VStack(spacing: 12) {
                    Button {
                        Task { await store.purchase() }
                    } label: {
                        Group {
                            if case .purchasing = store.purchaseState {
                                ProgressView()
                                    .tint(.white)
                            } else if let product = store.product {
                                Text("Unlock for \(product.displayPrice)")
                                    .font(.headline)
                            } else {
                                Text("Loading...")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(store.product == nil || isPurchasing)

                    Button("Restore Purchases") {
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
                    Button("Cancel") { dismiss() }
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
