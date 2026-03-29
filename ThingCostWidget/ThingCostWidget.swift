import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Entry

struct CostEntry: TimelineEntry {
    let date: Date
    let totalDailyCost: Double
    let totalMonthlyCost: Double
    let itemCount: Int
    let topItems: [(name: String, dailyCost: Double, iconName: String, categoryColor: String)]
    let currencyCode: String
}

// MARK: - Timeline Provider

struct CostProvider: TimelineProvider {
    func placeholder(in context: Context) -> CostEntry {
        CostEntry(
            date: .now,
            totalDailyCost: 12.45,
            totalMonthlyCost: 373.50,
            itemCount: 5,
            topItems: [
                ("iPhone 15 Pro", 3.61, "iphone", "blue"),
                ("MacBook Air", 2.19, "laptopcomputer", "blue"),
                ("Nike Air Max", 1.23, "figure.run", "green")
            ],
            currencyCode: "USD"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CostEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
            return
        }
        let entry = fetchEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CostEntry>) -> Void) {
        let entry = fetchEntry()
        // Refresh once per hour — daily cost changes at midnight
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    @MainActor
    private func fetchEntry() -> CostEntry {
        let currencyCode = Locale.current.currency?.identifier ?? "USD"

        do {
            let container = try ModelContainer(for: Item.self)
            let context = container.mainContext
            let descriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let items = try context.fetch(descriptor)

            let totalDaily = items.reduce(0) { $0 + $1.dailyCost }
            let totalMonthly = totalDaily * 30

            let topItems = items
                .sorted { $0.dailyCost > $1.dailyCost }
                .prefix(3)
                .map { (name: $0.name, dailyCost: $0.dailyCost, iconName: $0.iconName, categoryColor: $0.category.rawValue) }

            return CostEntry(
                date: .now,
                totalDailyCost: totalDaily,
                totalMonthlyCost: totalMonthly,
                itemCount: items.count,
                topItems: Array(topItems),
                currencyCode: currencyCode
            )
        } catch {
            return CostEntry(
                date: .now,
                totalDailyCost: 0,
                totalMonthlyCost: 0,
                itemCount: 0,
                topItems: [],
                currencyCode: currencyCode
            )
        }
    }
}

// MARK: - Widget Views

struct SmallWidgetView: View {
    let entry: CostEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "tag.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text("ThingCost")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(entry.totalDailyCost, format: .currency(code: entry.currencyCode))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text("per day · \(entry.itemCount) items")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct MediumWidgetView: View {
    let entry: CostEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left: total cost
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("ThingCost")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(entry.totalDailyCost, format: .currency(code: entry.currencyCode))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text("\(entry.totalMonthlyCost, format: .currency(code: entry.currencyCode))/mo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: top items
            if !entry.topItems.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(entry.topItems.enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 6) {
                            Image(systemName: item.iconName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 16)

                            Text(item.name)
                                .font(.caption)
                                .lineLimit(1)

                            Spacer()

                            Text(item.dailyCost, format: .currency(code: entry.currencyCode))
                                .font(.caption.weight(.semibold))
                                .monospacedDigit()
                        }
                    }

                    if entry.itemCount > 3 {
                        Text("+\(entry.itemCount - 3) more")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Definition

struct ThingCostWidget: Widget {
    let kind = "ThingCostWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CostProvider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                WidgetView(entry: entry)
            } else {
                WidgetView(entry: entry)
                    .padding()
            }
        }
        .configurationDisplayName("Daily Cost")
        .description("See the total daily cost of everything you own.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: CostEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle

@main
struct ThingCostWidgetBundle: WidgetBundle {
    var body: some Widget {
        ThingCostWidget()
    }
}

// MARK: - Preview

#Preview("Small", as: .systemSmall) {
    ThingCostWidget()
} timeline: {
    CostEntry(
        date: .now,
        totalDailyCost: 12.45,
        totalMonthlyCost: 373.50,
        itemCount: 7,
        topItems: [("iPhone", 3.61, "iphone", "blue")],
        currencyCode: "USD"
    )
}

#Preview("Medium", as: .systemMedium) {
    ThingCostWidget()
} timeline: {
    CostEntry(
        date: .now,
        totalDailyCost: 12.45,
        totalMonthlyCost: 373.50,
        itemCount: 7,
        topItems: [
            ("iPhone 15 Pro", 3.61, "iphone", "blue"),
            ("MacBook Air", 2.19, "laptopcomputer", "blue"),
            ("Nike Air Max", 1.23, "figure.run", "green")
        ],
        currencyCode: "USD"
    )
}
