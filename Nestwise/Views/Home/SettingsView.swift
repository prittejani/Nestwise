// SettingsView.swift
// Nestwise – AI Parenting Guide

import SwiftUI
import SwiftData
import StoreKit
import UserNotifications

struct SettingsView: View {

    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.requestReview) private var requestReview
    @Environment(\.scenePhase) private var scenePhase

    @Query private var children: [ChildProfile]
    @State private var showDeleteConfirmation = false
    @State private var showAbout = false
    @State private var showSettingsAlert = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    @AppStorage(AppConstants.Keys.dailyTipsEnabled) private var dailyTipsEnabled = false
    @AppStorage(AppConstants.Keys.milestoneNudgesEnabled) private var milestoneNudgesEnabled = false

    private let isPro = UserDefaults.standard.bool(forKey: AppConstants.Keys.isPro)

    var body: some View {
        NavigationStack {
            List {

                // MARK: Child
                if let child = children.first {
                    Section("Your child") {
                        LabeledContent("Name", value: child.name)
                        LabeledContent("Age", value: child.ageDisplayString)
                        LabeledContent("Age group", value: child.ageGroup.rawValue)
                    }
                }

                // MARK: Usage
                /*
                Section("Daily usage") {
                    LabeledContent(
                        "Messages remaining",
                        value: isPro ? "Unlimited" : "\(MessageLimitService.shared.remainingMessages)/\(AppConstants.freeDailyMessageLimit)"
                    )
                }
                */

                // MARK: Notifications
                Section("Notifications") {
                    Toggle("Daily Parenting Tips", isOn: $dailyTipsEnabled)
                        .onChange(of: dailyTipsEnabled) { _, newValue in
                            handleToggleChange(newValue: newValue, isDailyTip: true)
                        }
                    
                    Toggle("Milestone Reminders", isOn: $milestoneNudgesEnabled)
                        .onChange(of: milestoneNudgesEnabled) { _, newValue in
                            handleToggleChange(newValue: newValue, isDailyTip: false)
                        }
                }

                // MARK: Privacy
                Section("Privacy") {
                    HStack {
                        Label("AI processing", systemImage: "iphone")
                        Spacer()
                        Text("On-device only")
                            .font(.system(size: 13))
                            .foregroundStyle(.green)
                    }
                    HStack {
                        Label("Data storage", systemImage: "lock.fill")
                        Spacer()
                        Text("Local only")
                            .font(.system(size: 13))
                            .foregroundStyle(.green)
                    }
                    Button {
                        if let url = URL(string: "https://prittejani.github.io/Nestwise/PrivacyPolicy/index.html") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Privacy Policy", systemImage: "doc.text")
                            .foregroundStyle(NWColors.primaryText)
                    }
                    // Inside the Privacy Section in SettingsView
                    NavigationLink {
                        CitationsView()
                    } label: {
                        Label("Medical Sources & Citations", systemImage: "cross.case.fill")
                            .foregroundStyle(NWColors.primaryText)
                    }
                }

                // MARK: Support
                Section("Support") {
                    // Rate Us
                    Button {
                        requestReview()
                    } label: {
                        HStack {
                            Label("Rate Nestwise", systemImage: "star.fill")
                                .foregroundStyle(NWColors.primaryText)
                            Spacer()
                            HStack(spacing: 2) {
                                ForEach(0..<5) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.yellow)
                                }
                            }
                        }
                    }

                    // Share App
                    /*
                    ShareLink(
                        item: URL(string: "https://apps.apple.com/app/Nestwise")!,
                        subject: Text("Nestwise – AI Parenting Guide"),
                        message: Text("Check out Nestwise — a private AI parenting app that runs entirely on your iPhone!")
                    ) {
                        Label("Share Nestwise", systemImage: "square.and.arrow.up")
                            .foregroundStyle(NWColors.primaryText)
                    }
                    */
                    // Contact
                    Button {
                        if let url = URL(string: "mailto:prittejani01@gmail.com?subject=Nestwise%20Support") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Contact Support", systemImage: "envelope")
                            .foregroundStyle(NWColors.primaryText)
                    }
                }

                // MARK: About
                Section("About") {
                    Button {
                        showAbout = true
                    } label: {
                        HStack {
                            Label("About Nestwise", systemImage: "info.circle")
                                .foregroundStyle(NWColors.primaryText)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(NWColors.tertiaryText)
                        }
                    }

                    LabeledContent("Version") {
                        Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
                            .foregroundStyle(NWColors.secondaryText)
                    }
                }

                // MARK: Danger Zone
                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Reset all data", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .confirmationDialog(
                "Reset all data?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete everything", role: .destructive) {
                    deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete your child profile, milestones, and chat history. This cannot be undone.")
            }
            .navigationDestination(isPresented: $showAbout) {
                AboutView()
            }
            .onAppear {
                checkNotificationPermissions()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    checkNotificationPermissions()
                }
            }
            .alert("Notifications Disabled", isPresented: $showSettingsAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            } message: {
                Text("Please enable notifications for Nestwise in your device Settings to receive reminders.")
            }
        }
    }
    
    // MARK: - Notifications
    private func checkNotificationPermissions() {
        NotificationManager.shared.checkPermissionStatus { status in
            self.notificationStatus = status
            if status == .denied {
                // If denied, force toggles off
                self.dailyTipsEnabled = false
                self.milestoneNudgesEnabled = false
            }
        }
    }
    
    private func handleToggleChange(newValue: Bool, isDailyTip: Bool) {
        if newValue && notificationStatus == .denied {
            // Revert the toggle and show alert
            if isDailyTip {
                dailyTipsEnabled = false
            } else {
                milestoneNudgesEnabled = false
            }
            showSettingsAlert = true
            return
        }
        
        if isDailyTip {
            if newValue {
                NotificationManager.shared.scheduleDailyTip()
            } else {
                NotificationManager.shared.cancelDailyTip()
            }
        } else {
            if newValue {
                NotificationManager.shared.rescheduleMilestoneNudge()
            } else {
                NotificationManager.shared.cancelMilestoneNudge()
            }
        }
    }

    // MARK: - Delete All
    private func deleteAllData() {
        for child in children { context.delete(child) }
        try? context.save()
        UserDefaults.standard.set(false, forKey: AppConstants.Keys.hasCompletedOnboarding)
        UserDefaults.standard.set(false, forKey: AppConstants.Keys.isPro)
        UserDefaults.standard.set(0, forKey: AppConstants.Keys.dailyMessageCount)
        dismiss()
        coordinator.resetToOnboarding()
    }
}
