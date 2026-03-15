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

            Text("ThingCost")
                .font(.largeTitle.bold())

            Text("See the real daily cost\nof everything you own")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                withAnimation { currentPage = 1 }
            } label: {
                Text("Next")
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
                stepRow(icon: "plus.circle.fill", color: .blue, title: "Add a purchase", description: "Enter what you bought, how much, and when")
                stepRow(icon: "chart.line.downtrend.xyaxis", color: .green, title: "Watch the cost drop", description: "Daily cost decreases every day you own it")
                stepRow(icon: "square.and.arrow.up", color: .purple, title: "Share your stats", description: "Generate beautiful cards for social media")
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                withAnimation { currentPage = 2 }
            } label: {
                Text("Next")
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

            Text("Ready to start?")
                .font(.title.bold())

            Text("We'll add a sample item\nso you can see how it works")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                addSampleItemAndFinish()
            } label: {
                Text("Add Sample & Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)

            Button("Skip") {
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
