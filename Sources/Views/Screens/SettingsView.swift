import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue
    @Environment(StoreService.self) private var store
    @Environment(\.dismiss) private var dismiss

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .system
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Label {
                                Text(theme.displayName)
                            } icon: {
                                Image(systemName: theme.iconName)
                            }
                            .tag(theme.rawValue)
                        }
                    } label: {
                        Label {
                            Text("theme")
                        } icon: {
                            Image(systemName: "paintbrush.fill")
                        }
                    }
                } header: {
                    Text("appearance")
                }

                if !store.isUnlimited {
                    Section {
                        Button {
                            dismiss()
                            // Small delay so the settings sheet dismisses first
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                NotificationCenter.default.post(name: .showPaywall, object: nil)
                            }
                        } label: {
                            HStack {
                                Label {
                                    Text("settings_unlock")
                                } icon: {
                                    Image(systemName: "lock.open.fill")
                                }
                                Spacer()
                                if let product = store.product {
                                    Text(product.displayPrice)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    } header: {
                        Text("settings_purchase")
                    }
                }

                Section {
                    Button {
                        Task { await store.restore() }
                    } label: {
                        Label {
                            Text("paywall_restore")
                        } icon: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                } header: {
                    Text("settings_purchases")
                }

                Section {
                    Link(destination: URL(string: "https://theknack2020-sketch.github.io/ThingCost/privacy")!) {
                        Label {
                            Text("privacy_policy")
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                        }
                    }

                    Link(destination: URL(string: "https://theknack2020-sketch.github.io/ThingCost/terms")!) {
                        Label {
                            Text("terms_of_use")
                        } icon: {
                            Image(systemName: "doc.text.fill")
                        }
                    }

                    Link(destination: URL(string: "mailto:support@theknack.dev")!) {
                        Label {
                            Text("contact_us")
                        } icon: {
                            Image(systemName: "envelope.fill")
                        }
                    }
                } header: {
                    Text("settings_legal")
                }

                Section {
                    HStack {
                        Text("version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("about")
                }
            }
            .navigationTitle("settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("done") { dismiss() }
                }
            }
        }
    }
}

extension Notification.Name {
    static let showPaywall = Notification.Name("showPaywall")
}

#Preview {
    SettingsView()
        .environment(StoreService.shared)
}
