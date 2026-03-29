import SwiftUI

/// Settings tab: simple app info and appearance controls.
struct SettingsView: View {
    @AppStorage("appearance") private var appearance: String = "system"
    @State private var showResetConfirm = false

    var body: some View {
        Form {
            headerSection

            Section("Appearance") {
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
                .tint(DS.Color.accent)

                Text("Choose how the app looks. “System” follows your device setting.")
                    .font(DS.FontToken.body(size: 13))
                    .foregroundStyle(DS.Color.textSecondary)
            }

            Section("About") {
                LabeledContent("Version", value: versionString)
                LabeledContent("Build", value: buildString)

                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("Daily Vocab")
                        .font(DS.FontToken.body(weight: .semibold))
                        .foregroundStyle(DS.Color.textPrimary)
                    Text("A minimal daily vocabulary app with offline words and simple review.")
                        .font(DS.FontToken.body(size: 14))
                        .foregroundStyle(DS.Color.textSecondary)
                }
                .padding(.vertical, 4)
            }

            Section("Links") {
                Link(destination: URL(string: "https://example.com/daily-vocab-site")!) {
                    Label("Website", systemImage: "globe")
                }
//                Link(destination: URL(string: "https://example.com/privacy")!) {
//                    Label("Privacy Policy", systemImage: "hand.raised")
//                }
//                Link(destination: URL(string: "https://example.com/terms")!) {
//                    Label("Terms of Use", systemImage: "doc.text")
//                }
//                Link(destination: URL(string: "mailto:support@example.com")!) {
//                    Label("Contact Support", systemImage: "envelope")
//                }
            }

//            Section("Reset") {
//                Button(role: .destructive) {
//                    showResetConfirm = true
//                } label: {
//                    Label("Reset App Preferences", systemImage: "arrow.counterclockwise")
//                }
//                .confirmationDialog(
//                    "Reset preferences?",
//                    isPresented: $showResetConfirm,
//                    titleVisibility: .visible
//                ) {
//                    Button("Reset Appearance to System", role: .destructive) {
//                        appearance = "system"
//                    }
//                    Button("Cancel", role: .cancel) { }
//                } message: {
//                    Text("This resets simple preferences like appearance. Saved words are not affected.")
//                }
//
//                Text("Saved words are not deleted in v1.")
//                    .font(DS.FontToken.body(size: 13))
//                    .foregroundStyle(DS.Color.textSecondary)
//            }
        }
        .scrollContentBackground(.hidden)
        .background(DS.Color.background)
        .navigationTitle("Settings")
    }

    // MARK: - Header

    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text("Daily Vocab")
                    .font(DS.FontToken.heading(size: 28, weight: .bold))
                    .foregroundStyle(DS.Color.textPrimary)

                Text("A collection of your favourite words.")
                    .font(DS.FontToken.body(size: 14))
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .padding(.vertical, DS.Space.xs)
        }
    }

    // MARK: - Version strings

    private var versionString: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildString: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
