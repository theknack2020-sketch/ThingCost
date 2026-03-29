import SwiftUI

struct AchievementPopup: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var confettiVisible = false

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(appeared ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 16) {
                // Confetti particles
                ZStack {
                    ForEach(0 ..< 12, id: \.self) { index in
                        Circle()
                            .fill(confettiColor(for: index))
                            .frame(width: 8, height: 8)
                            .offset(confettiOffset(for: index))
                            .opacity(confettiVisible ? 0 : 1)
                            .animation(
                                .easeOut(duration: 1.0).delay(Double(index) * 0.05),
                                value: confettiVisible
                            )
                    }

                    Image(systemName: achievement.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(achievement.color.gradient)
                        .symbolEffect(.bounce, value: appeared)
                }
                .frame(height: 80)

                Text("Achievement Unlocked!")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text(achievement.rawValue)
                    .font(.title2.bold())

                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.caption)
                    Text(achievement.threshold)
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(achievement.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(achievement.color.opacity(0.15), in: Capsule())

                Button {
                    dismiss()
                } label: {
                    Text("Awesome!")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
                .padding(.top, 4)
            }
            .padding(28)
            .frame(maxWidth: 320)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            .scaleEffect(appeared ? 1.0 : 0.6)
            .opacity(appeared ? 1.0 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                confettiVisible = true
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.2)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }

    private func confettiColor(for index: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .mint]
        return colors[index % colors.count]
    }

    private func confettiOffset(for index: Int) -> CGSize {
        let angle = (Double(index) / 12.0) * 2 * .pi
        let radius: CGFloat = confettiVisible ? 80 : 0
        return CGSize(width: cos(angle) * radius, height: sin(angle) * radius)
    }
}

#Preview {
    AchievementPopup(achievement: .weekStreak) {}
}
