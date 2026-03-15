import SwiftUI

struct ItemRowView: View {
    let item: Item

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: item.iconName)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(item.category.color.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // Name and date
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body.weight(.medium))
                Text(item.daysOwned.dayLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Daily cost
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.dailyCost.compactCurrency(code: currencyCode))
                    .font(.body.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("per_day_short")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }


}
