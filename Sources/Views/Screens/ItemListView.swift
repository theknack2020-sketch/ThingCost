import SwiftUI
import SwiftData

struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]
    @Environment(StoreService.self) private var store
    @State private var showingAddSheet = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var sortOption: SortOption = .dailyCostHigh
    @State private var editingItem: Item?
    @State private var selectedItem: Item?

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

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyState
                } else {
                    itemList
                }
            }
            .navigationTitle("app_name")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 4) {
                        if !items.isEmpty {
                            sortMenu
                        }
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityIdentifier("settingsButton")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.canAddItem(currentCount: items.count) {
                            showingAddSheet = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .accessibilityIdentifier("addButton")
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
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationDestination(item: $selectedItem) { item in
                ItemDetailView(item: item)
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button {
                    withAnimation { sortOption = option }
                } label: {
                    if sortOption == option {
                        Label { Text(option.displayName) } icon: { Image(systemName: "checkmark") }
                    } else {
                        Text(option.displayName)
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
        .accessibilityIdentifier("sortButton")
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("no_items_title", systemImage: "bag")
        } description: {
            Text("no_items_desc")
        } actions: {
            Button("add_item") {
                if store.canAddItem(currentCount: items.count) {
                    showingAddSheet = true
                } else {
                    showingPaywall = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var itemList: some View {
        List {
            totalSection
            itemsSection
        }
    }

    private var totalSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("total_daily_cost")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(totalDailyCost.compactCurrency(code: currencyCode))
                        .font(.title.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    if store.isUnlimited {
                        Text("items_count \(items.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("free_count \(items.count)")
                            .font(.subheadline)
                            .foregroundStyle(items.count >= 3 ? .orange : .secondary)
                    }
                    Text("\(totalMonthly.compactCurrency(code: currencyCode))\(String(localized: "per_month"))")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var itemsSection: some View {
        Section("items_section") {
            ForEach(sortedItems) { item in
                ItemRowView(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedItem = item
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                modelContext.delete(item)
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
}

#Preview {
    ItemListView()
        .environment(StoreService.shared)
        .modelContainer(for: Item.self, inMemory: true)
}
