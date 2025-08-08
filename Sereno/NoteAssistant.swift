//
//  NoteAssistant.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import Foundation
import SwiftUI

/// Represents the status of the AI system
enum AIStatus {
    case notInitialized
    case initializing
    case ready
    case error(String)
}

/// Represents a summary of a note
struct NoteSummary {
    let summary: String
    let keyPoints: [String]
    let confidence: Double
    let generatedAt: Date
}

/// Represents a search result with relevance score
struct SearchResult {
    let note: Note
    let relevance: Double
    let matchedSections: [String]
}

/// Represents an AI-generated answer to a question
struct AIAnswer {
    let answer: String
    let sourceNotes: [Note]
    let confidence: Double
    let generatedAt: Date
}

/// Main class for handling AI operations on notes
@MainActor
class NoteAssistant: ObservableObject {
    /// Current status of the AI system
    @Published var status: AIStatus = .notInitialized
    
    /// Path to the local AI model
    @Published var modelPath: String = ""
    
    /// Current performance mode configuration
    @Published var performanceMode: PerformanceMode = .balanced
    
    /// Current model configuration based on performance mode
    var currentConfiguration: ModelConfiguration {
        return ModelConfiguration(performanceMode: performanceMode)
    }
    
    /// Whether AI features are available
    var isAvailable: Bool {
        switch status {
        case .ready:
            return true
        default:
            return false
        }
    }
    
    init() {
        // TODO: Initialize with actual model when available
        // For now, simulate initialization
        Task {
            await initializeAI()
        }
    }
    
    /// Initialize the AI system
    private func initializeAI() async {
        status = .initializing
        
        // Simulate initialization delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // For now, always succeed if model path is set
        if !modelPath.isEmpty {
            status = .ready
        } else {
            status = .notInitialized
        }
    }
    
    /// Set the model path and reinitialize
    func setModelPath(_ path: String) {
        modelPath = path
        Task {
            await initializeAI()
        }
    }
    
    /// Set the performance mode and update configuration
    func setPerformanceMode(_ mode: PerformanceMode) {
        performanceMode = mode
        // TODO: Apply new configuration to loaded model
        print("Performance mode changed to: \(mode.rawValue)")
        print("New configuration: \(currentConfiguration.description)")
    }
    
    /// Summarize a note using AI
    func summarize(_ note: Note) async -> NoteSummary {
        // Apply performance mode settings
        let config = currentConfiguration
        let processingDelay = getProcessingDelay(for: config)
        
        // Simulate AI processing delay based on performance mode
        try? await Task.sleep(nanoseconds: processingDelay)
        
        // Generate mock summary based on note content
        let words = note.content.components(separatedBy: .whitespacesAndNewlines)
        let wordCount = words.count
        
        let mockSummary: String
        let mockKeyPoints: [String]
        
        if wordCount < 50 {
            mockSummary = "This is a brief note with \(wordCount) words. It appears to be a quick thought or reminder."
            mockKeyPoints = ["Short note", "Quick reference"]
        } else if wordCount < 200 {
            mockSummary = "This note contains \(wordCount) words and appears to be a detailed entry covering multiple topics."
            mockKeyPoints = ["Detailed content", "Multiple topics", "Substantial length"]
        } else {
            mockSummary = "This is a comprehensive note with \(wordCount) words. It contains detailed information and appears to be well-structured."
            mockKeyPoints = ["Comprehensive content", "Well-structured", "Detailed information", "Substantial length"]
        }
        
        return NoteSummary(
            summary: mockSummary,
            keyPoints: mockKeyPoints,
            confidence: Double.random(in: 0.85...0.98),
            generatedAt: Date()
        )
    }
    
    /// Perform semantic search across notes
    func semanticSearch(query: String, in notes: [Note]) async -> [SearchResult] {
        // Apply performance mode settings
        let config = currentConfiguration
        let processingDelay = getProcessingDelay(for: config) / 2 // Search is faster than summarization
        
        // Simulate AI processing delay based on performance mode
        try? await Task.sleep(nanoseconds: processingDelay)
        
        // Mock semantic search results
        var results: [SearchResult] = []
        
        for note in notes {
            let relevance = calculateMockRelevance(query: query, note: note)
            if relevance > 0.1 { // Only include relevant results
                let matchedSections = extractMockMatchedSections(query: query, note: note)
                results.append(SearchResult(
                    note: note,
                    relevance: relevance,
                    matchedSections: matchedSections
                ))
            }
        }
        
        // Sort by relevance
        return results.sorted { $0.relevance > $1.relevance }
    }
    
    /// Answer a question using AI
    func answerQuestion(_ question: String, using notes: [Note]) async -> AIAnswer {
        // Apply performance mode settings
        let config = currentConfiguration
        let processingDelay = UInt64(Double(getProcessingDelay(for: config)) * 1.5) // Question answering is more complex
        
        // Simulate AI processing delay based on performance mode
        try? await Task.sleep(nanoseconds: processingDelay)
        
        // Generate mock answer based on question and available notes
        let relevantNotes = await semanticSearch(query: question, in: notes)
        let sourceNotes = relevantNotes.prefix(3).map { $0.note }
        
        let mockAnswer: String
        if sourceNotes.isEmpty {
            mockAnswer = "I couldn't find any relevant notes to answer your question. Try rephrasing or check if you have notes on this topic."
        } else {
            let noteCount = sourceNotes.count
            mockAnswer = "Based on your \(noteCount) relevant note\(noteCount == 1 ? "" : "s"), here's what I found: \(generateMockAnswerForQuestion(question, notes: sourceNotes))"
        }
        
        return AIAnswer(
            answer: mockAnswer,
            sourceNotes: Array(sourceNotes),
            confidence: Double.random(in: 0.75...0.95),
            generatedAt: Date()
        )
    }
    
    // MARK: - Private Helper Methods
    
    /// Gets processing delay based on performance mode configuration
    private func getProcessingDelay(for config: ModelConfiguration) -> UInt64 {
        switch config.performanceMode {
        case .lowPower:
            return 1_200_000_000 // 1.2 seconds (slower but more efficient)
        case .balanced:
            return 600_000_000 // 0.6 seconds
        case .maxPower:
            return 300_000_000 // 0.3 seconds (faster but more resource intensive)
        }
    }
    
    private func calculateMockRelevance(query: String, note: Note) -> Double {
        let queryWords = query.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let noteContent = (note.title + " " + note.content).lowercased()
        
        var relevance: Double = 0.0
        
        for word in queryWords {
            if word.count > 2 && noteContent.contains(word) {
                relevance += 0.2
            }
        }
        
        // Add some randomness for more realistic results
        relevance += Double.random(in: 0...0.1)
        
        return min(relevance, 1.0)
    }
    
    private func extractMockMatchedSections(query: String, note: Note) -> [String] {
        let sentences = note.content.components(separatedBy: ". ")
        let queryWords = query.lowercased().components(separatedBy: .whitespacesAndNewlines)
        
        return sentences.compactMap { sentence in
            let sentenceLower = sentence.lowercased()
            let hasMatch = queryWords.contains { word in
                word.count > 2 && sentenceLower.contains(word)
            }
            return hasMatch ? sentence : nil
        }.prefix(2).map { $0 }
    }
    
    private func generateMockAnswerForQuestion(_ question: String, notes: [Note]) -> String {
        let questionLower = question.lowercased()
        
        if questionLower.contains("swiftui") {
            return "You have notes about SwiftUI development, including UI components and best practices for building native macOS applications."
        } else if questionLower.contains("meeting") {
            return "You have meeting notes covering various topics including project timelines, resource allocation, and action items."
        } else if questionLower.contains("last week") {
            return "Your recent notes from last week include development progress, meeting summaries, and project updates."
        } else {
            return "Your notes contain relevant information that addresses your question. I recommend reviewing the specific notes for detailed insights."
        }
    }
} 