import SwiftUI
import SwiftData

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item

    @State private var name: String
    @State private var priceText: String
    @State private var purchaseDate: Date
    @State private var category: ItemCategory

    init(item: Item) {
        self.item = item
        _name = State(initialValue: item.name)
        _priceText = State(initialValue: String(format: "%.2f", item.price))
        _purchaseDate = State(initialValue: item.purchaseDate)
        _category = State(initialValue: item.category)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("item_details") {
                    TextField("item_name", text: $name)

                    HStack {
                        Text(currencySymbol)
                            .foregroundStyle(.secondary)
                        TextField("item_price", text: $priceText)
                            .keyboardType(.decimalPad)
                    }

                    DatePicker("purchase_date", selection: $purchaseDate, in: ...Date(), displayedComponents: .date)
                }

                Section("category") {
                    Picker("category", selection: $category) {
                        ForEach(ItemCategory.allCases) { cat in
                            Label { Text(cat.displayName) } icon: { Image(systemName: cat.iconName) }
                                .tag(cat)
                        }
                    }
                }

                if let price = Double(priceText), price > 0 {
                    Section("current_cost") {
                        let daysOwned = max(Calendar.current.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 1, 1)
                        let dailyCost = price / Double(daysOwned)

                        HStack {
                            Text("daily_cost")
                            Spacer()
                            Text(dailyCost, format: .currency(code: currencyCode))
                                .bold()
                        }

                        HStack {
                            Text("days_owned")
                            Spacer()
                            Text(daysOwned.dayLabel)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("edit_item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") { saveItem() }
                        .disabled(!isValid)
                        .bold()
                }
            }
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(priceText) != nil &&
        Double(priceText)! > 0
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var currencySymbol: String {
        Locale.current.currencySymbol ?? "$"
    }

    private func saveItem() {
        guard let price = Double(priceText), price > 0 else { return }
        item.name = name.trimmingCharacters(in: .whitespaces)
        item.price = price
        item.purchaseDate = purchaseDate
        item.category = category
        item.iconName = category.defaultIcon
        dismiss()
    }
}
