// MilestonesViewModel.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class MilestonesViewModel: ObservableObject {

    // MARK: - Published
    @Published var selectedCategory: Milestone.MilestoneCategory? = nil
    @Published var selectedAgeGroup: AgeGroup? = nil
    @Published var showAIInsight: Bool = false
    @Published var aiInsight: String = ""
    @Published var isLoadingInsight: Bool = false

    // Owns its own session — separate from the chat session so insights
    // don't pollute the chat conversation history and vice versa.
    private let aiService = NestwiseAIService()

    // MARK: - Filtered Milestones

    func milestones(for child: ChildProfile, filteredBy category: Milestone.MilestoneCategory? = nil) -> [Milestone] {
        let group = selectedAgeGroup ?? child.ageGroup
        var result = MilestoneCatalog.milestones(for: group)
        if let cat = category ?? selectedCategory {
            result = result.filter { $0.category == cat }
        }
        return result
    }

    func isAchieved(milestone: Milestone, logs: [MilestoneLog]) -> Bool {
        logs.contains { $0.milestoneID == milestone.id }
    }

    func toggle(milestone: Milestone, logs: [MilestoneLog], child: ChildProfile, context: ModelContext) {
        if let existing = logs.first(where: { $0.milestoneID == milestone.id }) {
            context.delete(existing)
        } else {
            let log = MilestoneLog(milestoneID: milestone.id, childID: child.id)
            context.insert(log)
        }
        try? context.save()
    }

    // MARK: - Progress

    func progress(for child: ChildProfile, logs: [MilestoneLog]) -> Double {
        let total = MilestoneCatalog.milestones(for: child.ageGroup).count
        guard total > 0 else { return 0 }
        let achieved = logs.filter { log in
            MilestoneCatalog.milestones(for: child.ageGroup).contains { $0.id == log.milestoneID }
        }.count
        return Double(achieved) / Double(total)
    }

    func progressText(for child: ChildProfile, logs: [MilestoneLog]) -> String {
        let total = MilestoneCatalog.milestones(for: child.ageGroup).count
        let achieved = logs.filter { log in
            MilestoneCatalog.milestones(for: child.ageGroup).contains { $0.id == log.milestoneID }
        }.count
        return "\(achieved) of \(total)"
    }

    // MARK: - AI Insight

    // No longer takes aiService as a parameter — uses the privately owned NestwiseAIService.
    // Call site changes from:  viewModel.loadInsight(for: child, logs: logs, aiService: service)
    // to just:                 viewModel.loadInsight(for: child, logs: logs)
    func loadInsight(for child: ChildProfile, logs: [MilestoneLog]) {
        let achieved = logs.map { $0.milestoneID }.joined(separator: ", ")
        let prompt = """
            The child \(child.name), \(child.ageDisplayString) old, has achieved \
            these milestone IDs: \(achieved). Give one encouraging observation and \
            one gentle next-step activity suggestion in 3 sentences.
            """

        isLoadingInsight = true
        showAIInsight = true
        aiInsight = ""

        Task {
            let stream = aiService.stream(
                instructions: AppConstants.systemPrompt(
                    childName: child.name,
                    ageMonths: child.ageInMonths
                ),
                userMessage: prompt
            )
            do {
                for try await delta in stream {
                    aiInsight += delta
                }
            } catch {
                aiInsight = "Couldn't load insight right now. Try again shortly."
            }
            isLoadingInsight = false
        }
    }
}
