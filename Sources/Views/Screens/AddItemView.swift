import PhotosUI
import SwiftData
import SwiftUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreService.self) private var store

    @State private var name = ""
    @State private var priceText = ""
    @State private var purchaseDate = Date()
    @State private var category: ItemCategory = .other
    @State private var iconName = "bag.fill"
    @State private var showingSoftPaywall = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var photoImage: Image?
    @State private var showingPaywall = false
    @State private var warrantyDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var hasWarranty = false
    @State private var selectedReceiptItem: PhotosPickerItem?
    @State private var receiptData: Data?
    @State private var receiptImage: Image?

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
                    Section("preview") {
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
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: priceText)
            .navigationTitle("add_item")
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
                        addItem()
                    } label: {
                        Label("Add item", systemImage: "plus")
                            .labelStyle(.titleOnly)
                    }
                    .disabled(!isValid)
                    .bold()
                    .accessibilityIdentifier("confirmAddButton")
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

    /// Downsample image data to reduce storage size
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

    private func addItem() {
        guard let price = Double(priceText), price > 0 else { return }

        let item = Item(
            name: name.trimmingCharacters(in: .whitespaces),
            price: price,
            purchaseDate: purchaseDate,
            category: category,
            iconName: category.defaultIcon,
            photoData: photoData,
            receiptData: receiptData,
            warrantyExpirationDate: hasWarranty ? warrantyDate : nil
        )

        do {
            modelContext.insert(item)
            try modelContext.save()
            Analytics.itemAdded(category: category.rawValue, daysOwned: item.daysOwned)
            ReviewManager.shared.recordItemAdded()
            AddFirstItemTip.hasAddedItem = true
        } catch {
            showError = true
            errorMessage = "Couldn't save your item. Please try again."
            return
        }

        // Soft paywall trigger
        let trigger = PaywallTrigger.shared
        trigger.recordItemAdded()
        if trigger.shouldShowSoftPaywall(isPro: store.isPro) {
            trigger.recordPaywallShown()
            // Dismiss AddItemView first, then show paywall from parent
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: .showPaywall, object: nil)
            }
        } else {
            dismiss()
        }
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: Item.self, inMemory: true)
}
