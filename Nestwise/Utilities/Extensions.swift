// Extensions.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import Foundation

// MARK: - Date Extensions
extension Date {
    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: self, to: Date()).month ?? 0
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    func formatted(as style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isNotEmpty: Bool { !isEmpty }
}

// MARK: - View Extensions
extension View {
    func nwCard() -> some View {
        self
            .padding(16)
            .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    static func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: AppConstants.Keys.hasCompletedOnboarding)
    }
}

// MARK: - Array Extensions
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
extension UIApplication {
    func endEditing(_ force: Bool) {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .endEditing(force)
    }
}
