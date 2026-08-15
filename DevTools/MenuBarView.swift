import SwiftUI

struct MenuBarView: View {
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
                // Open JWT decoder
            } label: {
                Label("JWT Decoder", systemImage: "key")
            }

            Button {
                // Generate UUID
            } label: {
                Label("UUID Generator", systemImage: "number")
            }

            Divider()

            Button("Open DevTools") {
                // We'll connect this to your main window
            }

            Button("Quit DevTools") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 280)
    }
}