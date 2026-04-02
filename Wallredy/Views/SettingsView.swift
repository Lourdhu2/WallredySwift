import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        Text("Wallredy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .listRowBackground(Color.clear)
                }

                Section("About") {
                    Label("Photos by Pexels", systemImage: "photo.on.rectangle")
                    Label("Built with SwiftUI", systemImage: "swift")
                    Label("iOS 26 Liquid Glass", systemImage: "drop.fill")
                }

                Section("Support") {
                    Label("Rate on App Store", systemImage: "star.fill")
                    Label("Share App", systemImage: "square.and.arrow.up")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
