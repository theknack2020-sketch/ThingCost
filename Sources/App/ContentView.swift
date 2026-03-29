import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab: AppTab = .items
    @State private var showAddItemAfterOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingView()
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: hasCompletedOnboarding)
        .onReceive(NotificationCenter.default.publisher(for: .openAddItemAfterOnboarding)) { _ in
            showAddItemAfterOnboarding = true
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
                .tag(AppTab.dashboard)

            ItemListView()
                .tabItem {
                    Label("Items", systemImage: "bag.fill")
                }
                .tag(AppTab.items)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(.blue)
        .sheet(isPresented: $showAddItemAfterOnboarding) {
            AddItemView()
        }
    }
}

enum AppTab: String, Hashable {
    case dashboard
    case items
    case settings
}

#Preview {
    ContentView()
        .environment(StoreService.shared)
        .modelContainer(for: Item.self, inMemory: true)
}
