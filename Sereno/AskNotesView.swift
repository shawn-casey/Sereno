//
//  AskNotesView.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import SwiftUI
import AppKit

/// View that allows users to ask questions about their notes using AI
struct AskNotesView: View {
    @ObservedObject var appState: AppState
    @State private var question: String = ""
    @State private var answer: AIAnswer?
    @State private var isSearching: Bool = false
    @State private var showingNoNotesAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Text("Ask My Notes")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // AI Status indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(aiStatusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(aiStatusText)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Ask questions about your notes using natural language")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // Question input area
            VStack(spacing: 16) {
                HStack {
                    TextField("What did I write about SwiftUI last week?", text: $question)
                        .font(.system(size: 16))
                        .textFieldStyle(.roundedBorder)
                        .disabled(!appState.noteAssistant.isAvailable)
                    
                    Button("Ask") {
                        askQuestion()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .disabled(question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !appState.noteAssistant.isAvailable || isSearching)
                }
                
                if !appState.noteAssistant.isAvailable {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        
                        Text("AI features are not available. Please configure a model in Settings.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // Answer area
            if isSearching {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text("Searching your notes...")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let answer = answer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Answer
                        GroupBox("Answer") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(answer.answer)
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Text("Confidence: \(Int(answer.confidence * 100))%")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(answer.generatedAt, style: .relative)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 12)
                        }
                        
                        // Source notes
                        if !answer.sourceNotes.isEmpty {
                            GroupBox("Source Notes (\(answer.sourceNotes.count))") {
                                VStack(spacing: 12) {
                                    ForEach(answer.sourceNotes) { note in
                                        SourceNoteRow(note: note)
                                    }
                                }
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    .padding(20)
                }
            } else {
                // Placeholder
                VStack(spacing: 20) {
                    Image(systemName: "questionmark.bubble")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        Text("Ask a Question")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Type a question above to search through your notes")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.windowBackgroundColor))
        .alert("No Notes Available", isPresented: $showingNoNotesAlert) {
            Button("OK") { }
        } message: {
            Text("You need to create some notes before you can ask questions about them.")
        }
    }
    
    // MARK: - Computed Properties
    
    private var aiStatusColor: Color {
        switch appState.noteAssistant.status {
        case .ready:
            return .green
        case .initializing:
            return .orange
        case .error(_):
            return .red
        case .notInitialized:
            return .gray
        }
    }
    
    private var aiStatusText: String {
        switch appState.noteAssistant.status {
        case .ready:
            return "AI Ready"
        case .initializing:
            return "Initializing..."
        case .error(_):
            return "Error"
        case .notInitialized:
            return "Not Configured"
        }
    }
    
    // MARK: - Private Methods
    
    private func askQuestion() {
        guard !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard appState.noteAssistant.isAvailable else { return }
        guard !appState.notes.isEmpty else {
            showingNoNotesAlert = true
            return
        }
        
        isSearching = true
        answer = nil
        
        Task {
            let result = await appState.noteAssistant.answerQuestion(question, using: appState.notes)
            
            await MainActor.run {
                answer = result
                isSearching = false
            }
        }
    }
}

/// Row component for displaying a source note
struct SourceNoteRow: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Text(note.content)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(note.updatedAt, style: .relative)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    AskNotesView(appState: AppState())
        .frame(minWidth: 800, minHeight: 600)
} 