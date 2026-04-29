//
//  AboutView.swift
//  Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI

struct AboutView: View {

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                appHeader
                descriptionCard
                linksCard
                techCard
                versionFooter
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
        }
        .background(NWColors.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - App Header
    private var appHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(NWColors.accentLight)
                    .frame(width: 88, height: 88)
                Image(systemName: "bird.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(NWColors.accent)
            }

            VStack(spacing: 4) {
                Text("Nestwise")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(NWColors.primaryText)
                Text("AI Parenting Guide")
                    .font(.system(size: 15))
                    .foregroundStyle(NWColors.secondaryText)
            }

            Text("Version \(appVersion) (\(buildNumber))")
                .font(.system(size: 12))
                .foregroundStyle(NWColors.tertiaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(NWColors.surfaceSecondary, in: Capsule())
        }
    }

    // MARK: - Description
    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Our mission")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(NWColors.accent)
                .textCase(.uppercase)
                .kerning(0.5)

            Text("Nestwise was built for parents who want trusted, private AI parenting advice — without sending their family's data to the cloud.")
                .font(.system(size: 15))
                .foregroundStyle(NWColors.primaryText)
                .lineSpacing(4)

            Text("Powered entirely by Apple Intelligence on your device, Nestwise gives you instant answers about sleep, feeding, development, and behaviour — all staying on your iPhone.")
                .font(.system(size: 14))
                .foregroundStyle(NWColors.secondaryText)
                .lineSpacing(4)
        }
        .padding(18)
        .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Links
    private var linksCard: some View {
        VStack(spacing: 0) {
            AboutLinkRow(
                icon: "lock.shield.fill",
                iconColor: NWColors.accent,
                title: "Privacy Policy",
                subtitle: "How we protect your data"
            ) {
                // Replace with your actual hosted URL
                if let url = URL(string: "https://prittejani.github.io/Nestwise/PrivacyPolicy/index.html") {
                    UIApplication.shared.open(url)
                }
            }

            Divider().padding(.leading, 52)

            AboutLinkRow(
                icon: "doc.text.fill",
                iconColor: .blue,
                title: "Terms of Use",
                subtitle: "App usage terms"
            ) {
                if let url = URL(string: "https://prittejani.github.io/Nestwise/PrivacyPolicy/index.html") {
                    UIApplication.shared.open(url)
                }
            }

            Divider().padding(.leading, 52)

            AboutLinkRow(
                icon: "envelope.fill",
                iconColor: .green,
                title: "Contact Us",
                subtitle: "prittejani01@gmail.com"
            ) {
                if let url = URL(string: "mailto:prittejani01@gmail.com") {
                    UIApplication.shared.open(url)
                }
            }
        }
        .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Tech Stack
    private var techCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Built with")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(NWColors.secondaryText)
                .textCase(.uppercase)
                .kerning(0.5)

            HStack(spacing: 10) {
                TechBadge(label: "Apple Intelligence", icon: "apple.intelligence")
                TechBadge(label: "SwiftUI", icon: "swift")
                TechBadge(label: "SwiftData", icon: "cylinder.fill")
            }
        }
        .padding(18)
        .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Version Footer
    private var versionFooter: some View {
        VStack(spacing: 6) {
            Text("Made with care for parents everywhere")
                .font(.system(size: 12))
                .foregroundStyle(NWColors.tertiaryText)
            Text("© 2026 Nestwise. All rights reserved.")
                .font(.system(size: 11))
                .foregroundStyle(NWColors.tertiaryText)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 8)
    }
}

// MARK: - About Link Row
private struct AboutLinkRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundStyle(iconColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(NWColors.primaryText)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(NWColors.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(NWColors.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tech Badge
private struct TechBadge: View {
    let label: String
    let icon: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(NWColors.accent)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(NWColors.primaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(NWColors.surfaceSecondary, in: Capsule())
    }
}
