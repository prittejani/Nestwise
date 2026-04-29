// ChatMessage.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import Foundation
import SwiftData

@Model
final class ChatMessage {
    var id: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var childID: UUID

    init(content: String, isFromUser: Bool, childID: UUID) {
        self.id = UUID()
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.childID = childID
    }
}

// MARK: - Quick Question Chips
struct QuickQuestion: Identifiable {
    let id = UUID()
    let label: String
    let prompt: String
    let systemIcon: String
}

extension QuickQuestion {
    static func suggestions(for ageGroup: AgeGroup) -> [QuickQuestion] {
        switch ageGroup {
        case .newborn, .infant3:
            return [
                QuickQuestion(label: "Sleep help",    prompt: "My newborn won't sleep more than 2 hours. What can I do?",              systemIcon: "moon.fill"),
                QuickQuestion(label: "Feeding tips",  prompt: "How often should I feed my newborn?",                                    systemIcon: "drop.fill"),
                QuickQuestion(label: "Is this normal?", prompt: "My baby cries a lot in the evening. Is this colic? What can I do?",   systemIcon: "questionmark.circle.fill"),
                QuickQuestion(label: "Tummy time",    prompt: "How do I do tummy time and how long should it be?",                      systemIcon: "figure.roll"),
            ]
        case .infant6:
            return [
                QuickQuestion(label: "Starting solids", prompt: "When and how do I start my baby on solid foods?",                     systemIcon: "fork.knife"),
                QuickQuestion(label: "Sleep routine",  prompt: "How do I create a bedtime routine for a 6-month-old?",                  systemIcon: "moon.fill"),
                QuickQuestion(label: "Teething",       prompt: "My baby seems to be teething. How can I soothe them?",                  systemIcon: "face.smiling"),
                QuickQuestion(label: "Milestones",     prompt: "What milestones should my 6-month-old be reaching?",                   systemIcon: "star.fill"),
            ]
        case .toddler1, .toddler2:
            return [
                QuickQuestion(label: "Tantrums",      prompt: "My toddler has frequent tantrums. How should I handle them?",            systemIcon: "bolt.fill"),
                QuickQuestion(label: "Picky eating",  prompt: "My toddler refuses to eat vegetables. Any tips?",                        systemIcon: "fork.knife"),
                QuickQuestion(label: "Screen time",   prompt: "How much screen time is OK for my toddler's age?",                      systemIcon: "tv.fill"),
                QuickQuestion(label: "Potty training", prompt: "How do I know when my toddler is ready for potty training?",            systemIcon: "checkmark.circle.fill"),
            ]
        default:
            return [
                QuickQuestion(label: "Behaviour",     prompt: "My child is hitting other kids. How do I address this?",                systemIcon: "hand.raised.fill"),
                QuickQuestion(label: "Sleep",         prompt: "My child is refusing bedtime. What strategies can help?",                systemIcon: "moon.fill"),
                QuickQuestion(label: "Learning",      prompt: "What activities help my child's development at this age?",              systemIcon: "book.fill"),
                QuickQuestion(label: "Nutrition",     prompt: "What should a healthy diet look like for my child's age?",               systemIcon: "leaf.fill"),
            ]
        }
    }
}
