// HomeView.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {

    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var healthKitManager = HealthKitManager.shared
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.modelContext) private var context

    @Query private var children: [ChildProfile]
    @Query private var milestoneLogs: [MilestoneLog]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    if let child = children.first {
                        childCard(child)
                        quickActionsSection(child)
                        milestoneProgressCard(child)
                        if let sleepHours = healthKitManager.lastNightSleepHours {
                            sleepCard(hours: sleepHours)
                        }
                        tipOfDayCard
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(NWColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onAppear { 
                viewModel.updateGreeting() 
                
                // Request push notifications if not already requested
                if !UserDefaults.standard.bool(forKey: AppConstants.Keys.notificationsRequested) {
                    NotificationManager.shared.requestPermission()
                    UserDefaults.standard.set(true, forKey: AppConstants.Keys.notificationsRequested)
                }
                
                // Request HealthKit permissions
                healthKitManager.requestAuthorization()
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.greeting)
                .font(.system(size: 14))
                .foregroundStyle(NWColors.secondaryText)
            Text(AppConstants.appName)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(NWColors.primaryText)
        }
        .padding(.top, 8)
    }

    // MARK: - Child Card
    private func childCard(_ child: ChildProfile) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(NWColors.accentLight)
                    .frame(width: 56, height: 56)
                Text(child.name.prefix(1).uppercased())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(NWColors.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(child.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(NWColors.primaryText)
                HStack(spacing: 6) {
                    Image(systemName: child.ageGroup.iconName)
                        .font(.system(size: 12))
                        .foregroundStyle(NWColors.accent)
                    Text(child.ageDisplayString)
                        .font(.system(size: 14))
                        .foregroundStyle(NWColors.secondaryText)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quick Actions
    private func quickActionsSection(_ child: ChildProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(NWColors.secondaryText)
                .textCase(.uppercase)
                .kerning(0.5)

            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "bubble.left.and.bubble.right.fill",
                    label: "Ask AI",
                    color: NWColors.accent
                ) {
                    coordinator.navigate(to: .chat(childName: child.name, ageMonths: child.ageInMonths))
                }

                QuickActionButton(
                    icon: "checklist",
                    label: "Milestones",
                    color: .orange
                ) {
                    coordinator.navigate(to: .milestones)
                }

                /*
                QuickActionButton(
                    icon: "crown.fill",
                    label: "Go Pro",
                    color: .purple
                ) {
                    coordinator.navigate(to: .paywall)
                }
                */
            }
        }
    }

    // MARK: - Milestone Progress
    private func milestoneProgressCard(_ child: ChildProfile) -> some View {
        let progress = viewModel.milestoneProgress(logs: milestoneLogs, for: child)
        let completed = viewModel.completedMilestoneCount(logs: milestoneLogs, for: child)
        let total = viewModel.totalMilestoneCount(for: child)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Milestone progress")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(NWColors.primaryText)
                Spacer()
                Text("\(completed)/\(total)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(NWColors.accent)
            }

            Text(child.ageGroup.rawValue)
                .font(.system(size: 13))
                .foregroundStyle(NWColors.secondaryText)

            ProgressView(value: progress)
                .tint(NWColors.accent)
                .scaleEffect(y: 1.5)
        }
        .padding(16)
        .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
        .onTapGesture { coordinator.navigate(to: .milestones) }
    }

    // MARK: - Tip of the Day
    private var tipOfDayCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Text(viewModel.tipOfTheDay.emoji)
                    .font(.system(size: 16))
                
                Text("Tip of the day")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(NWColors.accent)
                    
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(viewModel.tipOfTheDay.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(NWColors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(viewModel.tipOfTheDay.body)
                .font(.system(size: 14))
                .foregroundStyle(NWColors.secondaryText)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(NWColors.accentLight, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Sleep Card
    private func sleepCard(hours: Double) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.indigo)
                
                Text("Sleep Insight")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.indigo)
                    
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("You slept \(String(format: "%.1f", hours))h last night")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(NWColors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let tip = hours < 6.0 
                ? "Here's a tip for tired parents: Rest when you can, and don't hesitate to ask for help today. You're doing amazing."
                : "Great job getting some rest! A well-rested parent is a more patient parent."
                
            Text(tip)
                .font(.system(size: 14))
                .foregroundStyle(NWColors.secondaryText)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(NWColors.accent)
            Text("No child profile found")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(NWColors.primaryText)
            NWPrimaryButton(title: "Set up profile", isEnabled: true) {
                coordinator.resetToOnboarding()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Toolbar
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                coordinator.presentSheet(.settings)
            } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(NWColors.secondaryText)
            }
        }
    }
}

// MARK: - Quick Action Button
private struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(NWColors.primaryText)
            }
        }
        .buttonStyle(.plain)
    }
}
