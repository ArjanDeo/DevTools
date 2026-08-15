//
//  JWTDecodeView.swift
//  DevTools
//
//  Created by Arjan Deo on 15/08/2026.
//

import SwiftUI
import Foundation

struct JWTClaim: Identifiable {
    let id = UUID()
    let key: String
    let value: String
}

struct JWTDecodeView: View {
    @State private var token = ""

    @State private var alertText: String?
    @State private var headerClaims: [JWTClaim] = []
    @State private var payloadClaims: [JWTClaim] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // MARK: - Header

            VStack(alignment: .leading, spacing: 4) {
                Text("JWT Decoder")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Decode and inspect the header and payload of a JSON Web Token.")
                    .foregroundStyle(.secondary)
            }

            // MARK: - Token Input

            VStack(alignment: .leading, spacing: 8) {
                Text("TOKEN")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                TextEditor(text: $token)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 110)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.quaternary.opacity(0.35))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.quaternary, lineWidth: 1)
                    }
            }

            // MARK: - Actions

            HStack(spacing: 10) {
                Button {
                    decodeJWT()
                } label: {
                    Label("Decode", systemImage: "arrow.down.doc")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    token = ""
                    alertText = nil
                    headerClaims = []
                    payloadClaims = []
                } label: {
                    Label("Clear", systemImage: "xmark")
                }
                .buttonStyle(.bordered)

                Spacer()
            }

            // MARK: - Error

            if let alertText {
                Label(alertText, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.callout)
            }

            // MARK: - Results

            if !headerClaims.isEmpty || !payloadClaims.isEmpty {

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Header

                        if !headerClaims.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("HEADER")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                Table(headerClaims) {
                                    TableColumn("Claim") { claim in
                                        Text(claim.key)
                                            .font(.system(.body, design: .monospaced))
                                    }
                                    .width(min: 100, ideal: 140)

                                    TableColumn("Value") { claim in
                                        Text(claim.value)
                                            .font(.system(.body, design: .monospaced))
                                            .textSelection(.enabled)
                                    }
                                    .width(min: 200, ideal: 300)
                                }
                                .frame(minHeight: 80)
                            }
                        }

                        // Payload

                        if !payloadClaims.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PAYLOAD")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                Table(payloadClaims) {
                                    TableColumn("Claim") { claim in
                                        Text(claim.key)
                                            .font(.system(.body, design: .monospaced))
                                    }
                                    .width(min: 100, ideal: 140)

                                    TableColumn("Value") { claim in
                                        Text(claim.value)
                                            .font(.system(.body, design: .monospaced))
                                            .textSelection(.enabled)
                                    }
                                    .width(min: 200, ideal: 300)
                                }
                                .frame(minHeight: 120)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }

            } else {
                // MARK: - Empty State

                VStack {
                    Spacer()

                    ContentUnavailableView {
                        Label("No JWT Decoded", systemImage: "key")
                    } description: {
                        Text("Paste a JWT above and click Decode.")
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: 700, height: 650)
    }

    // MARK: - JWT Decoder

    private func decodeJWT() {
        alertText = nil
        headerClaims = []
        payloadClaims = []

        let parts = token.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ".")

        guard parts.count == 3 else {
            alertText = "Invalid JWT"
            return
        }

        func decodeBase64URL(_ value: Substring) -> String? {
            var base64 = String(value)

            base64 = base64.replacingOccurrences(of: "-", with: "+")
            base64 = base64.replacingOccurrences(of: "_", with: "/")

            switch base64.count % 4 {
            case 0:
                break

            case 2:
                base64.append("==")

            case 3:
                base64.append("=")

            default:
                return nil
            }

            guard let data = Data(base64Encoded: base64) else {
                return nil
            }

            return String(data: data, encoding: .utf8)
        }

        // MARK: Header

        guard let header = decodeBase64URL(parts[0]) else {
            alertText = "Invalid JWT header."
            return
        }

        guard let headerData = header.data(using: .utf8),
              let headerJSON = try? JSONSerialization.jsonObject(with: headerData),
              let headerDictionary = headerJSON as? [String: Any] else {
            alertText = "Invalid JSON in JWT header."
            return
        }

        headerClaims = headerDictionary.map { key, value in
            JWTClaim(
                key: key,
                value: String(describing: value)
            )
        }
        .sorted { $0.key < $1.key }

        // MARK: Payload

        guard let payload = decodeBase64URL(parts[1]) else {
            alertText = "Invalid JWT payload."
            return
        }

        guard let payloadData = payload.data(using: .utf8),
              let payloadJSON = try? JSONSerialization.jsonObject(with: payloadData),
              let payloadDictionary = payloadJSON as? [String: Any] else {
            alertText = "Invalid JSON in JWT payload."
            return
        }

        payloadClaims = payloadDictionary.map { key, value in
            JWTClaim(
                key: key,
                value: String(describing: value)
            )
        }
        .sorted { $0.key < $1.key }
    }
}

#Preview {
    JWTDecodeView()
}
