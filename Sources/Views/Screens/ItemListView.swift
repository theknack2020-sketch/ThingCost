import SwiftData
import SwiftUI
import TipKit

struct ItemListView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]
    @Environment(StoreService.self) private var store
    @State private var showingAddSheet = false
    @State private var showingPaywall = false
    @State private var sortOption: SortOption = .dailyCostHigh
    @State private var editingItem: Item?
    @State private var selectedItem: Item?
    @State private var showExportShareSheet = false
    @State private var csvExportURL: URL?
    @State private var unlockedAchievement: Achievement?
    @State private var showAchievementPopup = false

    private let streakManager = StreakManager.shared
    private let achievementManager = AchievementManager.shared
    @State private var showDeleteError = false
    @State private var showExportError = false

    private var sortedItems: [Item] {
        switch sortOption {
        case .dailyCostHigh:
            items.sorted { $0.dailyCost > $1.dailyCost }
        case .dailyCostLow:
            items.sorted { $0.dailyCost < $1.dailyCost }
        case .priceHigh:
            items.sorted { $0.price > $1.price }
        case .priceLow:
            items.sorted { $0.price < $1.price }
        case .newest:
            items.sorted { $0.purchaseDate > $1.purchaseDate }
        case .oldest:
            items.sorted { $0.purchaseDate < $1.purchaseDate }
        case .name:
            items.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        }
    }

    // MARK: - Body

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddItemView()
        }
        .sheet(item: $editingItem) { item in
            EditItemView(item: item)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(store: store)
        }
        .onReceive(NotificationCenter.default.publisher(for: .showPaywall)) { _ in
            showingPaywall = true
        }
        .sheet(isPresented: $showExportShareSheet) {
            if let url = csvExportURL {
                ShareSheetView(items: [url])
            }
        }
        .alert("error_title", isPresented: $showDeleteError) {
            Button("error_ok", role: .cancel) {}
        } message: {
            Text("error_delete_failed")
        }
        .alert("error_export_title", isPresented: $showExportError) {
            Button("error_ok", role: .cancel) {}
        } message: {
            Text("error_export_failed")
        }
        .onAppear {
            Analytics.screenViewed(.itemList)
            streakManager.recordActivity()
            Analytics.streakRecorded(days: streakManager.currentStreak)
            NotificationManager.shared.scheduleStreakAtRisk()
            NotificationManager.shared.scheduleWarrantyReminders(for: items)
            checkAchievements()
        }
        .onChange(of: items.count) {
            checkAchievements()
        }
        .overlay {
            if showAchievementPopup, let achievement = unlockedAchievement {
                AchievementPopup(achievement: achievement) {
                    showAchievementPopup = false
                    unlockedAchievement = nil
                }
            }
        }
    }

    // MARK: - iPad: Two-Column Layout

    private var iPadLayout: some View {
        NavigationSplitView {
            Group {
                if items.isEmpty {
                    emptyState
                } else {
                    itemList
                }
            }
            .navigationTitle("app_name")
            .toolbar { toolbarLeading }
            .toolbar { toolbarTrailing }
        } detail: {
            if let selectedItem {
                ItemDetailView(item: selectedItem)
            } else {
                iPadPlaceholder
            }
        }
    }

    private var iPadPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.circle")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.5), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse, options: .repeating)

            Text("Select an item")
                .font(.title2.weight(.medium))
                .foregroundStyle(.secondary)

            Text("Choose an item from the list to see its daily cost breakdown, worth score, and projections.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - iPhone: Single-Column Layout

    private var iPhoneLayout: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyState
                } else {
                    itemList
                }
            }
            .navigationTitle("app_name")
            .toolbar { toolbarLeading }
            .toolbar { toolbarTrailing }
            .navigationDestination(item: $selectedItem) { item in
                ItemDetailView(item: item)
            }
        }
    }

    // MARK: - Shared Toolbar

    @ToolbarContentBuilder
    private var toolbarLeading: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if !items.isEmpty {
                sortMenu
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarTrailing: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 12) {
                // CSV Export — Pro only
                if !items.isEmpty {
                    Button {
                        HapticManager.shared.tap()
                        if store.canExportCSV {
                            exportCSV()
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Label("Export items as CSV", systemImage: "square.and.arrow.up.on.square")
                                .labelStyle(.iconOnly)
                                .font(.body)
                            if !store.isPro {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.white)
                                    .padding(2)
                                    .background(.blue, in: Circle())
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                    .accessibilityIdentifier("exportButton")
                }

                Button {
                    HapticManager.shared.tap()
                    if store.canAddItem(currentCount: items.count) {
                        showingAddSheet = true
                    } else {
                        showingPaywall = true
                    }
                } label: {
                    Label("Add new item", systemImage: "plus.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                }
                .accessibilityIdentifier("addButton")
            }
        }
    }

    // MARK: - Helpers

    private func checkAchievements() {
        let categoryCount = Set(items.map(\.category)).count
        if let achievement = achievementManager.checkAndUnlock(
            itemCount: items.count,
            streak: streakManager.currentStreak,
            categoryCount: categoryCount
        ) {
            unlockedAchievement = achievement
            showAchievementPopup = true
            Analytics.achievementUnlocked(name: achievement.rawValue)
            ReviewManager.shared.requestReviewIfAppropriate()
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button {
                    HapticManager.shared.selection()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { sortOption = option }
                } label: {
                    if sortOption == option {
                        Label(
                            title: { Text(option.displayName) },
                            icon: { Image(systemName: "checkmark") }
                        )
                    } else {
                        Text(option.displayName)
                    }
                }
            }
        } label: {
            Label("Sort items", systemImage: "arrow.up.arrow.down")
                .labelStyle(.iconOnly)
        }
        .accessibilityIdentifier("sortButton")
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("no_items_title", systemImage: "bag.fill")
        } description: {
            Text("no_items_desc")
        } actions: {
            Button {
                HapticManager.shared.tap()
                if store.canAddItem(currentCount: items.count) {
                    showingAddSheet = true
                } else {
                    showingPaywall = true
                }
            } label: {
                Text("add_item")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
            }
            .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
            .accessibilityLabel("Add your first item")
        }
    }

    // MARK: - Item List

    private var itemList: some View {
        List(selection: sizeClass == .regular ? $selectedItem : nil) {
            // Warranty tip — shown once, after a few items
            TipView(WarrantyTip())
                .tipBackground(Color.clear)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            totalSection
            itemsSection
        }
    }

    private var totalSection: some View {
        Section {
            VStack(spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("total_daily_cost")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.65))
                            .textCase(.uppercase)
                            .tracking(0.8)

                        Text(totalDailyCost.compactCurrency(code: currencyCode))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .contentTransition(.numericText())
                            .shadow(color: .white.opacity(0.15), radius: 4, y: 0)
                    }

                    Spacer()

                    // Streak badge
                    if streakManager.currentStreak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                            Text("\(streakManager.currentStreak)")
                                .font(.caption.bold().monospacedDigit())
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.2), in: Capsule())
                    }
                }

                // Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.2), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)

                HStack(spacing: 0) {
                    // Item count
                    VStack(spacing: 2) {
                        if store.isUnlimited {
                            Text("items_count \(items.count)")
                                .font(.caption)
                        } else {
                            Text("free_count \(items.count)")
                                .font(.caption)
                                .foregroundStyle(items.count >= 5 ? .orange : .white.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Capsule divider
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .frame(width: 1, height: 20)

                    // Monthly
                    VStack(spacing: 2) {
                        Text("\(totalMonthly.compactCurrency(code: currencyCode))\(String(localized: "per_month"))")
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                }
                .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.vertical, 8)
            .listRowBackground(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.25, green: 0.35, blue: 0.85),
                                    Color(red: 0.50, green: 0.30, blue: 0.80),
                                    Color(red: 0.65, green: 0.35, blue: 0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Subtle glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.12), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 120
                            )
                        )
                        .frame(width: 200, height: 200)
                        .offset(x: -80, y: -30)
                }
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Total daily cost \(totalDailyCost.compactCurrency(code: currencyCode)), \(items.count) items, monthly \(totalMonthly.compactCurrency(code: currencyCode))")
        }
    }

    private var itemsSection: some View {
        Section("items_section") {
            ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                Group {
                    if sizeClass == .regular {
                        // iPad: selection-based navigation
                        ItemRowView(item: item)
                            .tag(item)
                    } else {
                        // iPhone: tap-based navigation
                        ItemRowView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                HapticManager.shared.selection()
                                selectedItem = item
                            }
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .opacity
                ))
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05),
                    value: items.count
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        HapticManager.shared.delete()
                        SoundManager.shared.playDelete()
                        Analytics.itemDeleted()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if selectedItem?.id == item.id {
                                selectedItem = nil
                            }
                            modelContext.delete(item)
                            do {
                                try modelContext.save()
                            } catch {
                                showDeleteError = true
                            }
                        }
                    } label: {
                        Label("delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        editingItem = item
                    } label: {
                        Label("edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
    }

    private var totalDailyCost: Double {
        items.reduce(0) { $0 + $1.dailyCost }
    }

    private var totalMonthly: Double {
        totalDailyCost * 30
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    // MARK: - CSV Export

    private func exportCSV() {
        let header = "Name,Price,Purchase Date,Category,Days Owned,Daily Cost,Monthly Cost,Yearly Cost,Uses,Cost Per Use,Worth Score\n"
        let rows = sortedItems.map { item in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let date = dateFormatter.string(from: item.purchaseDate)
            let cpuStr = item.costPerUse.map { String(format: "%.2f", $0) } ?? ""
            return "\"\(item.name)\",\(item.price),\(date),\(item.category.rawValue),\(item.daysOwned),\(String(format: "%.2f", item.dailyCost)),\(String(format: "%.2f", item.monthlyCost)),\(String(format: "%.2f", item.yearlyCost)),\(item.useCount),\(cpuStr),\(item.worthScore)"
        }.joined(separator: "\n")

        let csv = header + rows
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("ThingCost_Export.csv")
        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            csvExportURL = tempURL
            showExportShareSheet = true
            Analytics.csvExported()
        } catch {
            showExportError = true
        }
    }
}

// MARK: - Share Sheet for CSV

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

#Preview {
    ItemListView()
        .environment(StoreService.shared)
        .modelContainer(for: Item.self, inMemory: true)
}
