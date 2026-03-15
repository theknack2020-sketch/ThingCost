import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            ItemListView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .environment(StoreService.shared)
        .modelContainer(for: Item.self, inMemory: true)
}
