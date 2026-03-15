import SwiftUI
import SwiftData

struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]
    @State private var showingAddSheet = false
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
            .navigationTitle("ThingCost")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !items.isEmpty {
                        sortMenu
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddItemView()
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item)
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
                        Label(option.rawValue, systemImage: "checkmark")
                    } else {
                        Text(option.rawValue)
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Items Yet", systemImage: "bag")
        } description: {
            Text("Add your first purchase to see its daily cost.")
        } actions: {
            Button("Add Item") {
                showingAddSheet = true
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
                    Text("Total Daily Cost")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(totalDailyCost, format: .currency(code: currencyCode))
                        .font(.title.bold())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(items.count) items")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(totalMonthly, format: .currency(code: currencyCode))/mo")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var itemsSection: some View {
        Section("Items") {
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
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            editingItem = item
                        } label: {
                            Label("Edit", systemImage: "pencil")
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
        .modelContainer(for: Item.self, inMemory: true)
}
