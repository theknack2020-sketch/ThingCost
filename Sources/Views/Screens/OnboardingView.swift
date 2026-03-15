import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            howItWorksPage.tag(1)
            getStartedPage.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "tag.fill")
                .font(.system(size: 70))
                .foregroundStyle(.blue.gradient)
                .scaleEffect(x: -1, y: 1)

            Text("app_name")
                .font(.largeTitle.bold())

            Text("onboarding_tagline")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                withAnimation { currentPage = 1 }
            } label: {
                Text("onboarding_next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    private var howItWorksPage: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                stepRow(icon: "plus.circle.fill", color: .blue,
                        title: String(localized: "onboarding_step1_title"),
                        description: String(localized: "onboarding_step1_desc"))
                stepRow(icon: "chart.line.downtrend.xyaxis", color: .green,
                        title: String(localized: "onboarding_step2_title"),
                        description: String(localized: "onboarding_step2_desc"))
                stepRow(icon: "square.and.arrow.up", color: .purple,
                        title: String(localized: "onboarding_step3_title"),
                        description: String(localized: "onboarding_step3_desc"))
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                withAnimation { currentPage = 2 }
            } label: {
                Text("onboarding_next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    private func stepRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var getStartedPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundStyle(.yellow.gradient)

            Text("onboarding_ready")
                .font(.title.bold())

            Text("onboarding_sample_desc")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                addSampleItemAndFinish()
            } label: {
                Text("onboarding_add_sample")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)

            Button("onboarding_skip") {
                hasCompletedOnboarding = true
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 40)
        }
    }

    private func addSampleItemAndFinish() {
        let sampleItem = Item(
            name: "iPhone",
            price: 64999,
            purchaseDate: Calendar.current.date(byAdding: .day, value: -180, to: Date())!,
            category: .electronics,
            iconName: "iphone"
        )
        modelContext.insert(sampleItem)
        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: Item.self, inMemory: true)
}
