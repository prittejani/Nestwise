// MessageLimitService.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import Foundation

final class MessageLimitService {

    // MARK: - Singleton
    static let shared = MessageLimitService()
    private init() {}

    // MARK: - Daily Limit
    var remainingMessages: Int {
        resetIfNewDay()
        let used = UserDefaults.standard.integer(forKey: AppConstants.Keys.dailyMessageCount)
        return max(0, AppConstants.freeDailyMessageLimit - used)
    }

    var hasReachedLimit: Bool {
        remainingMessages <= 0
    }

    func recordMessage() {
        resetIfNewDay()
        let current = UserDefaults.standard.integer(forKey: AppConstants.Keys.dailyMessageCount)
        UserDefaults.standard.set(current + 1, forKey: AppConstants.Keys.dailyMessageCount)
    }

    // MARK: - Reset Logic
    private func resetIfNewDay() {
        let lastDateString = UserDefaults.standard.string(forKey: AppConstants.Keys.lastMessageDate)
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        if lastDateString != today {
            UserDefaults.standard.set(0, forKey: AppConstants.Keys.dailyMessageCount)
            UserDefaults.standard.set(today, forKey: AppConstants.Keys.lastMessageDate)
        }
    }
}

private extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
