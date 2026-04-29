// ChatViewModel.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {

    // MARK: - Published state

    @Published var messages: [ChatBubble] = []
    @Published var inputText: String = ""
    @Published var isStreaming: Bool = false
    @Published var streamingContent: String = ""
    @Published var showPaywall: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    let childName: String
    let ageMonths: Int
    let childID: UUID

    // NestwiseAIService owns the LanguageModelSession directly — no protocol indirection.
    private let aiService: NestwiseAIService

    // Task<Void, Error> so CancellationError and thrown errors are never silently swallowed.
    private var streamingTask: Task<Void, Error>?

    // MARK: - Computed

    var quickQuestions: [QuickQuestion] {
        QuickQuestion.suggestions(for: ageGroupFromMonths(ageMonths))
    }

    var remainingMessages: Int {
        MessageLimitService.shared.remainingMessages
    }

    var canSendMessage: Bool {
        PurchaseManager.shared.canSendMessage
    }

    // MARK: - Init

    init(
        childName: String,
        ageMonths: Int,
        childID: UUID
    ) {
        self.childName = childName
        self.ageMonths = ageMonths
        self.childID = childID
        self.aiService = NestwiseAIService()     // owns its own LanguageModelSession
        addWelcomeMessage()
    }

    // MARK: - Send

    func send(text: String? = nil) {
        let messageText = (text ?? inputText).trimmingCharacters(in: .whitespaces)
        guard !messageText.isEmpty, !isStreaming else { return }

        /*
        guard  PurchaseManager.shared.canSendMessage else {
            showPaywall = true
            return
        }
        */

        inputText = ""
        messages.append(ChatBubble(content: messageText, isFromUser: true))
        MessageLimitService.shared.recordMessage()
        startStreaming(for: messageText)
    }

    // MARK: - Streaming

    private func startStreaming(for userMessage: String) {
        isStreaming = true
        streamingContent = ""
        errorMessage = nil

        let instructions = AppConstants.systemPrompt(
            childName: childName, 
            ageMonths: ageMonths,
            sleepHours: HealthKitManager.shared.lastNightSleepHours
        )

        streamingTask = Task {
            do {
                // aiService.stream() returns an AsyncThrowingStream<String, Error>
                // where each element is a delta (new characters only, not a full snapshot).
                let stream = aiService.stream(
                    instructions: instructions,
                    userMessage: userMessage
                )

                for try await delta in stream {
                    try Task.checkCancellation()
                    streamingContent += delta      // append delta — correct because service diffs for us
                }

                finaliseStreamedMessage()

            } catch is CancellationError {
                // User tapped the stop button — clean up quietly
                isStreaming = false
                streamingContent = ""

            } catch let aiError as NWAIError {
                appendSystemBubble(aiError.errorDescription ?? "Something went wrong.")
                isStreaming = false

            } catch {
                errorMessage = "Something went wrong. Please try again."
                isStreaming = false
            }
        }
    }

    private func finaliseStreamedMessage() {
        let content = streamingContent.trimmingCharacters(in: .whitespaces)
        guard !content.isEmpty else {
            isStreaming = false
            return
        }
        messages.append(ChatBubble(content: content, isFromUser: false))
        streamingContent = ""
        isStreaming = false
    }

    // MARK: - Cancel

    func cancelStream() {
        streamingTask?.cancel()
        streamingTask = nil
        isStreaming = false
        streamingContent = ""
    }

    // MARK: - Helpers

    private func appendSystemBubble(_ text: String) {
        messages.append(ChatBubble(content: text, isFromUser: false))
    }

    private func addWelcomeMessage() {
        appendSystemBubble(
            "Hi! I'm your Nestwise AI — here to help you with \(childName)'s journey. What would you like to know today?"
        )
    }

    private func ageGroupFromMonths(_ months: Int) -> AgeGroup {
        switch months {
        case 0..<3:   return .newborn
        case 3..<6:   return .infant3
        case 6..<12:  return .infant6
        case 12..<24: return .toddler1
        case 24..<36: return .toddler2
        case 36..<60: return .preschool
        default:      return .schoolAge
        }
    }
}

// MARK: - ChatBubble

struct ChatBubble: Identifiable {
    let id = UUID()
    var content: String
    let isFromUser: Bool
    let timestamp = Date()
}
