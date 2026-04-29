// AppConstants.swift
// Nestwise – AI Parenting Guide

import Foundation

enum AppConstants {

    // MARK: - App Info
    static let appName = "Nestwise"
    static let appTagline = "Your AI Parenting Guide"

    // MARK: - StoreKit
    // static let monthlyProductID = "app.prittu.Nestwise.monthly"
    // static let yearlyProductID  = "app.prittu.Nestwise.yearly"

    // MARK: - Free Tier Limits
    static let freeDailyMessageLimit = 10

    // MARK: - UserDefaults Keys
    enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isPro                  = "isPro"
        static let dailyMessageCount      = "dailyMessageCount"
        static let lastMessageDate        = "lastMessageDate"
        
        // Notifications
        static let notificationsRequested = "notificationsRequested"
        static let dailyTipsEnabled       = "dailyTipsEnabled"
        static let milestoneNudgesEnabled = "milestoneNudgesEnabled"
    }

    // MARK: - AI System Prompt
    static func systemPrompt(childName: String, ageMonths: Int, sleepHours: Double? = nil) -> String {
        var prompt = """
        You are NestWise, a warm and trusted AI parenting companion. \
        You are helping a parent with their child named \(childName), \
        who is \(ageMonths) months old (\(ageMonths / 12) years \(ageMonths % 12) months). \
        Give safe, practical, evidence-based parenting advice. \
        Always base recommendations on guidelines from AAP (American Academy of Pediatrics), \
        WHO (World Health Organization), NHS (UK National Health Service), or CDC where relevant. \
        When giving health-related advice, briefly mention which guideline it is based on \
        (e.g. "According to AAP guidelines..." or "The WHO recommends..."). \
        Never replace professional medical advice — always recommend consulting \
        a paediatrician for medical concerns. \
        Keep responses concise, warm, and jargon-free — 2 to 4 short paragraphs maximum.
        """
        
        if let sleep = sleepHours {
            if sleep < 6.0 {
                prompt += "\n\nImportant context: The parent slept only \(String(format: "%.1f", sleep)) hours last night. Be extra encouraging, empathetic, and keep your answers brief as they are likely tired."
            } else {
                prompt += "\n\nImportant context: The parent slept \(String(format: "%.1f", sleep)) hours last night."
            }
        }
        
        return prompt
    }
}
