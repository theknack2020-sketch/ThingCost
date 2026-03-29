import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var heroAppeared = false
    @State private var shimmerOffset: CGFloat = -200
    let store: StoreService

    // MARK: - Comparison Data

    private struct ComparisonRow: Identifiable {
        let id = UUID()
        let feature: LocalizedStringResource
        let icon: String
        let freeValue: String
        let proValue: String
        let freeIsLimited: Bool
    }

    private let comparisonRows: [ComparisonRow] = [
        ComparisonRow(feature: "paywall_feat_items", icon: "cube.fill", freeValue: "5 max", proValue: "Unlimited", freeIsLimited: true),
        ComparisonRow(feature: "paywall_feat_photos", icon: "camera.fill", freeValue: "—", proValue: "✓", freeIsLimited: true),
        ComparisonRow(feature: "paywall_feat_usage", icon: "hand.tap.fill", freeValue: "View only", proValue: "Log uses", freeIsLimited: true),
        ComparisonRow(feature: "paywall_feat_share", icon: "square.and.arrow.up", freeValue: "1 style", proValue: "All 3", freeIsLimited: true),
        ComparisonRow(feature: "paywall_feat_themes", icon: "paintpalette.fill", freeValue: "2", proValue: "All", freeIsLimited: true),
        ComparisonRow(feature: "paywall_feat_charts", icon: "chart.bar.fill", freeValue: "Basic", proValue: "All", freeIsLimited: true),
        ComparisonRow(feature: "paywall_feat_export", icon: "arrow.down.doc.fill", freeValue: "—", proValue: "✓", freeIsLimited: true),
        ComparisonRow(feature: "paywall_feat_projections", icon: "sparkles", freeValue: "6 mo", proValue: "∞", freeIsLimited: true),
        ComparisonRow(feature: "paywall_feat_categories", icon: "folder.fill", freeValue: "Standard", proValue: "+ Custom", freeIsLimited: true),
        ComparisonRow(feature: "paywall_feat_widget", icon: "widget.small", freeValue: "Basic", proValue: "All sizes", freeIsLimited: true),
        ComparisonRow(feature: "paywall_feat_support", icon: "bolt.heart.fill", freeValue: "—", proValue: "✓", freeIsLimited: true),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Rich Background
                backgroundLayers

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28) {
                        heroSection
                        comparisonCard
                        purchaseCard
                        termsText
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        HapticManager.shared.tap()
                        dismiss()
                    } label: {
                        Label("Close paywall", systemImage: "xmark.circle.fill")
                            .labelStyle(.iconOnly)
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .onChange(of: store.isUnlimited) { _, isUnlimited in
                if isUnlimited {
                    HapticManager.shared.celebrate()
                    SoundManager.shared.playCelebrate()
                    Analytics.purchaseCompleted()
                    dismiss()
                }
            }
            .onChange(of: store.purchaseState) { _, newState in
                if case let .failed(message) = newState {
                    HapticManager.shared.error()
                    SoundManager.shared.playError()
                    Analytics.purchaseFailed(error: message)
                }
            }
            .onAppear {
                Analytics.paywallViewed(trigger: "direct")
            }
        }
    }

    // MARK: - Background

    private var backgroundLayers: some View {
        ZStack {
            // Base gradient — deeper, richer
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.05, blue: 0.35),
                    Color(red: 0.25, green: 0.08, blue: 0.55),
                    Color(red: 0.40, green: 0.15, blue: 0.65),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient glow orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue.opacity(0.4), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: -100, y: -200)
                .blur(radius: 60)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.35), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 120, y: 300)
                .blur(radius: 70)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.pink.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .offset(x: 80, y: -50)
                .blur(radius: 50)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 20) {
            // Crown icon with glow rings
            ZStack {
                // Outer glow
                ForEach(0 ..< 3, id: \.self) { ring in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.15 - Double(ring) * 0.04),
                                    Color.orange.opacity(0.1 - Double(ring) * 0.03),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(
                            width: CGFloat(80 + ring * 28),
                            height: CGFloat(80 + ring * 28)
                        )
                        .scaleEffect(heroAppeared ? 1 : 0.5)
                        .opacity(heroAppeared ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                                .delay(0.1 + Double(ring) * 0.08),
                            value: heroAppeared
                        )
                }

                // Icon background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.25),
                                Color.orange.opacity(0.15),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)

                Image(systemName: "crown.fill")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .yellow.opacity(0.5), radius: 12, y: 4)
            }
            .scaleEffect(heroAppeared ? 1 : 0.3)
            .opacity(heroAppeared ? 1 : 0)
            .animation(.spring(response: 0.7, dampingFraction: 0.6), value: heroAppeared)
            .onAppear { heroAppeared = true }

            VStack(spacing: 8) {
                Text("Go Pro")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Unlock every feature. Pay once, keep forever.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .opacity(heroAppeared ? 1 : 0)
            .offset(y: heroAppeared ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: heroAppeared)
        }
        .padding(.top, 20)
    }

    // MARK: - Comparison Card

    private var comparisonCard: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Feature")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Free")
                    .frame(width: 60)

                Text("Pro")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 70)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.5))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Rows
            ForEach(Array(comparisonRows.enumerated()), id: \.element.id) { index, row in
                VStack(spacing: 0) {
                    if index > 0 {
                        Rectangle()
                            .fill(.white.opacity(0.06))
                            .frame(height: 0.5)
                            .padding(.leading, 48)
                    }

                    HStack(spacing: 10) {
                        // Feature icon
                        Image(systemName: row.icon)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.4))
                            .frame(width: 18)

                        Text(row.feature)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Free value
                        Group {
                            if row.freeValue == "—" {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.red.opacity(0.6))
                            } else {
                                Text(row.freeValue)
                                    .foregroundStyle(.white.opacity(0.35))
                            }
                        }
                        .font(.caption)
                        .frame(width: 60)

                        // Pro value
                        Group {
                            if row.proValue == "✓" {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.green)
                            } else {
                                Text(row.proValue)
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.caption)
                        .frame(width: 70)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 24, y: 12)
        .opacity(heroAppeared ? 1 : 0)
        .offset(y: heroAppeared ? 0 : 40)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: heroAppeared)
    }

    // MARK: - Purchase Card

    private var purchaseCard: some View {
        VStack(spacing: 20) {
            // Price
            VStack(spacing: 4) {
                if let product = store.product {
                    Text(product.displayPrice)
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .shadow(color: .white.opacity(0.2), radius: 8, y: 0)

                    Text("One-time purchase · No subscription")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(0.5)
                } else {
                    ProgressView()
                        .tint(.white)
                        .padding(.vertical, 20)
                }
            }

            // Purchase button — gradient with shimmer
            Button {
                HapticManager.shared.tap()
                Task { await store.purchase() }
            } label: {
                ZStack {
                    // Button background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.yellow,
                                    Color.orange,
                                    Color.yellow.opacity(0.9),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.5), radius: 16, y: 8)
                        .shadow(color: .yellow.opacity(0.3), radius: 4, y: 2)

                    // Shimmer overlay
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.3), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .mask(RoundedRectangle(cornerRadius: 16))
                        .onAppear {
                            withAnimation(
                                .linear(duration: 2.5)
                                    .repeatForever(autoreverses: false)
                                    .delay(1.0)
                            ) {
                                shimmerOffset = 400
                            }
                        }

                    // Label
                    Group {
                        if case .purchasing = store.purchaseState {
                            ProgressView()
                                .tint(.black)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "crown.fill")
                                    .font(.body.weight(.semibold))
                                Text("Unlock Pro")
                                    .font(.headline)
                            }
                        }
                    }
                    .foregroundStyle(.black)
                }
                .frame(height: 56)
            }
            .disabled(store.product == nil || isPurchasing)
            .accessibilityLabel(
                store.product.map { "Purchase Pro for \($0.displayPrice)" }
                    ?? "Loading price"
            )

            // Restore
            Button {
                HapticManager.shared.tap()
                Task { await store.restore() }
            } label: {
                Text("Restore Purchase")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.45))
            }
            .accessibilityLabel("Restore previous purchases")

            // Error
            if case let .failed(message) = store.purchaseState {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
        }
        .opacity(heroAppeared ? 1 : 0)
        .offset(y: heroAppeared ? 0 : 30)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.45), value: heroAppeared)
    }

    // MARK: - Terms

    private static let privacyURL = URL(string: "https://theknack2020-sketch.github.io/ThingCost/privacy")
    private static let termsURL = URL(string: "https://theknack2020-sketch.github.io/ThingCost/terms")

    private var termsText: some View {
        VStack(spacing: 4) {
            Text("No subscription. Pay once, own forever.")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.35))

            HStack(spacing: 4) {
                if let url = Self.privacyURL {
                    Link("Privacy Policy", destination: url)
                        .accessibilityLabel("Open privacy policy")
                }
                Text("·")
                if let url = Self.termsURL {
                    Link("Terms of Use", destination: url)
                        .accessibilityLabel("Open terms of use")
                }
            }
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.3))
        }
        .padding(.top, 8)
    }

    private var isPurchasing: Bool {
        if case .purchasing = store.purchaseState { return true }
        return false
    }
}
