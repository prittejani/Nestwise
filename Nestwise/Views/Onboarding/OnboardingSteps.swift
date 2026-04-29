// OnboardingSteps.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI

// MARK: - Welcome Step
struct OnboardingWelcomeStep: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            // Logo / hero
            ZStack {
                Circle()
                    .fill(NWColors.accentLight)
                    .frame(width: 120, height: 120)
                Image(systemName: "bird.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(NWColors.accent)
            }

            VStack(spacing: 12) {
                Text("Nestwise")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(NWColors.primaryText)

                Text("Your private AI parenting companion.\nAll advice stays on your phone.")
                    .font(.system(size: 17))
                    .foregroundStyle(NWColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // Feature pills
            VStack(spacing: 10) {
                FeaturePill(icon: "brain.head.profile", text: "AI powered by Apple Intelligence")
                FeaturePill(icon: "lock.shield.fill",   text: "100% on-device · never shared")
                FeaturePill(icon: "chart.line.uptrend.xyaxis", text: "Milestone tracking & insights")
            }

            Spacer()
        }
        .padding(.horizontal, 28)
    }
}

// MARK: - Child Name Step
struct OnboardingNameStep: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your\nchild's name?")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(NWColors.primaryText)
                Text("This personalises your AI advice.")
                    .font(.system(size: 15))
                    .foregroundStyle(NWColors.secondaryText)
            }
            .padding(.top, 16)

            NWTextField(
                placeholder: "e.g. Aria, Liam, Sophie…",
                text: $viewModel.childName
            )
            .focused($isFocused)

            Spacer()
        }
        .padding(.horizontal, 28)
        .onAppear {
            isFocused = true
        }
        .onDisappear {
            isFocused = false
        }
        .onChange(of: viewModel.currentStep) { newStep in
            if newStep != .childName {
                isFocused = false
            }
        }
    }
}

// MARK: - Date of Birth Step
struct OnboardingDOBStep: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("When was \(viewModel.childName.isEmpty ? "your child" : viewModel.childName) born?")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(NWColors.primaryText)
                Text("We'll tailor milestones and advice to their exact age.")
                    .font(.system(size: 15))
                    .foregroundStyle(NWColors.secondaryText)
            }
            .padding(.top, 16)

            // Date picker
            DatePicker(
                "Date of birth",
                selection: $viewModel.dateOfBirth,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))

            // Age preview
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundStyle(NWColors.accent)
                Text(viewModel.agePreview)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(NWColors.accent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(NWColors.accentLight, in: RoundedRectangle(cornerRadius: 10))
            
            Spacer()
        }
        .padding(.horizontal, 28)
    }
}

// MARK: - Privacy Step
struct OnboardingPrivacyStep: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.green)
            }

            VStack(spacing: 10) {
                Text("Your data stays with you")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(NWColors.primaryText)
                    .multilineTextAlignment(.center)

                Text("Nestwise uses Apple Intelligence — AI that runs entirely on your device. No data is sent to any server. No account required.")
                    .font(.system(size: 15))
                    .foregroundStyle(NWColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(spacing: 10) {
                PrivacyRow(icon: "xmark.icloud.fill",   text: "No cloud storage of your child's data")
                PrivacyRow(icon: "person.slash.fill",   text: "No account or email required")
                PrivacyRow(icon: "iphone.and.arrow.forward", text: "All AI runs on-device via Apple Intelligence")
                PrivacyRow(icon: "dollarsign.circle",   text: "Free tier — 10 AI chats per day")
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 28)
    }
}

// MARK: - Subcomponents
private struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(NWColors.accent)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(NWColors.primaryText)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct PrivacyRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(Color.green)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(NWColors.primaryText)
            Spacer()
        }
    }
}
