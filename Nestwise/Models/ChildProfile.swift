// ChildProfile.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import Foundation
import SwiftData

@Model
final class ChildProfile {

    // MARK: - Properties
    var id: UUID
    var name: String
    var dateOfBirth: Date
    var createdAt: Date

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade)
    var milestones: [MilestoneLog] = []

    @Relationship(deleteRule: .cascade)
    var chatMessages: [ChatMessage] = []

    // MARK: - Computed
    var ageInMonths: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dateOfBirth, to: Date())
        return max(0, components.month ?? 0)
    }

    var ageInYears: Int { ageInMonths / 12 }

    var ageDisplayString: String {
        let years = ageInYears
        let months = ageInMonths % 12
        if years == 0 {
            return months == 1 ? "1 month" : "\(months) months"
        } else if months == 0 {
            return years == 1 ? "1 year" : "\(years) years"
        } else {
            let y = years == 1 ? "1 year" : "\(years) years"
            let m = months == 1 ? "1 month" : "\(months) months"
            return "\(y) \(m)"
        }
    }

    var ageGroup: AgeGroup {
        switch ageInMonths {
        case 0..<3:   return .newborn
        case 3..<6:   return .infant3
        case 6..<12:  return .infant6
        case 12..<24: return .toddler1
        case 24..<36: return .toddler2
        case 36..<60: return .preschool
        default:      return .schoolAge
        }
    }

    // MARK: - Init
    init(name: String, dateOfBirth: Date) {
        self.id = UUID()
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.createdAt = Date()
    }
}

// MARK: - Age Group
enum AgeGroup: String, CaseIterable {
    case newborn   = "0–3 months"
    case infant3   = "3–6 months"
    case infant6   = "6–12 months"
    case toddler1  = "1–2 years"
    case toddler2  = "2–3 years"
    case preschool = "3–5 years"
    case schoolAge = "5+ years"

    var iconName: String {
        switch self {
        case .newborn:   return "moon.zzz.fill"
        case .infant3:   return "sun.min.fill"
        case .infant6:   return "figure.roll"
        case .toddler1:  return "figure.walk"
        case .toddler2:  return "figure.run"
        case .preschool: return "book.fill"
        case .schoolAge: return "backpack.fill"
        }
    }
}
