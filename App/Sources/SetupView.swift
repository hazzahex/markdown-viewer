#if os(macOS)
import SwiftUI

/// First-run / Help window for the macOS app. Explains what the app provides
/// (Quick Look preview + Finder thumbnails for `.md`), how to enable the
/// extensions, and the login/restart gotcha that registers them.
struct SetupView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            Text("This app adds native Markdown to macOS — no need to open it:")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 14) {
                step(1, "Enable the extensions",
                     "System Settings → General → **Login Items & Extensions** → under **Extensions**, open **Quick Look** and turn on **Markdown Preview** and **Markdown Thumbnail**.")
                step(2, "Log out & back in (or restart)",
                     "macOS registers Quick Look extensions at login. If previews or thumbnails don't appear yet, this almost always fixes it.")
                step(3, "Try it",
                     "Select a `.md` file in Finder and press **Space** for a rendered preview. Switch Finder to icon view (**⌘1**) to see Markdown thumbnails.")
            }

            HStack {
                Button("Open Quick Look Settings") {
                    openURL(URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences")!)
                }
                Spacer()
                Text("You can reopen this from the **Help** menu.")
                    .font(.footnote).foregroundStyle(.tertiary)
            }
            .padding(.top, 4)
        }
        .padding(28)
        .frame(width: 480)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Text("M↓")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color(red: 0.13, green: 0.16, blue: 0.20), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text("Markdown Viewer").font(.title2.bold())
                Text("Quick Look previews & thumbnails for .md files")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }

    private func step(_ n: Int, _ title: String, _ detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(n)")
                .font(.callout.bold().monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color.accentColor, in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(detail).font(.callout).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
#endif
