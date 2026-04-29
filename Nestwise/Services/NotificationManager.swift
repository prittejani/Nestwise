// NotificationManager.swift
// Nestwise – AI Parenting Guide

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    // Identifiers
    private let dailyTipIdentifier = "dailyParentingTip"
    private let milestoneNudgeIdentifier = "milestoneNudge"
    
    // Parenting Tips
    private let parentingTips = [
        "Talk to your child throughout the day to build their vocabulary.",
        "Make eye contact when interacting to strengthen emotional bonding.",
        "Sing songs to your baby to enhance memory and listening skills.",
        "Create a safe space where your child can explore freely.",
        "Limit screen time and encourage interactive play instead.",
        "Be consistent with rules to help your child feel secure.",
        "Model good behavior—children learn by watching you.",
        "Encourage your child to express their feelings openly.",
        "Give your child simple choices to build decision-making skills.",
        "Spend one-on-one time with your child every day.",
        "Celebrate small milestones to boost confidence.",
        "Teach your child to say 'please' and 'thank you' early on.",
        "Keep a calm tone during discipline to avoid fear-based reactions.",
        "Allow your child to make small mistakes and learn from them.",
        "Read bedtime stories daily to build imagination.",
        "Encourage outdoor play for physical and mental development.",
        "Maintain a healthy routine for meals and sleep.",
        "Show affection regularly through hugs and kind words.",
        "Encourage creativity through drawing and crafts.",
        "Be patient—every child develops at their own pace.",
        "Teach problem-solving instead of giving instant solutions.",
        "Listen actively when your child speaks.",
        "Encourage sharing and cooperation with others.",
        "Use positive reinforcement more than punishment.",
        "Set realistic expectations based on age.",
        "Keep dangerous items out of reach for safety.",
        "Teach basic hygiene habits early.",
        "Help your child build friendships and social skills.",
        "Encourage curiosity by answering their questions.",
        "Create family traditions to build lasting memories.",
        "Stay involved in your child’s learning activities.",
        "Allow time for unstructured play every day.",
        "Teach gratitude by practicing it yourself.",
        "Avoid comparing your child with others.",
        "Encourage independence in small daily tasks.",
        "Be a good listener during emotional moments.",
        "Teach your child to manage frustration calmly.",
        "Praise kindness and empathy.",
        "Make learning fun through games and activities.",
        "Be flexible and adapt to your child’s needs.",
        "Encourage healthy eating habits early.",
        "Respect your child’s individuality.",
        "Create a supportive and loving home environment.",
        "Stay calm during tantrums and guide gently.",
        "Teach responsibility with small chores.",
        "Be mindful of your words—they shape self-esteem.",
        "Encourage your child to try new things.",
        "Limit distractions during family time.",
        "Show appreciation for your child’s efforts.",
        "End each day with a positive interaction."
    ]
    
    private init() {}
    
    // MARK: - Permissions
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // By default, enable both if they just granted permission
                if UserDefaults.standard.object(forKey: AppConstants.Keys.dailyTipsEnabled) == nil {
                    UserDefaults.standard.set(true, forKey: AppConstants.Keys.dailyTipsEnabled)
                    self.scheduleDailyTip()
                }
                if UserDefaults.standard.object(forKey: AppConstants.Keys.milestoneNudgesEnabled) == nil {
                    UserDefaults.standard.set(true, forKey: AppConstants.Keys.milestoneNudgesEnabled)
                    self.rescheduleMilestoneNudge()
                }
            } else {
                // If they deny, make sure toggles are off
                UserDefaults.standard.set(false, forKey: AppConstants.Keys.dailyTipsEnabled)
                UserDefaults.standard.set(false, forKey: AppConstants.Keys.milestoneNudgesEnabled)
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Daily Tips
    func scheduleDailyTip() {
        guard UserDefaults.standard.bool(forKey: AppConstants.Keys.dailyTipsEnabled) else { return }
        
        // Cancel existing first
        cancelDailyTip()
        
        let content = UNMutableNotificationContent()
        content.title = "Parenting Tip of the Day"
        content.body = parentingTips.randomElement() ?? "You're doing great!"
        content.sound = .default
        
        // Schedule for 8:00 AM every day
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: dailyTipIdentifier, content: content, trigger: trigger)
        center.add(request)
    }
    
    func cancelDailyTip() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyTipIdentifier])
    }
    
    // MARK: - Milestone Nudge
    func rescheduleMilestoneNudge() {
        guard UserDefaults.standard.bool(forKey: AppConstants.Keys.milestoneNudgesEnabled) else { return }
        
        // Cancel existing
        cancelMilestoneNudge()
        
        let content = UNMutableNotificationContent()
        content.title = "Log a Milestone"
        content.body = "You haven't logged a milestone in 3 days. Check in on your child's progress!"
        content.sound = .default
        
        // Schedule for 3 days from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 24 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(identifier: milestoneNudgeIdentifier, content: content, trigger: trigger)
        center.add(request)
    }
    
    func cancelMilestoneNudge() {
        center.removePendingNotificationRequests(withIdentifiers: [milestoneNudgeIdentifier])
    }
}
