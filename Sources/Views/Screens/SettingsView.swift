import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("streakAlertsEnabled") private var streakAlertsEnabled = true
    @Environment(StoreService.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showingPaywall = false
    @State private var notificationsAuthorized = false

    private let streakManager = StreakManager.shared
    private let achievementManager = AchievementManager.shared

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .system
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(AppTheme.allCases) { theme in
                        let isLocked = theme.isProOnly && !store.isPro
                        Button {
                            if isLocked {
                                showingPaywall = true
                            } else {
                                HapticManager.shared.selection()
                                appTheme = theme.rawValue
                            }
                        } label: {
                            HStack {
                                Label {
                                    Text(theme.displayName)
                                } icon: {
                                    Image(systemName: theme.iconName)
                                }
                                .foregroundStyle(isLocked ? .secondary : .primary)

                                Spacer()

                                if isLocked {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lock.fill")
                                            .font(.caption2)
                                        Text("Pro")
                                            .font(.caption.weight(.semibold))
                                    }
                                    .foregroundStyle(.blue)
                                } else if selectedTheme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .accessibilityLabel("\(String(localized: theme.displayName)) theme")
                    }
                } header: {
                    Text("appearance")
                }

                // MARK: - Streak & Achievements

                Section {
                    HStack {
                        Label {
                            Text("Current Streak")
                        } icon: {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                        }
                        Spacer()
                        Text("\(streakManager.currentStreak) days")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label {
                            Text("Longest Streak")
                        } icon: {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                        }
                        Spacer()
                        Text("\(streakManager.longestStreak) days")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label {
                            Text("Achievements")
                        } icon: {
                            Image(systemName: "medal.fill")
                                .foregroundStyle(.purple)
                        }
                        Spacer()
                        Text("\(achievementManager.unlockedCount)/\(Achievement.allCases.count)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Progress")
                }

                // MARK: - Notifications

                Section {
                    Toggle(isOn: $dailyReminderEnabled) {
                        Label {
                            Text("Daily Reminder")
                        } icon: {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    .accessibilityLabel("Enable daily reminder notification")
                    .onChange(of: dailyReminderEnabled) { _, enabled in
                        if enabled {
                            Task {
                                let granted = await NotificationManager.shared.requestPermission()
                                if granted {
                                    NotificationManager.shared.scheduleDailyReminder()
                                    notificationsAuthorized = true
                                } else {
                                    dailyReminderEnabled = false
                                }
                            }
                        } else {
                            NotificationManager.shared.cancelDailyReminder()
                        }
                    }

                    Toggle(isOn: $streakAlertsEnabled) {
                        Label {
                            Text("Streak Alerts")
                        } icon: {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .accessibilityLabel("Enable streak alert notifications")
                    .onChange(of: streakAlertsEnabled) { _, enabled in
                        if !enabled {
                            NotificationManager.shared.cancelStreakAtRisk()
                        }
                    }

                    if !notificationsAuthorized {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text("Notifications may be disabled in Settings")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Notifications")
                }

                if !store.isUnlimited {
                    Section {
                        Button {
                            HapticManager.shared.tap()
                            showingPaywall = true
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
                        .accessibilityLabel("Unlock unlimited items")
                    } header: {
                        Text("settings_purchase")
                    }
                }

                Section {
                    Button {
                        HapticManager.shared.tap()
                        Task { await store.restore() }
                    } label: {
                        Label {
                            Text("paywall_restore")
                        } icon: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .accessibilityLabel("Restore previous purchases")
                } header: {
                    Text("settings_purchases")
                }

                Section {
                    if let privacyURL = URL(string: "https://theknack2020-sketch.github.io/ThingCost/privacy") {
                        Link(destination: privacyURL) {
                            Label {
                                Text("privacy_policy")
                            } icon: {
                                Image(systemName: "hand.raised.fill")
                            }
                        }
                        .accessibilityLabel("Open privacy policy")
                    }

                    if let termsURL = URL(string: "https://theknack2020-sketch.github.io/ThingCost/terms") {
                        Link(destination: termsURL) {
                            Label {
                                Text("terms_of_use")
                            } icon: {
                                Image(systemName: "doc.text.fill")
                            }
                        }
                        .accessibilityLabel("Open terms of use")
                    }

                    if let mailURL = URL(string: "mailto:support@theknack.dev") {
                        Link(destination: mailURL) {
                            Label {
                                Text("contact_us")
                            } icon: {
                                Image(systemName: "envelope.fill")
                            }
                        }
                        .accessibilityLabel("Contact support via email")
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

                // MARK: - Cross-Promo

                Section {
                    moreAppsRow(
                        name: "WrenchLog",
                        icon: "wrench.and.screwdriver.fill",
                        color: .orange,
                        subtitle: "Vehicle maintenance tracker",
                        appStoreID: "6746599498"
                    )
                    moreAppsRow(
                        name: "PillPal",
                        icon: "pills.fill",
                        color: .green,
                        subtitle: "Medication reminders",
                        appStoreID: "6740702498"
                    )
                    moreAppsRow(
                        name: "Vettie",
                        icon: "pawprint.fill",
                        color: .blue,
                        subtitle: "Pet health & vet records",
                        appStoreID: "6746209498"
                    )
                } header: {
                    Label("More Apps by TheKnack", systemImage: "apps.iphone")
                } footer: {
                    Text("Built with care for people who like simple, beautiful apps.")
                }
            }
            .navigationTitle("settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPaywall) {
                PaywallView(store: store)
            }
            .task {
                notificationsAuthorized = await NotificationManager.shared.isAuthorized()
                Analytics.screenViewed(.settings)
            }
        }
    }
}

extension Notification.Name {
    static let showPaywall = Notification.Name("showPaywall")
    static let openAddItemAfterOnboarding = Notification.Name("openAddItemAfterOnboarding")
}

// MARK: - Cross-Promo Row

private extension SettingsView {
    func moreAppsRow(
        name: String,
        icon: String,
        color: Color,
        subtitle: String,
        appStoreID: String
    ) -> some View {
        Button {
            HapticManager.shared.tap()
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appStoreID)") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(color.gradient, in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .accessibilityLabel("Open \(name) on the App Store")
    }
}

#Preview {
    SettingsView()
        .environment(StoreService.shared)
}
