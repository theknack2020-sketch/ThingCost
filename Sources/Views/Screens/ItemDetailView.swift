import SwiftUI
import Charts

struct ItemDetailView: View {
    let item: Item
    @State private var showingEditSheet = false
    @State private var showingShareSheet = false
    @Environment(\.dismiss) private var dismiss

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                costBreakdownCard
                costChartCard
                milestonesCard
            }
            .padding()
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        showingShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Button("edit") {
                        showingEditSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditItemView(item: item)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareCardPreviewView(item: item)
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: item.iconName)
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(item.category.color.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Text(item.dailyCost, format: .currency(code: currencyCode))
                .font(.system(size: 44, weight: .bold, design: .rounded))

            Text("per_day")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Cost Breakdown

    private var costBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("cost_breakdown")
                .font(.headline)

            costRow("purchase_price", value: item.price)
            costRow("days_owned", text: item.daysOwned.dayLabel)
            Divider()
            costRow("daily", value: item.dailyCost)
            costRow("monthly", value: item.monthlyCost)
            costRow("yearly", value: item.yearlyCost)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func costRow(_ label: LocalizedStringKey, value: Double) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value, format: .currency(code: currencyCode))
                .fontWeight(.medium)
        }
    }

    private func costRow(_ label: LocalizedStringKey, text: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(text)
                .fontWeight(.medium)
        }
    }

    // MARK: - Chart

    private var costChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("cost_over_time")
                .font(.headline)

            Chart(chartData, id: \.day) { point in
                LineMark(
                    x: .value(String(localized: "chart_day"), point.day),
                    y: .value(String(localized: "chart_cost"), point.cost)
                )
                .foregroundStyle(item.category.color.gradient)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value(String(localized: "chart_day"), point.day),
                    y: .value(String(localized: "chart_cost"), point.cost)
                )
                .foregroundStyle(item.category.color.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)

                if point.day == item.daysOwned {
                    PointMark(
                        x: .value(String(localized: "chart_day"), point.day),
                        y: .value(String(localized: "chart_cost"), point.cost)
                    )
                    .foregroundStyle(item.category.color)
                    .symbolSize(60)
                    .annotation(position: .top) {
                        Text("today")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartXAxisLabel(String(localized: "chart_days_axis"))
            .chartYAxisLabel(String(localized: "chart_cost_axis"))
            .frame(height: 200)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var chartData: [CostPoint] {
        let totalDays = max(item.daysOwned * 2, 365)
        let step = max(totalDays / 50, 1)
        var points: [CostPoint] = []

        for day in stride(from: 1, through: totalDays, by: step) {
            points.append(CostPoint(day: day, cost: item.price / Double(day)))
        }

        if !points.contains(where: { $0.day == item.daysOwned }) {
            points.append(CostPoint(day: item.daysOwned, cost: item.dailyCost))
            points.sort { $0.day < $1.day }
        }

        return points
    }

    // MARK: - Milestones

    private var milestonesCard: some View {
        Group {
            if !item.costMilestones.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("future_projections")
                        .font(.headline)

                    ForEach(item.costMilestones, id: \.days) { milestone in
                        HStack {
                            Text(milestone.label)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(milestone.cost, format: .currency(code: currencyCode))
                                .fontWeight(.medium)
                            Text("per_day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

struct CostPoint {
    let day: Int
    let cost: Double
}
