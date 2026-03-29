import Charts
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]
    @Environment(StoreService.self) private var store

    private let streakManager = StreakManager.shared
    @State private var appeared = false

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if items.isEmpty {
                        emptyDashboard
                    } else {
                        heroCard
                            .cardEntrance(appeared: appeared, delay: 0)

                        warrantyAlertCard
                            .cardEntrance(appeared: appeared, delay: 0.08)

                        categoryBreakdownCard
                            .cardEntrance(appeared: appeared, delay: 0.14)

                        worthOverviewCard
                            .cardEntrance(appeared: appeared, delay: 0.20)

                        topCostliestCard
                            .cardEntrance(appeared: appeared, delay: 0.26)
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
            .onAppear { appeared = true }
        }
    }

    // MARK: - Empty

    private var emptyDashboard: some View {
        ContentUnavailableView {
            Label("No data yet", systemImage: "chart.bar.fill")
        } description: {
            Text("Add items to see your spending dashboard.")
        } actions: {
            // No action here — user adds from Items tab
        }
        .padding(.top, 60)
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Everything You Own")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text(totalDailyCost.compactCurrency(code: currencyCode))
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .contentTransition(.numericText())

                Text("per day")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Divider with gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .primary.opacity(0.1), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)

            // Stats row
            HStack(spacing: 0) {
                statCell(
                    icon: "cube.fill",
                    value: "\(items.count)",
                    label: "Items"
                )

                capsuleDivider

                statCell(
                    icon: "calendar",
                    value: totalMonthly.compactCurrency(code: currencyCode),
                    label: "Monthly"
                )

                capsuleDivider

                statCell(
                    icon: "flame.fill",
                    value: "\(streakManager.currentStreak)",
                    label: "Streak",
                    tint: .orange
                )
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.06), .purple.opacity(0.04), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: .blue.opacity(0.08), radius: 20, y: 10)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Total daily cost \(totalDailyCost.compactCurrency(code: currencyCode)), \(items.count) items, monthly \(totalMonthly.compactCurrency(code: currencyCode)), streak \(streakManager.currentStreak) days")
    }

    private var capsuleDivider: some View {
        Capsule()
            .fill(.primary.opacity(0.08))
            .frame(width: 1, height: 36)
    }

    private func statCell(icon: String, value: String, label: String, tint: Color = .blue) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(tint)
                .shadow(color: tint.opacity(0.3), radius: 4, y: 2)
            Text(value)
                .font(.headline.monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Warranty Alert

    @ViewBuilder
    private var warrantyAlertCard: some View {
        let expiringItems = items.filter { item in
            guard let days = item.warrantyDaysRemaining, item.isWarrantyActive else { return false }
            return days <= 30
        }.sorted { ($0.warrantyDaysRemaining ?? 0) < ($1.warrantyDaysRemaining ?? 0) }

        if !expiringItems.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .symbolEffect(.pulse, options: .repeating)
                    Text("Warranty Expiring Soon")
                        .font(.headline)
                    Spacer()
                }

                ForEach(expiringItems) { item in
                    HStack(spacing: 10) {
                        Image(systemName: item.iconName)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(item.category.color.gradient, in: RoundedRectangle(cornerRadius: 8))

                        Text(item.name)
                            .font(.subheadline)
                            .lineLimit(1)

                        Spacer()

                        Text("\(item.warrantyDaysRemaining ?? 0) days")
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.orange.opacity(0.12), in: Capsule())
                    }
                }
            }
            .dashboardCard(tintColor: .orange)
        }
    }

    // MARK: - Category Breakdown

    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text("By Category")
                    .font(.headline)
            }

            Chart(categoryData, id: \.category) { data in
                BarMark(
                    x: .value("Cost", data.totalDailyCost),
                    y: .value("Category", String(localized: data.category.displayName))
                )
                .foregroundStyle(data.category.color.gradient)
                .cornerRadius(6)
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let val = value.as(Double.self) {
                            Text(val.compactCurrency(code: currencyCode))
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: CGFloat(max(categoryData.count, 1)) * 40)
        }
        .dashboardCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Category breakdown chart")
    }

    // MARK: - Worth Overview

    private var worthOverviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gauge.with.needle.fill")
                    .font(.caption)
                    .foregroundStyle(averageWorthColor)
                Text("Worth It Overview")
                    .font(.headline)
                Spacer()
                WorthBadge(
                    score: averageWorthScore,
                    label: averageWorthLabel,
                    color: averageWorthColor
                )
            }

            HStack(spacing: 10) {
                worthBucket(icon: "star.fill", label: "Amazing", count: worthCounts.amazing, color: .green)
                worthBucket(icon: "hand.thumbsup.fill", label: "Great", count: worthCounts.great, color: .blue)
                worthBucket(icon: "minus.circle.fill", label: "Decent", count: worthCounts.decent, color: .orange)
                worthBucket(icon: "arrow.down.circle.fill", label: "Low", count: worthCounts.low, color: .red)
            }
        }
        .dashboardCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Worth overview, average score \(averageWorthScore), \(averageWorthLabel)")
    }

    private func worthBucket(icon: String, label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(count > 0 ? color.opacity(0.12) : Color.clear)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(count > 0 ? color : Color.gray.opacity(0.3))
            }
            Text("\(count)")
                .font(.title3.bold().monospacedDigit())
                .foregroundStyle(count > 0 ? .primary : .secondary)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Top Costliest

    private var topCostliestCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                Text("Most Expensive Per Day")
                    .font(.headline)
            }

            ForEach(Array(topItems.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: 10) {
                    // Rank number
                    Text("\(index + 1)")
                        .font(.caption2.weight(.bold).monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 16)

                    if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
                    } else {
                        Image(systemName: item.iconName)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(item.category.color.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: item.category.color.opacity(0.3), radius: 4, y: 2)
                    }

                    Text(item.name)
                        .font(.subheadline)
                        .lineLimit(1)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 1) {
                        Text(item.dailyCost.compactCurrency(code: currencyCode))
                            .font(.subheadline.bold().monospacedDigit())
                        Text("/day")
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                    }
                }
                if index < topItems.count - 1 {
                    Divider().padding(.leading, 62)
                }
            }
        }
        .dashboardCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Most expensive per day: \(topItems.prefix(3).map { "\($0.name), \($0.dailyCost.compactCurrency(code: currencyCode)) per day" }.joined(separator: "; "))")
    }

    // MARK: - Computed Data

    private var totalDailyCost: Double {
        items.reduce(0) { $0 + $1.dailyCost }
    }

    private var totalMonthly: Double {
        totalDailyCost * 30
    }

    private var topItems: [Item] {
        Array(items.sorted { $0.dailyCost > $1.dailyCost }.prefix(5))
    }

    private struct CategoryCost {
        let category: ItemCategory
        let totalDailyCost: Double
    }

    private var categoryData: [CategoryCost] {
        Dictionary(grouping: items, by: \.category)
            .map { CategoryCost(category: $0.key, totalDailyCost: $0.value.reduce(0) { $0 + $1.dailyCost }) }
            .sorted { $0.totalDailyCost > $1.totalDailyCost }
    }

    private var averageWorthScore: Int {
        guard !items.isEmpty else { return 0 }
        return items.reduce(0) { $0 + $1.worthScore } / items.count
    }

    private var averageWorthLabel: String {
        switch averageWorthScore {
        case 80 ... 100: String(localized: "worth_amazing")
        case 60 ..< 80: String(localized: "worth_great")
        case 40 ..< 60: String(localized: "worth_decent")
        case 20 ..< 40: String(localized: "worth_meh")
        default: String(localized: "worth_poor")
        }
    }

    private var averageWorthColor: Color {
        switch averageWorthScore {
        case 80 ... 100: .green
        case 60 ..< 80: .blue
        case 40 ..< 60: .orange
        case 20 ..< 40: .red.opacity(0.8)
        default: .red
        }
    }

    private struct WorthCounts {
        var amazing = 0
        var great = 0
        var decent = 0
        var low = 0
    }

    private var worthCounts: WorthCounts {
        var counts = WorthCounts()
        for item in items {
            switch item.worthScore {
            case 80 ... 100: counts.amazing += 1
            case 60 ..< 80: counts.great += 1
            case 40 ..< 60: counts.decent += 1
            default: counts.low += 1
            }
        }
        return counts
    }
}

// MARK: - Dashboard Card Modifier

private extension View {
    func dashboardCard(tintColor: Color? = nil) -> some View {
        padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                (tintColor ?? .clear).opacity(0.15),
                                lineWidth: tintColor != nil ? 1 : 0
                            )
                    )
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    .shadow(color: .black.opacity(0.02), radius: 2, y: 1)
            }
    }

    func cardEntrance(appeared: Bool, delay: Double) -> some View {
        opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 24)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

#Preview {
    DashboardView()
        .environment(StoreService.shared)
        .modelContainer(for: Item.self, inMemory: true)
}
