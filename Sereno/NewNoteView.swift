//
//  NewNoteView.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import SwiftUI
import AppKit

/// View for creating a new note with title and content editing using macOS-native design
struct NewNoteView: View {
    @ObservedObject var appState: AppState
    @State private var title: String = ""
    @State private var attributedContent: NSAttributedString
    @State private var showingSaveAlert = false
    @State private var showingDiscardAlert = false
    @State private var showFormattingToolbar = false
    @State private var selectedRange: NSRange = NSRange()
    @State private var isEditorFocused = false
    @FocusState private var isTitleFocused: Bool
    
    private enum SidebarTab {
        case notes
    }
    
    init(appState: AppState) {
        self.appState = appState
        // Create welcome text with styling
        let welcomeText = NSMutableAttributedString(
            string: "Welcome to your new note!\n\nStart writing here, or try these formatting options:\n• Use the toolbar above for styling\n• Press ⌘B for bold text\n• Press ⌘I for italic text\n• Press ⌘K to add links\n\nYour note is automatically saved and encrypted locally.",
            attributes: [
                .font: NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.secondaryLabelColor
            ]
        )
        
        // Style the welcome message
        welcomeText.addAttributes([
            .font: NSFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: NSColor.labelColor
        ], range: NSRange(location: 0, length: 24))
        
        _attributedContent = State(initialValue: welcomeText)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and buttons
            HStack {
                TextField("Note title", text: $title)
                    .font(.system(size: 20, weight: .semibold))
                    .textFieldStyle(.plain)
                    .focused($isTitleFocused)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        if !title.isEmpty || !attributedContent.string.isEmpty {
                            showingDiscardAlert = true
                        } else {
                            clearForm()
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                    
                    Button("Save") {
                        saveNote()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // Formatting toolbar
            ModernToolbar(
                onStyleSelected: { style in
                    applyStyle(style)
                },
                isVisible: $showFormattingToolbar
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            // Rich text editor
            RichTextEditor(
                attributedText: $attributedContent,
                onTextChange: { newText in
                    attributedContent = newText
                },
                onSelectionChange: { range in
                    selectedRange = range
                    showFormattingToolbar = range.length > 0 || isEditorFocused
                }
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .navigationTitle("New Note")
        .alert("Save Note", isPresented: $showingSaveAlert) {
            Button("OK") {
                clearForm()
            }
        } message: {
            Text("Your note has been saved successfully!")
        }
        .alert("Discard Changes", isPresented: $showingDiscardAlert) {
            Button("Discard", role: .destructive) {
                clearForm()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to discard your changes? This action cannot be undone.")
        }
    }
    
    /// Saves the current note to the app state
    private func saveNote() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newNote = Note(title: trimmedTitle, content: attributedContent.string)
        appState.addNote(newNote)
        
        // Show success alert
        showingSaveAlert = true
        
        // Switch to Notes tab and select the new note
        appState.selectedTab = .notes
        appState.selectedNote = newNote
    }
    
    /// Clears the form and resets to initial state
    private func clearForm() {
        title = ""
        attributedContent = NSAttributedString(string: "")
        showFormattingToolbar = false
        appState.selectedTab = .notes
    }
    
    /// Applies the selected style to the current text selection
    private func applyStyle(_ style: TextStyle) {
        // TODO: Implement style application through RichTextEditor
        // For now, this is a placeholder
    }
}

#Preview {
    NewNoteView(appState: AppState())
        .frame(minWidth: 800, minHeight: 600)
} 