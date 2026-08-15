import SwiftUI
import AppKit

struct MenuBarView: View {
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DevTools")
                .font(.headline)

            Button {
                // Open JSON formatter
            } label: {
                Label("JSON Formatter", systemImage: "curlybraces")
            }

            Button {
                JWTDecodeView()
            } label: {
                Label("JWT Decoder", systemImage: "key")
            }

            Button {
                let uuidString = UUID().uuidString

                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(
                    uuidString,
                    forType: .string
                )

                copied = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    copied = false
                }
            } label: {
                Label(
                    copied ? "UUID Copied!" : "Generate UUID",
                    systemImage: copied ? "checkmark" : "number"
                )
                .foregroundStyle(copied ? .green : .primary)
            }

            Divider()

            Button("Open DevTools") {
                // We'll connect this later
            }

            Button("Quit DevTools") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 280)
    }
}
