import SwiftData
import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab: AppTab = .items
    @State private var showAddItemAfterOnboarding = false
    @State private var reviewManager = ReviewManager.shared
    #if DEBUG
        @Environment(\.modelContext) private var modelContext
        @State private var tourDetailItem: Item?
        @State private var tourShareItem: Item?
    #endif

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
        #if DEBUG
            .task { applyScreenshotTour() }
            .fullScreenCover(item: $tourDetailItem) { item in
                NavigationStack {
                    ItemDetailView(item: item)
                }
            }
            .fullScreenCover(item: $tourShareItem) { item in
                ShareCardPreviewView(item: item)
            }
        #endif
    }

    #if DEBUG
        /// Store-screenshot routing (store-shots pipeline). Presents the panel's
        /// exact screen without animation for a deterministic first frame.
        private func applyScreenshotTour() {
            guard let state = ScreenshotTour.state else { return }
            hasCompletedOnboarding = true

            switch state {
            case .list:
                selectedTab = .items
            case .dashboard:
                selectedTab = .dashboard
            case .settings:
                selectedTab = .settings
            case .detail, .share:
                selectedTab = .items
                var descriptor = FetchDescriptor<Item>()
                descriptor.sortBy = [SortDescriptor(\.price, order: .reverse)]
                guard let items = try? modelContext.fetch(descriptor), !items.isEmpty
                else { return }
                let hero = items[min(ScreenshotTour.heroIndex, items.count - 1)]
                withTransaction(\.disablesAnimations, true) {
                    if state == .detail {
                        tourDetailItem = hero
                    } else {
                        tourShareItem = hero
                    }
                }
            }
        }
    #endif

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
        .sheet(isPresented: Binding(
            get: { reviewManager.pendingPrePrompt },
            set: { reviewManager.pendingPrePrompt = $0 }
        )) {
            ReviewPrePromptView(
                onLove: { reviewManager.lovedIt() },
                onFeedback: { reviewManager.notForMe() }
            )
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
