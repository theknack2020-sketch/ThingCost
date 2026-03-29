import SwiftUI

enum ShareCardStyle: String, CaseIterable, Identifiable {
    case minimal
    case bold
    case gradient

    var id: String {
        rawValue
    }

    var displayName: LocalizedStringResource {
        switch self {
        case .minimal: "style_minimal"
        case .bold: "style_bold"
        case .gradient: "style_gradient"
        }
    }
}

struct ShareCardView: View {
    let item: Item
    let style: ShareCardStyle
    let currencyCode: String

    init(item: Item, style: ShareCardStyle = .minimal, currencyCode: String? = nil) {
        self.item = item
        self.style = style
        self.currencyCode = currencyCode ?? Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        Group {
            switch style {
            case .minimal:
                minimalCard
            case .bold:
                boldCard
            case .gradient:
                gradientCard
            }
        }
        .frame(width: 390, height: 500)
    }

    // MARK: - Minimal Style

    private var minimalCard: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: item.iconName)
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)

                Text(item.name)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.primary)
            }

            Spacer()

            VStack(spacing: 4) {
                Text(item.dailyCost, format: .currency(code: currencyCode))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("per_day")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("bought_for")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(item.price, format: .currency(code: currencyCode))
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("owned_for")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(item.daysOwned.dayLabel)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)

            // Worth badge
            WorthBadge(score: item.worthScore, label: item.worthLabel, color: item.worthColor)
                .padding(.top, 4)

            Spacer()

            Text("ThingCost")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.tertiary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - Bold Style

    private var boldCard: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(item.category.color.gradient)
                .frame(height: 8)

            Spacer()

            VStack(spacing: 16) {
                Image(systemName: item.iconName)
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(item.category.color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: item.category.color.opacity(0.4), radius: 12, y: 6)

                Text(item.name)
                    .font(.title2.weight(.bold))

                Text("costs_me")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Text(item.dailyCost, format: .currency(code: currencyCode))
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .foregroundStyle(item.category.color)

                Text("per_day")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 32) {
                statBubble(label: String(localized: "price_label"), value: item.price, format: .currency(code: currencyCode))
                statBubble(label: String(localized: "days_label"), text: item.daysOwned.dayLabel)
                statBubble(label: String(localized: "monthly_label"), value: item.monthlyCost, format: .currency(code: currencyCode))
            }
            .padding(.horizontal, 20)

            Spacer()

            Text("ThingCost")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private func statBubble(label: String, value: Double, format: FloatingPointFormatStyle<Double>.Currency) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Text(value, format: format)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }

    private func statBubble(label: String, text: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Gradient Style

    private var gradientCard: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: item.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.9))

                Text(item.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(spacing: 4) {
                Text(item.dailyCost, format: .currency(code: currencyCode))
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("per_day")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.price, format: .currency(code: currencyCode))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("purchase_price_label")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.daysOwned.dayLabel)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("owned_label")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            Text("ThingCost")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [item.category.color, item.category.color.opacity(0.7), item.category.color.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview("Minimal") {
    ShareCardView(
        item: Item(name: "iPhone 15 Pro", price: 64999, purchaseDate: Calendar.current.date(byAdding: .day, value: -180, to: Date()) ?? Date(), category: .electronics),
        style: .minimal
    )
    .padding()
    .background(.gray.opacity(0.2))
}

#Preview("Bold") {
    ShareCardView(
        item: Item(name: "Nike Air Max", price: 4999, purchaseDate: Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date(), category: .clothing),
        style: .bold
    )
    .padding()
    .background(.gray.opacity(0.2))
}

#Preview("Gradient") {
    ShareCardView(
        item: Item(name: "MacBook Pro", price: 84999, purchaseDate: Calendar.current.date(byAdding: .day, value: -365, to: Date()) ?? Date(), category: .electronics),
        style: .gradient
    )
    .padding()
    .background(.gray.opacity(0.2))
}
