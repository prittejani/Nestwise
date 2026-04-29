// Milestone.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import Foundation
import SwiftData

// MARK: - MilestoneLog (persisted)
@Model
final class MilestoneLog {
    var id: UUID
    var milestoneID: String        // references Milestone.id
    var achievedAt: Date
    var childID: UUID

    init(milestoneID: String, childID: UUID) {
        self.id = UUID()
        self.milestoneID = milestoneID
        self.achievedAt = Date()
        self.childID = childID
    }
}

// MARK: - Milestone (static data)
struct Milestone: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let ageGroup: AgeGroup
    let category: MilestoneCategory

    enum MilestoneCategory: String, CaseIterable {
        case physical   = "Physical"
        case cognitive  = "Cognitive"
        case social     = "Social"
        case language   = "Language"

        var iconName: String {
            switch self {
            case .physical:  return "figure.arms.open"
            case .cognitive: return "brain.head.profile"
            case .social:    return "person.2.fill"
            case .language:  return "bubble.left.fill"
            }
        }
    }
}

// MARK: - Milestone Catalog
enum MilestoneCatalog {

    static let all: [Milestone] = newborn + infant3 + infant6 + toddler1 + toddler2 + preschool + schoolAge

    static let newborn: [Milestone] = [
        Milestone(id: "NB1", title: "Lifts head briefly", description: "Raises head when on tummy for a few seconds.", ageGroup: .newborn, category: .physical),
        Milestone(id: "NB2", title: "Responds to sounds", description: "Startles or turns toward loud sounds.", ageGroup: .newborn, category: .cognitive),
        Milestone(id: "NB3", title: "Makes eye contact", description: "Holds eye contact with a nearby face.", ageGroup: .newborn, category: .social),
        Milestone(id: "NB4", title: "First smile", description: "Produces a social smile in response to a face.", ageGroup: .newborn, category: .social),
    ]

    static let infant3: [Milestone] = [
        Milestone(id: "IN3_1", title: "Holds head steady", description: "Keeps head stable when held upright.", ageGroup: .infant3, category: .physical),
        Milestone(id: "IN3_2", title: "Coos and gurgles", description: "Makes vowel sounds to communicate.", ageGroup: .infant3, category: .language),
        Milestone(id: "IN3_3", title: "Follows moving objects", description: "Tracks a toy moved side to side.", ageGroup: .infant3, category: .cognitive),
        Milestone(id: "IN3_4", title: "Laughs out loud", description: "Produces clear laughter.", ageGroup: .infant3, category: .social),
    ]

    static let infant6: [Milestone] = [
        Milestone(id: "IN6_1", title: "Sits with support", description: "Sits upright when supported by hands or cushion.", ageGroup: .infant6, category: .physical),
        Milestone(id: "IN6_2", title: "Responds to name", description: "Turns toward caregiver when name is called.", ageGroup: .infant6, category: .language),
        Milestone(id: "IN6_3", title: "Transfers objects", description: "Passes a toy from one hand to the other.", ageGroup: .infant6, category: .physical),
        Milestone(id: "IN6_4", title: "Babbles consonants", description: "Makes sounds like ba, da, ma.", ageGroup: .infant6, category: .language),
    ]

    static let toddler1: [Milestone] = [
        Milestone(id: "TO1_1", title: "First steps", description: "Walks independently for several steps.", ageGroup: .toddler1, category: .physical),
        Milestone(id: "TO1_2", title: "First words", description: "Says at least 1–3 recognisable words.", ageGroup: .toddler1, category: .language),
        Milestone(id: "TO1_3", title: "Points to objects", description: "Points at things to show interest.", ageGroup: .toddler1, category: .cognitive),
        Milestone(id: "TO1_4", title: "Waves goodbye", description: "Waves hand when someone leaves.", ageGroup: .toddler1, category: .social),
    ]

    static let toddler2: [Milestone] = [
        Milestone(id: "TO2_1", title: "Runs steadily", description: "Runs without falling frequently.", ageGroup: .toddler2, category: .physical),
        Milestone(id: "TO2_2", title: "Two-word phrases", description: "Combines two words (more milk, daddy go)", ageGroup: .toddler2, category: .language),
        Milestone(id: "TO2_3", title: "Pretend play", description: "Engages in simple pretend scenarios.", ageGroup: .toddler2, category: .cognitive),
        Milestone(id: "TO2_4", title: "Parallel play", description: "Plays alongside other children.", ageGroup: .toddler2, category: .social),
    ]

    static let preschool: [Milestone] = [
        Milestone(id: "PS1", title: "Hops on one foot", description: "Balances and hops on one foot briefly.", ageGroup: .preschool, category: .physical),
        Milestone(id: "PS2", title: "Tells simple stories", description: "Narrates a short 2–3 sentence story.", ageGroup: .preschool, category: .language),
        Milestone(id: "PS3", title: "Understands rules", description: "Follows simple game rules.", ageGroup: .preschool, category: .cognitive),
        Milestone(id: "PS4", title: "Plays with friends", description: "Cooperates and takes turns with peers.", ageGroup: .preschool, category: .social),
    ]

    static let schoolAge: [Milestone] = [
        Milestone(id: "SA1", title: "Jumps over obstacles", description: "Can jump over small objects and land securely on both feet.", ageGroup: .schoolAge, category: .physical),
        Milestone(id: "SA2", title: "Tells complex stories", description: "Narrates detailed stories with a clear beginning, middle, and end.", ageGroup: .schoolAge, category: .language),
        Milestone(id: "SA3", title: "Follows board game rules", description: "Plays simple games with others and adheres to the established rules.", ageGroup: .schoolAge, category: .social),
        Milestone(id: "SA4", title: "Identifies colors & shapes", description: "Correctly names at least four colors and basic geometric shapes.", ageGroup: .schoolAge, category: .cognitive),
    ]

    static func milestones(for ageGroup: AgeGroup) -> [Milestone] {
        all.filter { $0.ageGroup == ageGroup }
    }
}
