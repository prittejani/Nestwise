// ChatView.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI
import SwiftData

struct ChatView: View {

    let childName: String
    let ageMonths: Int
    let childID: UUID

    @EnvironmentObject private var coordinator: AppCoordinator
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var viewModel: ChatViewModel

    @FocusState private var inputFocused: Bool

    init(childName: String, ageMonths: Int, childID: UUID) {
        self.childName = childName
        self.ageMonths = ageMonths
        self.childID = childID
        // ChatViewModel creates NestwiseAIService internally — no AIServiceProtocol needed.
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            childName: childName,
            ageMonths: ageMonths,
            childID: childID
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            chatNavBar

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {

                        ForEach(viewModel.messages) { bubble in
                            ChatBubbleView(bubble: bubble)
                        }

                        // Live streaming bubble — updates character by character
                        if viewModel.isStreaming && !viewModel.streamingContent.isEmpty {
                            ChatBubbleView(bubble: ChatBubble(
                                content: viewModel.streamingContent,
                                isFromUser: false
                            ))
                            .id("streaming")
                        }

                        // Typing indicator shown before first characters appear
                        if viewModel.isStreaming && viewModel.streamingContent.isEmpty {
                            TypingIndicatorView()
                        }

                        // Inline error banner
                        if let error = viewModel.errorMessage {
                            errorBanner(message: error)
                        }

                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation { proxy.scrollTo("bottom") }
                }
                .onChange(of: viewModel.streamingContent) {
                    proxy.scrollTo("bottom")
                }
            }

            if viewModel.messages.count <= 1 {
                quickQuestionsBar
            }

            /*
            if !purchaseManager.canSendMessage {
                messageLimitBanner
            }
            */

            inputBar
        }
        .aiDataUseAlert()
        .background(NWColors.background)
        .navigationBarHidden(true)
        /*
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
        */
    }

    // MARK: - Subviews

    private var chatNavBar: some View {
        HStack(spacing: 12) {
            Button { coordinator.navigate(to: .home) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(NWColors.primaryText)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Ask Nestwise AI")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(NWColors.primaryText)
                Text("About \(childName)")
                    .font(.system(size: 12))
                    .foregroundStyle(NWColors.secondaryText)
            }
            Spacer()
            ZStack {
                Circle().fill(NWColors.accentLight).frame(width: 36, height: 36)
                Image(systemName: "bird.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(NWColors.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(NWColors.surface)
        .overlay(alignment: .bottom) { Divider() }
    }

    private var quickQuestionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.quickQuestions) { q in
                    Button { viewModel.send(text: q.prompt) } label: {
                        HStack(spacing: 6) {
                            Image(systemName: q.systemIcon).font(.system(size: 12))
                            Text(q.label).font(.system(size: 13, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(NWColors.accentLight, in: Capsule())
                        .foregroundStyle(NWColors.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 44)
        .padding(.vertical, 6)
    }

    private var messageLimitBanner: some View {
        let remaining = viewModel.remainingMessages
        return HStack(spacing: 8) {
            Image(systemName: remaining > 3 ? "info.circle" : "exclamationmark.circle.fill")
                .font(.system(size: 13))
                .foregroundStyle(remaining > 3 ? NWColors.secondaryText : .orange)
            Text(remaining > 0
                 ? "\(remaining) free messages left today"
                 : "Daily limit reached — upgrade to continue")
                .font(.system(size: 12))
                .foregroundStyle(remaining > 0 ? NWColors.secondaryText : .orange)
            Spacer()
            if remaining == 0 {
                Button("Upgrade") { viewModel.showPaywall = true }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(NWColors.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(remaining > 0 ? NWColors.surfaceSecondary : Color.orange.opacity(0.08))
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask anything about \(childName)…", text: $viewModel.inputText, axis: .vertical)
                .font(.system(size: 15))
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(NWColors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 20))
                .focused($inputFocused)
                .onSubmit { viewModel.send() }

            Button {
                if viewModel.isStreaming { viewModel.cancelStream() }
                else { viewModel.send(); inputFocused = false }
            } label: {
                ZStack {
                    Circle()
                        .fill(viewModel.isStreaming ? Color.red.opacity(0.15) : NWColors.accent)
                        .frame(width: 40, height: 40)
                    Image(systemName: viewModel.isStreaming ? "stop.fill" : "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(viewModel.isStreaming ? .red : .white)
                }
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isStreaming && viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(NWColors.surface)
        .overlay(alignment: .top) { Divider() }
    }

    private func errorBanner(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 13))
                .foregroundStyle(.orange)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(NWColors.primaryText)
            Spacer()
            Button {
                viewModel.errorMessage = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundStyle(NWColors.secondaryText)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 4)
    }
}

// MARK: - ChatBubbleView
/*
struct ChatBubbleView: View {
    let bubble: ChatBubble
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if bubble.isFromUser { Spacer(minLength: 52) }
            if !bubble.isFromUser {
                ZStack {
                    Circle().fill(NWColors.accentLight).frame(width: 28, height: 28)
                    Image(systemName: "bird.fill").font(.system(size: 11)).foregroundStyle(NWColors.accent)
                }
            }
            Text(bubble.content)
                .font(.system(size: 15))
                .foregroundStyle(bubble.isFromUser ? .white : NWColors.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    bubble.isFromUser ? NWColors.accent : NWColors.surface,
                    in: BubbleShape(isFromUser: bubble.isFromUser)
                )
                .frame(maxWidth: .infinity, alignment: bubble.isFromUser ? .trailing : .leading)
            if !bubble.isFromUser { Spacer(minLength: 52) }
        }
    }
}*/
// ChatBubbleView — update the AI bubble to show citation footer
struct ChatBubbleView: View {
    let bubble: ChatBubble
    @State private var showCitations = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if bubble.isFromUser { Spacer(minLength: 52) }

            if !bubble.isFromUser {
                ZStack {
                    Circle().fill(NWColors.accentLight).frame(width: 28, height: 28)
                    Image(systemName: "bird.fill").font(.system(size: 11)).foregroundStyle(NWColors.accent)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(bubble.content)
                    .font(.system(size: 15))
                    .foregroundStyle(bubble.isFromUser ? .white : NWColors.primaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        bubble.isFromUser ? NWColors.accent : NWColors.surface,
                        in: BubbleShape(isFromUser: bubble.isFromUser)
                    )

                // ✅ Citation footer — only on AI messages
                if !bubble.isFromUser {
                    Button {
                        showCitations = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "cross.case.fill")
                                .font(.system(size: 9))
                            Text("AAP · WHO · NHS — tap to view sources")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(NWColors.tertiaryText)
                        .padding(.horizontal, 14)
                        .padding(.top, 4)
                        .padding(.bottom, 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: bubble.isFromUser ? .trailing : .leading)

            if !bubble.isFromUser { Spacer(minLength: 52) }
        }
        .sheet(isPresented: $showCitations) {
            NavigationStack {
                CitationsView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showCitations = false }
                                .fontWeight(.semibold)
                        }
                    }
            }
            .presentationDetents([.large])
        }
    }
}

// MARK: - BubbleShape

struct BubbleShape: Shape {
    let isFromUser: Bool
    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 16
        let tail: CGFloat = 6
        var path = Path()
        if isFromUser {
            path.addRoundedRect(
                in: CGRect(x: rect.minX, y: rect.minY, width: rect.width - tail, height: rect.height),
                cornerSize: CGSize(width: r, height: r)
            )
        } else {
            path.addRoundedRect(
                in: CGRect(x: rect.minX + tail, y: rect.minY, width: rect.width - tail, height: rect.height),
                cornerSize: CGSize(width: r, height: r)
            )
        }
        return path
    }
}

// MARK: - TypingIndicatorView

struct TypingIndicatorView: View {
    @State private var phase = 0
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle().fill(NWColors.accentLight).frame(width: 28, height: 28)
                Image(systemName: "bird.fill").font(.system(size: 11)).foregroundStyle(NWColors.accent)
            }
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(NWColors.secondaryText)
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == i ? 1.3 : 0.8)
                        .animation(.easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15), value: phase)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
            Spacer()
        }
        .onAppear { phase = 1 }
    }
}
