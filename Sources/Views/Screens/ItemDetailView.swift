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
                    Button("Edit") {
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
                .background(categoryColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Text(item.dailyCost, format: .currency(code: currencyCode))
                .font(.system(size: 44, weight: .bold, design: .rounded))

            Text("per day")
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
            Text("Cost Breakdown")
                .font(.headline)

            costRow("Purchase Price", value: item.price)
            costRow("Days Owned", text: "\(item.daysOwned)")
            Divider()
            costRow("Daily", value: item.dailyCost)
            costRow("Monthly", value: item.monthlyCost)
            costRow("Yearly", value: item.yearlyCost)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func costRow(_ label: String, value: Double) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value, format: .currency(code: currencyCode))
                .fontWeight(.medium)
        }
    }

    private func costRow(_ label: String, text: String) -> some View {
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
            Text("Cost Over Time")
                .font(.headline)

            Chart(chartData, id: \.day) { point in
                LineMark(
                    x: .value("Day", point.day),
                    y: .value("Cost", point.cost)
                )
                .foregroundStyle(categoryColor.gradient)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Day", point.day),
                    y: .value("Cost", point.cost)
                )
                .foregroundStyle(categoryColor.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)

                if point.day == item.daysOwned {
                    PointMark(
                        x: .value("Day", point.day),
                        y: .value("Cost", point.cost)
                    )
                    .foregroundStyle(categoryColor)
                    .symbolSize(60)
                    .annotation(position: .top) {
                        Text("Today")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartXAxisLabel("Days")
            .chartYAxisLabel("Cost/Day")
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

        // Ensure current day is included
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
                    Text("Future Projections")
                        .font(.headline)

                    ForEach(item.costMilestones, id: \.days) { milestone in
                        HStack {
                            Text(milestone.label)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(milestone.cost, format: .currency(code: currencyCode))
                                .fontWeight(.medium)
                            Text("/day")
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

    private var categoryColor: Color {
        switch item.category {
        case .electronics: return .blue
        case .clothing: return .purple
        case .furniture: return .orange
        case .vehicle: return .red
        case .sports: return .green
        case .kitchen: return .yellow
        case .accessories: return .pink
        case .other: return .gray
        }
    }
}

struct CostPoint {
    let day: Int
    let cost: Double
}
