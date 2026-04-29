//
//  AIDataUseAlert.swift
//  Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI

struct AIDataUseAlert: ViewModifier {

    @AppStorage("hasAcceptedAIDataUse") private var hasAccepted = false
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !hasAccepted {
                    isPresented = true
                }
            }
            .sheet(isPresented: $isPresented) {
                AIDataUseSheetView {
                    hasAccepted = true
                    isPresented = false
                }
                .interactiveDismissDisabled(true)
            }
    }
}

// MARK: - Sheet View
struct AIDataUseSheetView: View {

    let onAccept: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "#EEEDFF"))
                    .frame(width: 88, height: 88)
                Image(systemName: "apple.intelligence")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(hex: "#6C63FF"))
            }
            .padding(.bottom, 24)

            // Title
            Text("Powered by Apple Intelligence")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(NWColors.primaryText)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            // Subtitle
            Text("Nestwise uses Apple Intelligence to answer your parenting questions privately and securely.")
                .font(.system(size: 15))
                .foregroundStyle(NWColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)
                .padding(.bottom, 32)

            // Privacy rows
            VStack(spacing: 0) {
                AIPrivacyRow(
                    icon: "iphone",
                    iconColor: Color(hex: "#6C63FF"),
                    title: "Processed on your device",
                    subtitle: "Your questions never leave your iPhone. All AI runs locally using Apple Intelligence."
                )

                Divider().padding(.leading, 52)

                AIPrivacyRow(
                    icon: "person.slash.fill",
                    iconColor: .green,
                    title: "Not linked to your identity",
                    subtitle: "Apple Intelligence does not associate your conversations with your Apple ID."
                )

                Divider().padding(.leading, 52)

                AIPrivacyRow(
                    icon: "xmark.icloud.fill",
                    iconColor: .orange,
                    title: "No data sent to servers",
                    subtitle: "Nestwise does not collect, store or transmit your chat messages to any server."
                )

                Divider().padding(.leading, 52)

                AIPrivacyRow(
                    icon: "lock.shield.fill",
                    iconColor: .blue,
                    title: "Apple's privacy standards",
                    subtitle: "Apple Intelligence is built under Apple's strict on-device privacy framework."
                )
                
                AIPrivacyRow(
                    icon: "arrow.down.circle.fill",
                    iconColor: .green,
                    title: "Apple Intelligence",
                    subtitle: "If Apple Intelligence is not available on your device. Please download or enable it to continue using this feature."
                )
            }
            .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
            .padding(.bottom, 24)

            // Accept button
            Button {
                onAccept()
            } label: {
                Text("Got it, let's go")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "#6C63FF"), in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)

            // Legal note
            Text("By continuing you agree that your parenting queries will be processed by Apple Intelligence on your device in accordance with Apple's Privacy Policy.")
                .font(.system(size: 11))
                .foregroundStyle(NWColors.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(NWColors.background)
    }
}

// MARK: - Privacy Row
private struct AIPrivacyRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconColor)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NWColors.primaryText)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(NWColors.secondaryText)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// MARK: - View Extension
extension View {
    func aiDataUseAlert() -> some View {
        modifier(AIDataUseAlert())
    }
}
