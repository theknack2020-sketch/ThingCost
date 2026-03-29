import PhotosUI
import SwiftData
import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(StoreService.self) private var store
    @Bindable var item: Item

    @State private var name: String
    @State private var priceText: String
    @State private var purchaseDate: Date
    @State private var category: ItemCategory
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var photoImage: Image?
    @State private var showingPaywall = false
    @State private var hasWarranty: Bool
    @State private var warrantyDate: Date
    @State private var selectedReceiptItem: PhotosPickerItem?
    @State private var receiptData: Data?
    @State private var receiptImage: Image?

    init(item: Item) {
        self.item = item
        _name = State(initialValue: item.name)
        _priceText = State(initialValue: String(format: "%.2f", item.price))
        _purchaseDate = State(initialValue: item.purchaseDate)
        _category = State(initialValue: item.category)
        _photoData = State(initialValue: item.photoData)
        _hasWarranty = State(initialValue: item.warrantyExpirationDate != nil)
        let defaultWarrantyDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        _warrantyDate = State(initialValue: item.warrantyExpirationDate ?? defaultWarrantyDate)
        _receiptData = State(initialValue: item.receiptData)
        if let data = item.photoData, let uiImage = UIImage(data: data) {
            _photoImage = State(initialValue: Image(uiImage: uiImage))
        }
        if let data = item.receiptData, let uiImage = UIImage(data: data) {
            _receiptImage = State(initialValue: Image(uiImage: uiImage))
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("item_details") {
                    TextField("item_name", text: $name)
                        .accessibilityLabel("Item name")

                    HStack {
                        Text(currencySymbol)
                            .foregroundStyle(.secondary)
                        TextField("item_price", text: $priceText)
                            .keyboardType(.decimalPad)
                            .accessibilityLabel("Purchase price")
                    }

                    DatePicker("purchase_date", selection: $purchaseDate, in: ...Date(), displayedComponents: .date)
                        .accessibilityLabel("Purchase date")
                        .onChange(of: purchaseDate) { _, _ in
                            HapticManager.shared.selection()
                        }
                }

                Section("category") {
                    Picker("category", selection: $category) {
                        ForEach(ItemCategory.allCases) { cat in
                            Label { Text(cat.displayName) } icon: { Image(systemName: cat.iconName) }
                                .tag(cat)
                        }
                    }
                    .accessibilityLabel("Item category")
                    .onChange(of: category) { _, _ in
                        HapticManager.shared.selection()
                    }
                }

                // MARK: - Photo Section

                Section {
                    if let photoImage {
                        photoImage
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    HapticManager.shared.tap()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedPhotoItem = nil
                                        photoData = nil
                                        self.photoImage = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 4)
                                }
                                .padding(8)
                                .accessibilityLabel("Remove photo")
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    }

                    if store.canAttachPhoto {
                        let photoLabel = photoData == nil ? "Add Photo" : "Change Photo"
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label(photoLabel, systemImage: "camera.fill")
                        }
                        .accessibilityLabel("Add a photo of this item")
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Label("Add Photo", systemImage: "camera.fill")
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.fill")
                                        .font(.caption2)
                                    Text("Pro")
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(.blue)
                            }
                        }
                        .accessibilityLabel("Add photo, requires Pro")
                    }
                } header: {
                    Text("Photo")
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        guard let newItem else { return }
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            let downsampledData = downsampleImageData(data, maxDimension: 800)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                photoData = downsampledData
                                if let uiImage = UIImage(data: downsampledData) {
                                    photoImage = Image(uiImage: uiImage)
                                }
                            }
                        }
                    }
                }

                // MARK: - Warranty Section

                Section {
                    Toggle("Warranty", isOn: $hasWarranty.animation(.spring(response: 0.3, dampingFraction: 0.8)))
                        .accessibilityLabel("Has warranty")

                    if hasWarranty {
                        DatePicker("Expires", selection: $warrantyDate, in: Date()..., displayedComponents: .date)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                } header: {
                    Text("Warranty")
                } footer: {
                    if hasWarranty {
                        Text("You'll be notified before warranty expires.")
                    }
                }

                // MARK: - Receipt Section

                Section {
                    if let receiptImage {
                        receiptImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    HapticManager.shared.tap()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedReceiptItem = nil
                                        receiptData = nil
                                        self.receiptImage = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 4)
                                }
                                .padding(8)
                                .accessibilityLabel("Remove receipt")
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    }

                    let receiptLabel = receiptData == nil ? "Add Receipt" : "Change Receipt"
                    PhotosPicker(selection: $selectedReceiptItem, matching: .images) {
                        Label(receiptLabel, systemImage: "doc.text.fill")
                    }
                    .accessibilityLabel("Add a receipt or invoice photo")
                } header: {
                    Text("Receipt / Invoice")
                }
                .onChange(of: selectedReceiptItem) { _, newItem in
                    Task {
                        guard let newItem else { return }
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            let downsampledData = downsampleImageData(data, maxDimension: 1200)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                receiptData = downsampledData
                                if let uiImage = UIImage(data: downsampledData) {
                                    receiptImage = Image(uiImage: uiImage)
                                }
                            }
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
                                .foregroundStyle(Color.accentColor)
                                .contentTransition(.numericText())
                        }

                        HStack {
                            Text("days_owned")
                            Spacer()
                            Text(daysOwned.dayLabel)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [.blue.opacity(0.08), .purple.opacity(0.05)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: priceText)
            .navigationTitle("edit_item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        HapticManager.shared.tap()
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                            .labelStyle(.titleOnly)
                    }
                    .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        HapticManager.shared.save()
                        SoundManager.shared.playSave()
                        saveItem()
                    } label: {
                        Label("Save changes", systemImage: "checkmark")
                            .labelStyle(.titleOnly)
                    }
                    .disabled(!isValid)
                    .bold()
                    .accessibilityIdentifier("confirmSaveButton")
                }
            }
            .alert("error_title", isPresented: $showError) {
                Button("error_ok", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView(store: store)
            }
        }
    }

    private var isValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, let price = Double(priceText) else { return false }
        return price > 0
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var currencySymbol: String {
        Locale.current.currencySymbol ?? "$"
    }

    private func downsampleImageData(_ data: Data, maxDimension: CGFloat) -> Data {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return data }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return data }
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage.jpegData(compressionQuality: 0.8) ?? data
    }

    private func saveItem() {
        guard let price = Double(priceText), price > 0 else { return }
        item.name = name.trimmingCharacters(in: .whitespaces)
        item.price = price
        item.purchaseDate = purchaseDate
        item.category = category
        item.iconName = category.defaultIcon
        item.photoData = photoData
        item.receiptData = receiptData
        item.warrantyExpirationDate = hasWarranty ? warrantyDate : nil
        do {
            try modelContext.save()
            Analytics.itemEdited()
        } catch {
            showError = true
            errorMessage = "Couldn't update your item. Please try again."
            return
        }
        dismiss()
    }
}
