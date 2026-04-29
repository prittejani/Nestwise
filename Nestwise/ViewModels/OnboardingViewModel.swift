// OnboardingViewModel.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import SwiftData
import Combine

enum OnboardingStep: Int, CaseIterable {
    case welcome    = 0
    case childName  = 1
    case childDOB   = 2
    case privacy    = 3
}

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published
    @Published var currentStep: OnboardingStep = .welcome
    @Published var childName: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
    @Published var canProceed: Bool = false
    @Published var isLoading: Bool = false

    // MARK: - AI Check

    // MARK: - Computed
    var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }

    var isLastStep: Bool {
        currentStep == .privacy
    }

    var agePreview: String {
        let calendar = Calendar.current
        let months = calendar.dateComponents([.month], from: dateOfBirth, to: Date()).month ?? 0
        if months < 12 {
            return months == 1 ? "1 month old" : "\(months) months old"
        } else {
            let years = months / 12
            return years == 1 ? "1 year old" : "\(years) years old"
        }
    }

    // MARK: - Validation
    func validate() {
        switch currentStep {
        case .welcome:  canProceed = true
        case .childName: canProceed = childName.trimmingCharacters(in: .whitespaces).count >= 2
        case .childDOB: canProceed = dateOfBirth <= Date()
        case .privacy:  canProceed = true
        }
    }

    func next() {
        guard let nextRaw = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = nextRaw
        }
        validate()
    }

    func back() {
        guard let prevRaw = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = prevRaw
        }
        validate()
    }

    // MARK: - Save Profile
    func saveProfile(context: ModelContext) -> ChildProfile {
        let trimmed = childName.trimmingCharacters(in: .whitespaces)
        let child = ChildProfile(name: trimmed, dateOfBirth: dateOfBirth)
        context.insert(child)
        return child
    }
}
