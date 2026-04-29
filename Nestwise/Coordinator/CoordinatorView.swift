// CoordinatorView.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import SwiftData

struct CoordinatorView: View {

    @EnvironmentObject private var coordinator: AppCoordinator
    @Query private var children: [ChildProfile]

    var body: some View {
        Group {
            switch coordinator.currentRoute {
            case .onboarding:
                OnboardingFlowView()

            case .home:
                HomeView()

            case .chat(let name, let age):
                ChatView(childName: name, ageMonths: age, childID: UUID())

            case .milestones:
                MilestonesView()

            /*
            case .paywall:
                PaywallView()
            */

            case .settings:
                SettingsView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: coordinator.currentRoute)
        .sheet(isPresented: $coordinator.isPresentingSheet) {
            if let sheet = coordinator.presentedSheet {
                sheetContent(for: sheet)
            }
        }
    }

    @ViewBuilder
    private func sheetContent(for route: AppRoute) -> some View {
        switch route {
        /*
        case .paywall:
            PaywallView()
        */
        case .settings:
            SettingsView()
        default:
            EmptyView()
        }
    }
}
