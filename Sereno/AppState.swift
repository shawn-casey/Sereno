//
//  AppState.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import SwiftUI

/// Represents a note in the Sereno app
struct Note: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, content: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// Represents the different tabs in the sidebar
enum SidebarTab: String, CaseIterable, Hashable {
    case notes = "Notes"
    case newNote = "New Note"
    case askNotes = "Ask My Notes"
    case settings = "Settings"
    case about = "About"
    
    var icon: String {
        switch self {
        case .notes:
            return "doc.text"
        case .newNote:
            return "plus.square"
        case .askNotes:
            return "questionmark.bubble"
        case .settings:
            return "gear"
        case .about:
            return "info.circle"
        }
    }
}

/// Main app state manager that handles navigation, notes, and settings
@MainActor
class AppState: ObservableObject {
    /// Currently selected sidebar tab
    @Published var selectedTab: SidebarTab = .notes
    
    /// Currently selected note for viewing/editing
    @Published var selectedNote: Note?
    
    /// All notes stored in the app
    @Published var notes: [Note] = []
    
    /// AI assistant for note operations
    @Published var noteAssistant = NoteAssistant()
    
    /// App settings
    @Published var isDarkMode: Bool = false
    @Published var fontSize: Double = 16.0
    @Published var localAIModel: String = "Default Model"
    @Published var performanceMode: PerformanceMode = .balanced
    @Published var systemCapabilities: SystemInfo.HardwareCapabilities?
    
    init() {
        // Load sample notes for demonstration
        loadSampleNotes()
        
        // Detect system capabilities and set recommended performance mode
        detectSystemCapabilities()
    }
    
    /// Adds a new note to the collection
    /// - Parameter note: The note to add
    func addNote(_ note: Note) {
        notes.append(note)
        // TODO: Implement persistent storage here
        // saveNotesToStorage()
    }
    
    /// Updates an existing note
    /// - Parameter note: The updated note
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = note
            updatedNote.updatedAt = Date()
            notes[index] = updatedNote
            // TODO: Implement persistent storage here
            // saveNotesToStorage()
        }
    }
    
    /// Deletes a note from the collection
    /// - Parameter note: The note to delete
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        // TODO: Implement persistent storage here
        // saveNotesToStorage()
    }
    
    /// Loads sample notes for demonstration purposes
    private func loadSampleNotes() {
        notes = [
            Note(title: "Welcome to Sereno", content: "Welcome to Sereno, your secure local AI note-taking app. This is your first note!"),
            Note(title: "Meeting Notes", content: "Team meeting discussion points:\n- Project timeline review\n- Resource allocation\n- Next steps"),
            Note(title: "Ideas", content: "Random thoughts and ideas:\n- App feature improvements\n- Design concepts\n- Future projects")
        ]
    }
    
    /// Saves notes to persistent storage (placeholder for future implementation)
    private func saveNotesToStorage() {
        // TODO: Implement Core Data or FileManager storage
        // This will be implemented when adding persistent storage
    }
    
    /// Loads notes from persistent storage (placeholder for future implementation)
    private func loadNotesFromStorage() {
        // TODO: Implement Core Data or FileManager loading
        // This will be implemented when adding persistent storage
    }
    
    /// Detects system capabilities and sets recommended performance mode
    private func detectSystemCapabilities() {
        let capabilities = SystemInfo.getHardwareCapabilities()
        systemCapabilities = capabilities
        
        // Set recommended performance mode if not already set
        let recommendedMode = SystemInfo.getRecommendedPerformanceMode(for: capabilities)
        if performanceMode == .balanced { // Only auto-set if still on default
            performanceMode = recommendedMode
        }
    }
    
    /// Securely deletes a note using secure deletion utilities
    /// - Parameter note: The note to securely delete
    func secureDeleteNote(_ note: Note) {
        // Remove from memory first
        notes.removeAll { $0.id == note.id }
        
        // TODO: Implement secure file deletion when persistent storage is added
        // let baseDirectory = getNotesDirectory()
        // let success = SecureDeletion.secureDeleteNote(note, from: baseDirectory)
        // if !success {
        //     print("Warning: Secure deletion failed for note \(note.id)")
        // }
    }
    
    /// Securely deletes all notes
    func secureDeleteAllNotes() {
        // TODO: Implement secure deletion of all note files
        // let baseDirectory = getNotesDirectory()
        // let deletedCount = SecureDeletion.secureDeleteAllNotes(from: baseDirectory)
        // print("Securely deleted \(deletedCount) note files")
        
        // Clear from memory
        notes.removeAll()
    }
} 