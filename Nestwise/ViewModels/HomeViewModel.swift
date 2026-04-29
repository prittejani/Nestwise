// HomeViewModel.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published
    @Published var greeting: String = ""
    @Published var tipOfTheDay: ParentingTip = ParentingTip.all.randomElement()!

    // MARK: - Init
    init() {
        updateGreeting()
    }

    // MARK: - Greeting
    func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  greeting = "Good morning"
        case 12..<17: greeting = "Good afternoon"
        case 17..<21: greeting = "Good evening"
        default:      greeting = "Good night"
        }
    }

    // MARK: - Progress
    func completedMilestoneCount(logs: [MilestoneLog], for child: ChildProfile) -> Int {
        let relevant = MilestoneCatalog.milestones(for: child.ageGroup)
        return logs.filter { log in
            relevant.contains { $0.id == log.milestoneID }
        }.count
    }

    func totalMilestoneCount(for child: ChildProfile) -> Int {
        MilestoneCatalog.milestones(for: child.ageGroup).count
    }

    func milestoneProgress(logs: [MilestoneLog], for child: ChildProfile) -> Double {
        let total = totalMilestoneCount(for: child)
        guard total > 0 else { return 0 }
        return Double(completedMilestoneCount(logs: logs, for: child)) / Double(total)
    }
}

// MARK: - Parenting Tip
struct ParentingTip: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let body: String

    static let all: [ParentingTip] = [
        ParentingTip(emoji: "🌙", title: "Consistent bedtimes matter", body: "Same sleep & wake time every day helps regulate your child's internal clock."),
        ParentingTip(emoji: "🗣️", title: "Talk all day long", body: "Narrate your day to your baby — even simple commentary builds language skills fast."),
        ParentingTip(emoji: "🤗", title: "Respond to cries", body: "You can't spoil a baby. Quick responses to crying builds secure attachment."),
        ParentingTip(emoji: "📵", title: "Screens under 2", body: "AAP recommends no screen time for children under 18–24 months, except video calls."),
        ParentingTip(emoji: "🥦", title: "Offer, don't force", body: "Repeatedly offer new foods without pressure. It can take 10–15 exposures to accept a new food."),
        ParentingTip(emoji: "🛁", title: "Bath = wind-down cue", body: "A warm bath 1–2 hours before bed helps lower core body temperature and signals sleep."),
        ParentingTip(emoji: "📚", title: "Read every day", body: "Even 10 minutes of reading daily dramatically improves vocabulary and brain development."),
        ParentingTip(emoji: "🧘", title: "Parent wellbeing matters", body: "You can't pour from an empty cup. Rest, ask for help, and be kind to yourself."),
    ]
}
