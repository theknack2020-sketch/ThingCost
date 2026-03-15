import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue
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

#Preview {
    SettingsView()
}
