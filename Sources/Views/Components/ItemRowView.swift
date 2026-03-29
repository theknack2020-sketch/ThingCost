import SwiftUI

struct ItemRowView: View {
    let item: Item

    var body: some View {
        HStack(spacing: 14) {
            // Photo or Icon — larger, more prominent
            itemThumbnail

            // Name, date, and worth badge
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(item.daysOwned.dayLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if item.useCount > 0 {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.quaternary)
                        HStack(spacing: 2) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 9))
                            Text("\(item.useCount)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    if item.isWarrantyActive {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.quaternary)
                        HStack(spacing: 2) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 9))
                            Text("\(item.warrantyDaysRemaining ?? 0)d")
                        }
                        .font(.caption)
                        .foregroundStyle(.green)
                    }

                    if item.hasReceipt {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.blue.opacity(0.6))
                    }
                }

                // Worth badge
                WorthBadge(score: item.worthScore, label: item.worthLabel, color: item.worthColor)
            }

            Spacer()

            // Daily cost
            VStack(alignment: .trailing, spacing: 3) {
                Text(item.dailyCost.compactCurrency(code: currencyCode))
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .contentTransition(.numericText())

                Text("per_day_short")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                if let cpu = item.costPerUse {
                    Text(cpu.compactCurrency(code: currencyCode) + String(localized: "per_use_short"))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name), \(item.dailyCost.compactCurrency(code: currencyCode)) per day, owned \(item.daysOwned) days, worth score \(item.worthScore)")
        .accessibilityHint("Double tap to view details")
        .accessibilityActions {
            Button("Edit") {}
            Button("Delete", role: .destructive) {}
        }
    }

    // MARK: - Thumbnail

    @ViewBuilder
    private var itemThumbnail: some View {
        if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [item.category.color, item.category.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Image(systemName: item.iconName)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white)
            }
            .shadow(color: item.category.color.opacity(0.35), radius: 8, y: 4)
        }
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
}

// MARK: - Worth Badge

struct WorthBadge: View {
    let score: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: worthIcon)
                .font(.system(size: 8, weight: .bold))
            Text("\(score)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 9, weight: .medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.12), in: Capsule())
    }

    private var worthIcon: String {
        switch score {
        case 80 ... 100: "star.fill"
        case 60 ..< 80: "hand.thumbsup.fill"
        case 40 ..< 60: "minus.circle.fill"
        default: "arrow.down.circle.fill"
        }
    }
}
