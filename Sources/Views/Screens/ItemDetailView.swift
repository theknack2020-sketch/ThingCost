import Charts
import SwiftUI
import TipKit

struct ItemDetailView: View {
    let item: Item
    @State private var showingEditSheet = false
    @State private var showingShareSheet = false
    @State private var showingPaywall = false
    @State private var headerAppeared = false
    @State private var logUseScale = 1.0
    @State private var showReceiptFullscreen = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(StoreService.self) private var store

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                worthScoreCard
                    .opacity(headerAppeared ? 1.0 : 0.0)
                    .offset(y: headerAppeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: headerAppeared)

                TipView(LogUseTip())
                    .tipBackground(.blue.opacity(0.06))

                useTrackingCard
                    .opacity(headerAppeared ? 1.0 : 0.0)
                    .offset(y: headerAppeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: headerAppeared)
                costBreakdownCard
                    .opacity(headerAppeared ? 1.0 : 0.0)
                    .offset(y: headerAppeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.25), value: headerAppeared)
                costChartCard
                    .opacity(headerAppeared ? 1.0 : 0.0)
                    .offset(y: headerAppeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: headerAppeared)
                milestonesCard
                    .opacity(headerAppeared ? 1.0 : 0.0)
                    .offset(y: headerAppeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35), value: headerAppeared)

                // Warranty card
                if item.warrantyExpirationDate != nil {
                    warrantyCard
                        .opacity(headerAppeared ? 1.0 : 0.0)
                        .offset(y: headerAppeared ? 0 : 20)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: headerAppeared)
                }

                // Receipt card
                if item.hasReceipt {
                    receiptCard
                        .opacity(headerAppeared ? 1.0 : 0.0)
                        .offset(y: headerAppeared ? 0 : 20)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.45), value: headerAppeared)
                }
            }
            .padding()
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        HapticManager.shared.tap()
                        showingShareSheet = true
                    } label: {
                        Label("Share item cost", systemImage: "square.and.arrow.up")
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityIdentifier("shareButton")
                    .popoverTip(ShareCardTip())
                    Button {
                        HapticManager.shared.tap()
                        showingEditSheet = true
                    } label: {
                        Label("Edit item", systemImage: "pencil")
                            .labelStyle(.titleOnly)
                    }
                    .accessibilityIdentifier("editButton")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditItemView(item: item)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareCardPreviewView(item: item)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(store: store)
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 12) {
            // Photo or Icon
            if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: item.category.color.opacity(0.4), radius: 12, y: 6)
                    .scaleEffect(headerAppeared ? 1.0 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: headerAppeared)
            } else {
                Image(systemName: item.iconName)
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(item.category.color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: item.category.color.opacity(0.5), radius: 12)
                    .scaleEffect(headerAppeared ? 1.0 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: headerAppeared)
                    .accessibilityLabel("\(item.category.rawValue) category icon")
            }

            Text(item.dailyCost, format: .currency(code: currencyCode))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [item.category.color, item.category.color.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .contentTransition(.numericText())
                .scaleEffect(headerAppeared ? 1.0 : 0.8)
                .opacity(headerAppeared ? 1.0 : 0.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: headerAppeared)
                .accessibilityLabel("Daily cost \(item.dailyCost.compactCurrency(code: currencyCode))")

            Text("per_day")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [item.category.color.opacity(0.15), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        .onAppear { headerAppeared = true }
        .onAppear {
            Analytics.screenViewed(.itemDetail)
            LogUseTip.viewCount += 1
            ShareCardTip.viewCount += 1
        }
    }

    // MARK: - Worth Score

    private var worthScoreCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Worth It?")
                    .font(.headline)
                Spacer()
                WorthBadge(score: item.worthScore, label: item.worthLabel, color: item.worthColor)
            }

            // Score ring
            ZStack {
                Circle()
                    .stroke(item.worthColor.opacity(0.15), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(item.worthScore) / 100.0)
                    .stroke(
                        item.worthColor.gradient,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: item.worthScore)

                VStack(spacing: 2) {
                    Text("\(item.worthScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(item.worthColor)
                        .contentTransition(.numericText())
                    Text("of 100")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)

            // Factors breakdown
            HStack(spacing: 16) {
                worthFactor(icon: "calendar", label: "Time", detail: item.daysOwned.dayLabel)
                if item.useCount > 0 {
                    worthFactor(icon: "hand.tap.fill", label: "Uses", detail: "\(item.useCount)")
                }
                worthFactor(icon: "arrow.down.right", label: "Cost/Day", detail: item.dailyCost.compactCurrency(code: currencyCode))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func worthFactor(icon: String, label: String, detail: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Text(detail)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Use Tracking

    private var useTrackingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Usage Tracking")
                    .font(.headline)
                Spacer()
                if item.useCount > 0 {
                    Text("\(item.useCount) uses")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let costPerUse = item.costPerUse {
                HStack {
                    Text("Cost per use")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(costPerUse, format: .currency(code: currencyCode))
                        .fontWeight(.medium)
                        .contentTransition(.numericText())
                }
            }

            // Log Use button
            if store.canLogUses {
                Button {
                    HapticManager.shared.impact(style: .medium)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        item.useCount += 1
                        logUseScale = 1.15
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) {
                        logUseScale = 1.0
                    }
                    try? modelContext.save()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                            .font(.body)
                        Text("Log a Use")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(item.category.color.gradient, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .scaleEffect(logUseScale)
                }
                .shadow(color: item.category.color.opacity(0.3), radius: 8, y: 4)
                .accessibilityLabel("Log a use of this item")
            } else {
                Button {
                    showingPaywall = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("Unlock Use Tracking")
                            .font(.callout.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.blue)
                }
                .accessibilityLabel("Unlock use tracking, requires Pro")
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
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

            if let cpu = item.costPerUse {
                Divider()
                costRow("cost_per_use_label", value: cpu)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func costRow(_ label: LocalizedStringKey, value: Double) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value, format: .currency(code: currencyCode))
                .fontWeight(.medium)
        }
        .accessibilityElement(children: .combine)
    }

    private func costRow(_ label: LocalizedStringKey, text: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(text)
                .fontWeight(.medium)
        }
        .accessibilityElement(children: .combine)
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
            .accessibilityLabel("Cost over time chart")
            .accessibilityElement(children: .ignore)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
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
                        let isLocked = !store.isMilestoneAvailable(days: milestone.days)
                        HStack {
                            Text(milestone.label)
                                .foregroundStyle(isLocked ? .secondary : .secondary)
                            Spacer()
                            if isLocked {
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.fill")
                                        .font(.caption2)
                                    Text("Pro")
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(.blue)
                            } else {
                                Text(milestone.cost, format: .currency(code: currencyCode))
                                    .fontWeight(.medium)
                                Text("per_day")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if !store.isPro {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.open.fill")
                                    .font(.caption)
                                Text("Unlock all projections")
                                    .font(.caption.weight(.medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(.blue)
                        }
                        .accessibilityLabel("Unlock all future projections")
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            }
        }
    }
}

struct CostPoint {
    let day: Int
    let cost: Double
}

// MARK: - Warranty & Receipt Cards

extension ItemDetailView {
    var warrantyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.title3)
                    .foregroundStyle(item.isWarrantyActive ? .green : .red)
                Text("Warranty")
                    .font(.headline)
                Spacer()
                if item.isWarrantyActive {
                    Text("\(item.warrantyDaysRemaining ?? 0) days left")
                        .font(.subheadline.weight(.medium).monospacedDigit())
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.12), in: Capsule())
                } else {
                    Text("Expired")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.red.opacity(0.12), in: Capsule())
                }
            }

            if let expDate = item.warrantyExpirationDate {
                HStack {
                    Text("Expires")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(expDate, style: .date)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    var receiptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
                Text("Receipt")
                    .font(.headline)
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }

            if let receiptData = item.receiptData, let uiImage = UIImage(data: receiptData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        showReceiptFullscreen = true
                    }
                    .accessibilityLabel("Receipt photo, tap to view full screen")
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        .fullScreenCover(isPresented: $showReceiptFullscreen) {
            if let receiptData = item.receiptData, let uiImage = UIImage(data: receiptData) {
                NavigationStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .navigationTitle("Receipt")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button {
                                    showReceiptFullscreen = false
                                } label: {
                                    Label("Done", systemImage: "xmark")
                                        .labelStyle(.titleOnly)
                                }
                            }
                        }
                }
            }
        }
    }
}
