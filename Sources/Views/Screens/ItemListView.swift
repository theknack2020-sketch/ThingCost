import SwiftUI
import SwiftData

struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.price, order: .reverse) private var items: [Item]
    @State private var showingAddSheet = false

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
            ForEach(items) { item in
                NavigationLink(value: item) {
                    ItemRowView(item: item)
                }
            }
            .onDelete(perform: deleteItems)
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

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

#Preview {
    ItemListView()
        .modelContainer(for: Item.self, inMemory: true)
}
