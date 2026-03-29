import SwiftData
import SwiftUI

// MARK: - Confetti

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let xPosition: Double
    let rotation: Double
    let delay: Double
    let size: Double
    let shape: Int // 0 = circle, 1 = rect, 2 = capsule
}

// MARK: - Main Onboarding View

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentPage = 0
    @State private var showConfetti = false

    private let totalPages = 4

    var body: some View {
        ZStack {
            // Animated mesh gradient background
            animatedBackground

            // Page content
            TabView(selection: $currentPage) {
                WelcomePage(currentPage: $currentPage, reduceMotion: reduceMotion)
                    .tag(0)

                FeaturesPage(currentPage: $currentPage, reduceMotion: reduceMotion)
                    .tag(1)

                NotificationPage(currentPage: $currentPage, reduceMotion: reduceMotion)
                    .tag(2)

                GetStartedPage(
                    reduceMotion: reduceMotion,
                    showConfetti: $showConfetti,
                    onAddFirst: finishAndOpenAddItem,
                    onSkip: { hasCompletedOnboarding = true }
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentPage)

            // Custom page indicator
            VStack {
                Spacer()
                pageIndicator
                    .padding(.bottom, 12)
            }

            // Confetti overlay
            if showConfetti {
                ConfettiOverlay()
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Background

    private var animatedBackground: some View {
        backgroundGradient
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.2), value: currentPage)
    }

    @ViewBuilder
    private var backgroundGradient: some View {
        if #available(iOS 18.0, *) {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0],
                ],
                colors: meshColors
            )
        } else {
            LinearGradient(
                colors: fallbackGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var fallbackGradientColors: [Color] {
        switch currentPage {
        case 0: [.blue.opacity(0.12), .purple.opacity(0.08), .clear]
        case 1: [.green.opacity(0.08), .blue.opacity(0.06), .clear]
        case 2: [.orange.opacity(0.1), .yellow.opacity(0.06), .clear]
        default: [.purple.opacity(0.1), .blue.opacity(0.08), .clear]
        }
    }

    private var meshColors: [Color] {
        switch currentPage {
        case 0:
            [
                .blue.opacity(0.15), .purple.opacity(0.1), .blue.opacity(0.08),
                .indigo.opacity(0.1), .blue.opacity(0.05), .purple.opacity(0.08),
                .blue.opacity(0.12), .indigo.opacity(0.06), .purple.opacity(0.1),
            ]
        case 1:
            [
                .green.opacity(0.1), .blue.opacity(0.08), .teal.opacity(0.1),
                .blue.opacity(0.06), .green.opacity(0.05), .blue.opacity(0.08),
                .teal.opacity(0.08), .green.opacity(0.06), .blue.opacity(0.1),
            ]
        case 2:
            [
                .orange.opacity(0.12), .yellow.opacity(0.08), .orange.opacity(0.06),
                .yellow.opacity(0.06), .orange.opacity(0.08), .yellow.opacity(0.05),
                .orange.opacity(0.1), .yellow.opacity(0.06), .orange.opacity(0.08),
            ]
        default:
            [
                .purple.opacity(0.12), .blue.opacity(0.1), .pink.opacity(0.08),
                .blue.opacity(0.08), .purple.opacity(0.06), .blue.opacity(0.08),
                .pink.opacity(0.1), .purple.opacity(0.08), .blue.opacity(0.12),
            ]
        }
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.primary : Color.primary.opacity(0.2))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    // MARK: - Sample Item

    private func finishAndOpenAddItem() {
        HapticManager.shared.celebrate()
        SoundManager.shared.playCelebrate()
        showConfetti = true

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                hasCompletedOnboarding = true
            }
            // Post notification to open AddItemView after onboarding dismisses
            try? await Task.sleep(for: .seconds(0.5))
            NotificationCenter.default.post(name: .openAddItemAfterOnboarding, object: nil)
        }
    }
}

// MARK: - Page 1: Welcome

private struct WelcomePage: View {
    @Binding var currentPage: Int
    let reduceMotion: Bool
    @State private var appeared = false
    @State private var iconBounce = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon with spring entrance — stays visible
            ZStack {
                // Glow ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue.opacity(0.25), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 90
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(appeared ? 1.0 : 0.3)
                    .opacity(appeared ? 0.6 : 0)

                // Icon
                Image(systemName: "tag.fill")
                    .font(.system(size: 72, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(x: -1, y: 1)
                    .scaleEffect(appeared ? (iconBounce ? 1.0 : 1.08) : 0.3)
                    .opacity(appeared ? 1.0 : 0)
                    .rotationEffect(.degrees(appeared ? 0 : -20))
                    .blur(radius: reduceMotion ? 0 : (appeared ? 0 : 8))
                    .shadow(color: .blue.opacity(0.4), radius: 20, y: 6)
            }
            .animation(
                reduceMotion ? .none : .spring(response: 0.7, dampingFraction: 0.6),
                value: appeared
            )
            .animation(
                reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.5).delay(0.7),
                value: iconBounce
            )
            .onAppear {
                appeared = true
                // Settle bounce after spring overshoot
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.7))
                    iconBounce = true
                }
            }

            Spacer().frame(height: 32)

            // Text content with staggered reveal
            VStack(spacing: 12) {
                Text("app_name")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(
                        reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.3),
                        value: appeared
                    )

                Text("onboarding_tagline")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(
                        reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.45),
                        value: appeared
                    )
            }

            Spacer()

            // CTA Button
            OnboardingButton(title: String(localized: "onboarding_next")) {
                HapticManager.shared.tap()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    currentPage = 1
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 30)
            .animation(
                reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.6),
                value: appeared
            )
            .padding(.bottom, 60)
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Page 2: Features

private struct FeaturesPage: View {
    @Binding var currentPage: Int
    let reduceMotion: Bool
    @State private var appeared = false

    private struct FeatureInfo {
        let icon: String
        let color: Color
        let titleKey: String
        let descKey: String
    }

    private let features: [FeatureInfo] = [
        FeatureInfo(icon: "plus.circle.fill", color: .blue, titleKey: "onboarding_step1_title", descKey: "onboarding_step1_desc"),
        FeatureInfo(icon: "chart.line.downtrend.xyaxis", color: .green, titleKey: "onboarding_step2_title", descKey: "onboarding_step2_desc"),
        FeatureInfo(icon: "square.and.arrow.up", color: .purple, titleKey: "onboarding_step3_title", descKey: "onboarding_step3_desc"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("How It Works")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.1),
                    value: appeared
                )
                .padding(.bottom, 32)

            VStack(spacing: 16) {
                ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                    FeatureCard(
                        icon: feature.icon,
                        color: feature.color,
                        title: String(localized: String.LocalizationValue(feature.titleKey)),
                        description: String(localized: String.LocalizationValue(feature.descKey)),
                        index: index,
                        appeared: appeared,
                        reduceMotion: reduceMotion
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            OnboardingButton(title: String(localized: "onboarding_next")) {
                HapticManager.shared.tap()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    currentPage = 2
                }
            }
            .padding(.bottom, 60)
        }
        .onAppear { appeared = true }
    }
}

private struct FeatureCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let index: Int
    let appeared: Bool
    let reduceMotion: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: color.opacity(0.35), radius: 8, y: 4)

                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.semibold))
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .scaleEffect(appeared ? 1 : 0.9)
        .animation(
            reduceMotion
                ? .none
                : .spring(response: 0.5, dampingFraction: 0.75).delay(0.15 + Double(index) * 0.12),
            value: appeared
        )
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Page 3: Notifications

private struct NotificationPage: View {
    @Binding var currentPage: Int
    let reduceMotion: Bool
    @State private var appeared = false
    @State private var notificationEnabled = false
    @State private var bellBounce = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Bell with bounce effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange.gradient)
                    .symbolEffect(.bounce, value: bellBounce)
                    .shadow(color: .orange.opacity(0.3), radius: 12, y: 4)
            }
            .scaleEffect(appeared ? 1 : 0.3)
            .opacity(appeared ? 1 : 0)
            .animation(
                reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.6),
                value: appeared
            )

            Text("onboarding_notifications_title")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.2),
                    value: appeared
                )

            Text("onboarding_notifications_desc")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(appeared ? 1 : 0)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.3),
                    value: appeared
                )

            if notificationEnabled {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("onboarding_notifications_enabled")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.green)
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()

            if !notificationEnabled {
                Button {
                    HapticManager.shared.tap()
                    bellBounce += 1
                    Task {
                        let granted = await NotificationManager.shared.requestPermission()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            notificationEnabled = granted
                        }
                        if granted {
                            NotificationManager.shared.scheduleDailyReminder()
                        }
                        try? await Task.sleep(for: .seconds(0.8))
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            currentPage = 3
                        }
                    }
                } label: {
                    Label("onboarding_enable_reminders", systemImage: "bell.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.horizontal, 32)
                .shadow(color: .orange.opacity(0.3), radius: 8, y: 4)
            }

            Button {
                HapticManager.shared.tap()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    currentPage = 3
                }
            } label: {
                Text(notificationEnabled ? "onboarding_next" : "onboarding_maybe_later")
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 60)
        }
        .onAppear {
            appeared = true
            // Delayed bell bounce
            if !reduceMotion {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.6))
                    bellBounce += 1
                }
            }
        }
    }
}

// MARK: - Page 4: Get Started

private struct GetStartedPage: View {
    let reduceMotion: Bool
    @Binding var showConfetti: Bool
    let onAddFirst: () -> Void
    let onSkip: () -> Void

    @State private var appeared = false
    @State private var sparkleRotation: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Sparkle icon with continuous subtle rotation
            ZStack {
                // Outer glow rings
                ForEach(0 ..< 3, id: \.self) { ringIndex in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.yellow.opacity(0.15), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: CGFloat(100 + ringIndex * 30), height: CGFloat(100 + ringIndex * 30))
                        .scaleEffect(appeared ? 1 : 0.5)
                        .opacity(appeared ? (0.4 - Double(ringIndex) * 0.1) : 0)
                        .animation(
                            reduceMotion
                                ? .none
                                : .spring(response: 0.6, dampingFraction: 0.7).delay(0.1 + Double(ringIndex) * 0.08),
                            value: appeared
                        )
                }

                Image(systemName: "sparkles")
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .yellow.opacity(0.4), radius: 16, y: 4)
                    .rotationEffect(.degrees(sparkleRotation))
            }
            .scaleEffect(appeared ? 1 : 0.3)
            .opacity(appeared ? 1 : 0)
            .animation(
                reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.6),
                value: appeared
            )

            Text("onboarding_ready")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.2),
                    value: appeared
                )

            Text("Add something you own\nand see what it really costs per day")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(appeared ? 1 : 0)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.3),
                    value: appeared
                )

            Spacer()

            // Primary CTA — gradient pill with press effect
            AnimatedButton {
                onAddFirst()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.body.weight(.semibold))
                    Text("Add Your First Item")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
            }
            .shadow(color: .blue.opacity(0.35), radius: 12, y: 6)
            .padding(.horizontal, 32)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 30)
            .animation(
                reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.45),
                value: appeared
            )
            .accessibilityLabel("Add your first item")

            Button("onboarding_skip") {
                HapticManager.shared.tap()
                onSkip()
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 60)
            .accessibilityLabel("Skip onboarding")
        }
        .onAppear {
            appeared = true
            if !reduceMotion {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    sparkleRotation = 360
                }
            }
        }
    }
}

// MARK: - Onboarding Button

private struct OnboardingButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
        }
        .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
        .padding(.horizontal, 32)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel("Continue to next step")
    }
}

// MARK: - Confetti Overlay

private struct ConfettiOverlay: View {
    @State private var pieces: [ConfettiPiece] = []
    @State private var animate = false

    private let confettiColors: [Color] = [
        .blue, .purple, .orange, .green, .pink, .yellow, .teal, .red,
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    confettiShape(piece)
                        .frame(width: piece.size, height: piece.size * (piece.shape == 1 ? 0.5 : 1))
                        .foregroundStyle(piece.color)
                        .position(
                            x: piece.xPosition * geo.size.width,
                            y: animate ? geo.size.height + 60 : -40
                        )
                        .rotationEffect(.degrees(animate ? piece.rotation + 360 : piece.rotation))
                        .opacity(animate ? 0 : 1)
                        .animation(
                            .easeIn(duration: Double.random(in: 1.8 ... 3.0))
                                .delay(piece.delay),
                            value: animate
                        )
                }
            }
            .onAppear {
                generatePieces()
                animate = true
            }
        }
    }

    @ViewBuilder
    private func confettiShape(_ piece: ConfettiPiece) -> some View {
        switch piece.shape {
        case 0: Circle()
        case 1: Rectangle()
        default: Capsule()
        }
    }

    private func generatePieces() {
        pieces = (0 ..< 50).map { _ in
            ConfettiPiece(
                color: confettiColors.randomElement() ?? .blue,
                xPosition: Double.random(in: 0.05 ... 0.95),
                rotation: Double.random(in: -180 ... 180),
                delay: Double.random(in: 0 ... 0.4),
                size: Double.random(in: 6 ... 14),
                shape: Int.random(in: 0 ... 2)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .modelContainer(for: Item.self, inMemory: true)
}
