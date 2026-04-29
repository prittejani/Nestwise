// OnboardingFlowView.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import SwiftData

struct OnboardingFlowView: View {

    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            NWColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                if viewModel.currentStep != .welcome {
                    progressBar
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }

                // Step content
                TabView(selection: Binding(
                    get: { viewModel.currentStep.rawValue },
                    set: { _ in }
                )) {
                    OnboardingWelcomeStep()
                        .tag(OnboardingStep.welcome.rawValue)
                        .environmentObject(viewModel)

                    OnboardingNameStep()
                        .tag(OnboardingStep.childName.rawValue)
                        .environmentObject(viewModel)

                    OnboardingDOBStep()
                        .tag(OnboardingStep.childDOB.rawValue)
                        .environmentObject(viewModel)

                    OnboardingPrivacyStep()
                        .tag(OnboardingStep.privacy.rawValue)
                        .environmentObject(viewModel)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentStep)

                // Nav buttons
                navigationButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .onChange(of: viewModel.childName) { viewModel.validate() }
        .onChange(of: viewModel.dateOfBirth) { viewModel.validate() }
        .onAppear { viewModel.validate() }
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(NWColors.surfaceSecondary)
                    .frame(height: 4)
                RoundedRectangle(cornerRadius: 3)
                    .fill(NWColors.accent)
                    .frame(width: geo.size.width * viewModel.progress, height: 4)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
            }
        }
        .frame(height: 4)
        .padding(.bottom, 8)
    }

    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        VStack(spacing: 12) {
            NWPrimaryButton(
                title: (viewModel.currentStep == .welcome || viewModel.isLastStep) ? "Get Started" : "Continue",
                isEnabled: viewModel.canProceed
            ) {
                if viewModel.isLastStep {
                    let _ = viewModel.saveProfile(context: context)
                    coordinator.completeOnboarding()
                } else {
                    viewModel.next()
                }
            }

            if viewModel.currentStep != .welcome {
                Button("Back") {
                    viewModel.back()
                }
                .font(.system(size: 15))
                .foregroundStyle(NWColors.secondaryText)
            }
        }
    }
}
