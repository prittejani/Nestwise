// NWComponents.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI

// MARK: - Primary Button
struct NWPrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    isEnabled ? NWColors.accent : NWColors.accent.opacity(0.35),
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// MARK: - Text Field
struct NWTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 17))
            .foregroundStyle(NWColors.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 14))
            .autocorrectionDisabled()
    }
}

// MARK: - Section Header
struct NWSectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(NWColors.secondaryText)
            .kerning(0.6)
    }
}

// MARK: - Card
struct NWCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Empty State
struct NWEmptyState: View {
    let systemIcon: String
    let title: String
    let subtitle: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemIcon)
                .font(.system(size: 44))
                .foregroundStyle(NWColors.accent.opacity(0.6))
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(NWColors.primaryText)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(NWColors.secondaryText)
                .multilineTextAlignment(.center)
            if let buttonTitle, let buttonAction {
                NWPrimaryButton(title: buttonTitle, isEnabled: true, action: buttonAction)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Loading Overlay
struct NWLoadingOverlay: View {
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.3)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(NWColors.secondaryText)
        }
        .padding(28)
        .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12)
    }
}

// MARK: - Tag / Badge
struct NWBadge: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: Capsule())
    }
}
