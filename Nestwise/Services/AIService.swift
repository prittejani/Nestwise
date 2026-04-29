// AIService.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import Foundation
import FoundationModels

// MARK: - Availability helper

enum AIAvailability {
    case available
    case downloading
    case notSupported(String)
}

func checkAIAvailability() -> AIAvailability {
    switch SystemLanguageModel.default.availability {
    case .available:
        return .available
    case .unavailable(.deviceNotEligible):
        return .notSupported("Apple Intelligence is not supported on this device.")
    case .unavailable(.appleIntelligenceNotEnabled):
        return .notSupported("Please enable Apple Intelligence in Settings → Apple Intelligence & Siri.")
    case .unavailable(.modelNotReady):
        return .downloading
    default:
        return .notSupported("Apple Intelligence is not available right now.")
    }
}

// MARK: - NestwiseAIService

/// Owns a single LanguageModelSession per conversation context.
/// Recreates the session only when the system prompt changes (e.g. when the child profile switches).
@MainActor
final class NestwiseAIService {

    private var session: LanguageModelSession?
    private var currentInstructions: String = ""

    // MARK: Session management

    private func activeSession(for instructions: String) -> LanguageModelSession {
        if let existing = session, currentInstructions == instructions {
            return existing
        }
        let fresh = LanguageModelSession(instructions: instructions)
        session = fresh
        currentInstructions = instructions
        return fresh
    }

    func resetSession() {
        session = nil
        currentInstructions = ""
    }

    // MARK: Streaming

    /// Streams the model response as delta strings (new characters only, not full snapshots).
    /// Iterate this on MainActor — every yield is a small new chunk ready to append to your UI.
    func stream(
        instructions: String,
        userMessage: String
    ) -> AsyncThrowingStream<String, Error> {

        AsyncThrowingStream { continuation in
            Task { @MainActor in

                // Availability gate — fail fast with a clear error
                switch checkAIAvailability() {
                case .downloading:
                    continuation.finish(throwing: NWAIError.modelDownloading)
                    return
                case .notSupported(let reason):
                    continuation.finish(throwing: NWAIError.notSupported(reason))
                    return
                case .available:
                    break
                }

                do {
                    let lmSession = self.activeSession(for: instructions)

                    // streamResponse(to:) is NOT async — returns AsyncSequence directly, no await.
                    // Each element is a full-text snapshot, so we diff to get delta characters only.
                    let responseStream = lmSession.streamResponse(to: userMessage)

                    var previousLength = 0
                    for try await snapshot in responseStream {
                        let full = snapshot.content
                        guard full.count > previousLength else { continue }
                        let startIndex = full.index(full.startIndex, offsetBy: previousLength)
                        let delta = String(full[startIndex...])
                        previousLength = full.count
                        continuation.yield(delta)
                    }
                    continuation.finish()

                } catch let genError as LanguageModelSession.GenerationError {
                    switch genError {
                    case .exceededContextWindowSize:
                        self.resetSession()
                        continuation.finish(throwing: NWAIError.contextReset)
                    case .guardrailViolation:
                        continuation.finish(throwing: NWAIError.guardrailViolation)
                    default:
                        continuation.finish(throwing: genError)
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - NWAIError

enum NWAIError: LocalizedError {
    case modelDownloading
    case notSupported(String)
    case guardrailViolation
    case contextReset

    var errorDescription: String? {
        switch self {
        case .modelDownloading:
            return "Apple Intelligence is still setting up. This usually takes 20–40 minutes on Wi-Fi while charging. Try again shortly!"
        case .notSupported(let reason):
            return reason
        case .guardrailViolation:
            return "This question couldn't be answered. Please try rephrasing."
        case .contextReset:
            return "The conversation was too long and has been reset. You can keep chatting!"
        }
    }
}
