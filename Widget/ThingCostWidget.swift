import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Provider

struct CostEntry: TimelineEntry {
    let date: Date
    let items: [WidgetItem]

    struct WidgetItem: Identifiable {
        let id: UUID
        let name: String
        let iconName: String
        let dailyCost: Double
        let daysOwned: Int
        let categoryRaw: String
    }
}

struct CostTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CostEntry {
        CostEntry(date: .now, items: Self.sampleItems)
    }

    func getSnapshot(in context: Context, completion: @escaping (CostEntry) -> Void) {
        if context.isPreview {
            completion(CostEntry(date: .now, items: Self.sampleItems))
        } else {
            let items = fetchItems()
            completion(CostEntry(date: .now, items: items))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CostEntry>) -> Void) {
        let items = fetchItems()
        let entry = CostEntry(date: .now, items: items)

        // Refresh once per day (daily cost changes daily)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchItems() -> [CostEntry.WidgetItem] {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: Item.self, configurations: config)
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<Item>()
            let items = try context.fetch(descriptor)

            return items
                .map { item in
                    CostEntry.WidgetItem(
                        id: UUID(),
                        name: item.name,
                        iconName: item.iconName,
                        dailyCost: item.dailyCost,
                        daysOwned: item.daysOwned,
                        categoryRaw: item.category.rawValue
                    )
                }
                .sorted { $0.dailyCost > $1.dailyCost }
        } catch {
            return []
        }
    }

    static let sampleItems: [CostEntry.WidgetItem] = [
        .init(id: UUID(), name: "iPhone", iconName: "laptopcomputer", dailyCost: 3.8, daysOwned: 180, categoryRaw: "Electronics"),
        .init(id: UUID(), name: "Nike Air Max", iconName: "tshirt.fill", dailyCost: 1.2, daysOwned: 90, categoryRaw: "Clothing"),
        .init(id: UUID(), name: "Office Chair", iconName: "sofa.fill", dailyCost: 0.8, daysOwned: 365, categoryRaw: "Furniture"),
    ]
}

// MARK: - Widget Views

struct SmallWidgetView: View {
    let entry: CostEntry

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "tag.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text("ThingCost")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if let topItem = entry.items.first {
                VStack(alignment: .leading, spacing: 2) {
                    Text(topItem.name)
                        .font(.callout.weight(.medium))
                        .lineLimit(1)

                    Text(topItem.dailyCost, format: .currency(code: currencyCode))
                        .font(.title2.bold())

                    Text("/day")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Add items to track")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(4)
    }
}

struct MediumWidgetView: View {
    let entry: CostEntry

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var totalDaily: Double {
        entry.items.reduce(0) { $0 + $1.dailyCost }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left: total
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("ThingCost")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(totalDaily, format: .currency(code: currencyCode))
                    .font(.title.bold())
                Text("total/day")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Divider
            Rectangle()
                .fill(.quaternary)
                .frame(width: 1)
                .padding(.vertical, 8)

            // Right: top items
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(entry.items.prefix(3))) { item in
                    HStack(spacing: 6) {
                        Image(systemName: item.iconName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 14)

                        Text(item.name)
                            .font(.caption)
                            .lineLimit(1)

                        Spacer()

                        Text(item.dailyCost, format: .currency(code: currencyCode))
                            .font(.caption.weight(.semibold))
                    }
                }

                if entry.items.isEmpty {
                    Text("No items yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(4)
    }
}

// MARK: - Widget

struct ThingCostWidget: Widget {
    let kind: String = "ThingCostWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CostTimelineProvider()) { entry in
            Group {
                switch entry.widgetFamily {
                case .systemSmall:
                    SmallWidgetView(entry: entry)
                default:
                    MediumWidgetView(entry: entry)
                }
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Costs")
        .description("See the daily cost of your items at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private extension CostEntry {
    var widgetFamily: WidgetFamily {
        .systemMedium // default, overridden by SwiftUI
    }
}

// MARK: - Widget Bundle

@main
struct ThingCostWidgetBundle: WidgetBundle {
    var body: some Widget {
        ThingCostWidget()
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    ThingCostWidget()
} timeline: {
    CostEntry(date: .now, items: CostTimelineProvider.sampleItems)
}

#Preview("Medium", as: .systemMedium) {
    ThingCostWidget()
} timeline: {
    CostEntry(date: .now, items: CostTimelineProvider.sampleItems)
}
