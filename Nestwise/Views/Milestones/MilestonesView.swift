// MilestonesView.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import SwiftData

struct MilestonesView: View {

    @StateObject private var viewModel = MilestonesViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.modelContext) private var context
    @State private var showCitations = false
    @State private var pdfURLToShare: URL? = nil
    
    @Query private var children: [ChildProfile]
    @Query private var logs: [MilestoneLog]

    var body: some View {
        NavigationStack {
            Group {
                if let child = children.first {
                    content(for: child)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Milestones")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        coordinator.navigate(to: .home)
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(NWColors.primaryText)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if let child = children.first {
                            viewModel.loadInsight(for: child, logs: logs)
                        }
                    } label: {
                        Image(systemName: "sparkles")
                            .foregroundStyle(NWColors.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showAIInsight) {
            AIInsightSheet(
                insight: viewModel.aiInsight,
                isLoading: viewModel.isLoadingInsight
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showCitations) {
            NavigationStack {
                CitationsView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showCitations = false }
                                .fontWeight(.semibold)
                        }
                    }
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: Binding<Bool>(
            get: { pdfURLToShare != nil },
            set: { if !$0 { pdfURLToShare = nil } }
        )) {
            if let url = pdfURLToShare {
                ActivityViewController(activityItems: [url])
            }
        }
    }

    // MARK: - Main Content
    @ViewBuilder
    private func content(for child: ChildProfile) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                progressHeader(for: child)
                
                // Export Button
                Button {
                    exportPDF(for: child)
                } label: {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Export for doctor visit")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(NWColors.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                
                ageGroupPicker(for: child)
                categoryFilter
                milestoneList(for: child)

                Button {
                    showCitations = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 9))
                        Text("AAP · WHO · NHS — tap to view sources")
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundStyle(NWColors.tertiaryText)
                    .padding(.top, 4)
                    .padding(.bottom, 2)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(NWColors.background)
    }
    
    private func exportPDF(for child: ChildProfile) {
        let total = MilestoneCatalog.milestones(for: child.ageGroup).count
        if let url = PDFGenerator.generateMilestoneReport(child: child, logs: logs, totalMilestones: total) {
            pdfURLToShare = url
        }
    }

    // MARK: - Progress Header
    private func progressHeader(for child: ChildProfile) -> some View {
        let progress = viewModel.progress(for: child, logs: logs)
        let text = viewModel.progressText(for: child, logs: logs)

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(NWColors.surfaceSecondary, lineWidth: 8)
                    .frame(width: 64, height: 64)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(NWColors.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: progress)
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(NWColors.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(child.name)'s progress")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(NWColors.primaryText)
                Text(text + " milestones")
                    .font(.system(size: 13))
                    .foregroundStyle(NWColors.secondaryText)
                Text(child.ageGroup.rawValue)
                    .font(.system(size: 12))
                    .foregroundStyle(NWColors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(NWColors.accentLight, in: Capsule())
            }
            Spacer()
        }
        .padding(16)
        .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Age Group Picker
    private func ageGroupPicker(for child: ChildProfile) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "Current" chip
                AgeGroupChip(
                    label: "Current",
                    isSelected: viewModel.selectedAgeGroup == nil
                ) { viewModel.selectedAgeGroup = nil }

                ForEach(AgeGroup.allCases, id: \.self) { group in
                    AgeGroupChip(
                        label: group.rawValue,
                        isSelected: viewModel.selectedAgeGroup == group
                    ) {
                        viewModel.selectedAgeGroup = viewModel.selectedAgeGroup == group ? nil : group
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        HStack(spacing: 8) {
            ForEach(Milestone.MilestoneCategory.allCases, id: \.self) { cat in
                CategoryChip(
                    category: cat,
                    isSelected: viewModel.selectedCategory == cat
                ) {
                    viewModel.selectedCategory = viewModel.selectedCategory == cat ? nil : cat
                }
            }
        }
    }

    // MARK: - Milestone List
    private func milestoneList(for child: ChildProfile) -> some View {
        let items = viewModel.milestones(for: child, filteredBy: viewModel.selectedCategory)
        return VStack(spacing: 10) {
            ForEach(items) { milestone in
                MilestoneRowView(
                    milestone: milestone,
                    isAchieved: viewModel.isAchieved(milestone: milestone, logs: logs)
                ) {
                    viewModel.toggle(milestone: milestone, logs: logs, child: child, context: context)
                }
            }
            if items.isEmpty {
                Text("No milestones for this filter.")
                    .font(.system(size: 14))
                    .foregroundStyle(NWColors.secondaryText)
                    .padding(.top, 24)
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(NWColors.secondaryText)
            Text("No child profile found")
                .font(.system(size: 17))
                .foregroundStyle(NWColors.primaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Milestone Row
struct MilestoneRowView: View {
    let milestone: Milestone
    let isAchieved: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isAchieved ? NWColors.accent : NWColors.surfaceSecondary)
                        .frame(width: 36, height: 36)
                    Image(systemName: isAchieved ? "checkmark" : milestone.category.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isAchieved ? .white : NWColors.secondaryText)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(milestone.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(NWColors.primaryText)
                        .strikethrough(isAchieved, color: NWColors.secondaryText)
                    Text(milestone.description)
                        .font(.system(size: 12))
                        .foregroundStyle(NWColors.secondaryText)
                        .lineLimit(2)
                }
                Spacer()

                Image(systemName: milestone.category.iconName)
                    .font(.system(size: 11))
                    .foregroundStyle(NWColors.secondaryText)
            }
            .padding(14)
            .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 14))
            .opacity(isAchieved ? 0.72 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isAchieved)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chips
private struct AgeGroupChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isSelected ? .white : NWColors.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? NWColors.accent : NWColors.surface, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryChip: View {
    let category: Milestone.MilestoneCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.iconName)
                    .font(.system(size: 10))
                Text(category.rawValue)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(isSelected ? .white : NWColors.primaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? NWColors.accent : NWColors.surface, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AI Insight Sheet
struct AIInsightSheet: View {
    let insight: String
    let isLoading: Bool
    @State private var showCitations = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(NWColors.accent)
                Text("AI Insight")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(NWColors.primaryText)
            }

            if isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Generating insight…")
                        .font(.system(size: 14))
                        .foregroundStyle(NWColors.secondaryText)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(insight.isEmpty ? "No insight available." : insight)
                            .font(.system(size: 15))
                            .foregroundStyle(NWColors.primaryText)
                            .lineSpacing(4)
                        
                        Button {
                            showCitations = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "cross.case.fill")
                                    .font(.system(size: 9))
                                Text("AAP · WHO · NHS — tap to view sources")
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundStyle(NWColors.tertiaryText)
                            .padding(.top, 4)
                            .padding(.bottom, 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NWColors.background)
        .sheet(isPresented: $showCitations) {
            NavigationStack {
                CitationsView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showCitations = false }
                                .fontWeight(.semibold)
                        }
                    }
            }
            .presentationDetents([.large])
        }
    }
}
