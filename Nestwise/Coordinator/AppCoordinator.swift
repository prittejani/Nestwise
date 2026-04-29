// AppCoordinator.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import Combine

enum AppRoute: Equatable {
    case onboarding
    case home
    case chat(childName: String, ageMonths: Int)
    case milestones
//    case paywall
    case settings
}

@MainActor
final class AppCoordinator: ObservableObject {

    // MARK: - Published State
    @Published var currentRoute: AppRoute = .onboarding
    @Published var presentedSheet: AppRoute?
    @Published var isPresentingSheet = false

    // MARK: - Init
    init() {
        let hasOnboarded = UserDefaults.standard.bool(forKey: AppConstants.Keys.hasCompletedOnboarding)
        currentRoute = hasOnboarded ? .home : .onboarding
    }

    // MARK: - Navigation
    func navigate(to route: AppRoute) {
        currentRoute = route
    }

    func presentSheet(_ route: AppRoute) {
        presentedSheet = route
        isPresentingSheet = true
    }

    func dismissSheet() {
        isPresentingSheet = false
        presentedSheet = nil
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: AppConstants.Keys.hasCompletedOnboarding)
        withAnimation(.easeInOut(duration: 0.4)) {
            currentRoute = .home
        }
    }

    func resetToOnboarding() {
        UserDefaults.standard.set(false, forKey: AppConstants.Keys.hasCompletedOnboarding)
        currentRoute = .onboarding
    }
}
