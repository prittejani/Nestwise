// NetwiseApp.swift
// Nestwise – AI Parenting Guide
// Created by Prit on 11/04/26.

import SwiftUI
import SwiftData

@main
struct NetwiseApp: App {

    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            CoordinatorView()
                .environmentObject(coordinator)
                .modelContainer(for: [ChildProfile.self, MilestoneLog.self, ChatMessage.self])
                .preferredColorScheme(.none)
        }
    }
}
