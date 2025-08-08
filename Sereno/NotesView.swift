//
//  NotesView.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import SwiftUI
import AppKit

/// View that displays a list of all notes with selection functionality using macOS-native design
struct NotesView: View {
    @ObservedObject var appState: AppState
    @State private var searchText: String = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching: Bool = false
    @State private var isFocusMode: Bool = false
    @State private var showTagPanel: Bool = false
    @State private var currentTag: String = ""
    @State private var notesListWidth: CGFloat = 350.0
    
    // MARK: - Helper Methods
    
    private func extractTags(from notes: [Note]) -> Set<String> {
        var tags = Set<String>()
        let tagPattern = "#([a-zA-Z0-9_]+)"
        
        for note in notes {
            let content = note.title + " " + note.content
            let regex = try? NSRegularExpression(pattern: tagPattern)
            let range = NSRange(location: 0, length: content.utf16.count)
            
            if let matches = regex?.matches(in: content, range: range) {
                for match in matches {
                    if let range = Range(match.range(at: 1), in: content) {
                        tags.insert(String(content[range]))
                    }
                }
            }
        }
        
        return tags
    }
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return appState.notes
        } else {
            return searchResults.map { $0.note }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // List of notes
            VStack(spacing: 0) {
                // Search bar
                VStack(spacing: 12) {
                                    HStack {
                    Text("Notes")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Hidden features
                    HStack(spacing: 8) {
                        // Focus mode toggle
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isFocusMode.toggle()
                            }
                        }) {
                            Image(systemName: isFocusMode ? "eye.slash" : "eye")
                                .font(.system(size: 14))
                                .foregroundColor(isFocusMode ? .blue : .secondary)
                        }
                        .buttonStyle(.borderless)
                        .help("Toggle Focus Mode (⌘⇧F)")
                        
                        // Tag panel toggle
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showTagPanel.toggle()
                            }
                        }) {
                            Image(systemName: "tag")
                                .font(.system(size: 14))
                                .foregroundColor(showTagPanel ? .blue : .secondary)
                        }
                        .buttonStyle(.borderless)
                        .help("Show Tags (⌘T)")
                        
                        if isSearching {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                        
                        TextField("Search notes...", text: $searchText)
                            .font(.system(size: 14))
                            .textFieldStyle(.plain)
                            .onChange(of: searchText) { _, newValue in
                                performSearch(query: newValue)
                            }
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                                searchResults = []
                            }
                            .buttonStyle(.borderless)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                
                HStack(spacing: 0) {
                    // Notes list
                    List(filteredNotes, selection: $appState.selectedNote) { note in
                        NoteRowView(note: note, appState: appState)
                            .tag(note)
                    }
                    .listStyle(.plain)
                    .opacity(isFocusMode ? 0.3 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isFocusMode)
                    
                    // Tag panel (hidden feature)
                    if showTagPanel {
                        TagPanel(
                            tags: extractTags(from: appState.notes),
                            currentTag: $currentTag,
                            onTagSelected: { tag in
                                searchText = "#\(tag)"
                                performSearch(query: searchText)
                            }
                        )
                        .frame(width: 200)
                        .transition(.move(edge: .trailing))
                    }
                }
            }
            .frame(width: notesListWidth)
            
            // Resizable divider
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1)
                .overlay(
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 8)
                        .contentShape(Rectangle())
                )
                .onHover { isHovered in
                    if isHovered {
                        NSCursor.resizeLeftRight.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newWidth = notesListWidth + value.translation.width
                            let maxWidth = showTagPanel ? 550.0 : 350.0
                            notesListWidth = max(280.0, min(maxWidth, newWidth))
                        }
                )
            
            // Detail view for selected note
            if let selectedNote = appState.selectedNote {
                EnhancedNoteDetailView(note: selectedNote, appState: appState)
            } else {
                PlaceholderView(
                    icon: "doc.text",
                    title: "No Note Selected",
                    subtitle: "Select a note from the list to view its contents"
                )
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        guard appState.noteAssistant.isAvailable else {
            // Fallback to simple text search
            searchResults = appState.notes.compactMap { note in
                let noteText = (note.title + " " + note.content).lowercased()
                let queryLower = query.lowercased()
                
                if noteText.contains(queryLower) {
                    return SearchResult(
                        note: note,
                        relevance: 0.5,
                        matchedSections: []
                    )
                }
                return nil
            }
            return
        }
        
        isSearching = true
        
        Task {
            let results = await appState.noteAssistant.semanticSearch(query: query, in: appState.notes)
            
            await MainActor.run {
                searchResults = results
                isSearching = false
            }
        }
    }
}

/// Enhanced detail view with floating formatting toolbar and better editing experience
struct EnhancedNoteDetailView: View {
    @ObservedObject var appState: AppState
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showFormattingToolbar = false
    @State private var selectedTextRange: NSRange = NSRange()
    @State private var toolbarPosition: CGPoint = .zero
    
    let note: Note
    
    init(note: Note, appState: AppState) {
        self.note = note
        self.appState = appState
        self._editedTitle = State(initialValue: note.title)
        self._editedContent = State(initialValue: note.content)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                // Header with title
                HStack {
                    if isEditing {
                        TextField("Note title", text: $editedTitle)
                            .font(.system(size: 20, weight: .semibold))
                            .textFieldStyle(.plain)
                    } else {
                        Text(note.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(isEditing ? "Done" : "Edit") {
                            if isEditing {
                                // Save changes
                                var updatedNote = note
                                updatedNote.title = editedTitle
                                updatedNote.content = editedContent
                                appState.updateNote(updatedNote)
                            }
                            isEditing.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        
                        Button("Delete") {
                            showingDeleteAlert = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.regular)
                        .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                
                // Content area with enhanced editor
                if isEditing {
                    EnhancedTextEditor(
                        text: $editedContent,
                        showFormattingToolbar: $showFormattingToolbar,
                        selectedTextRange: $selectedTextRange,
                        toolbarPosition: $toolbarPosition
                    )
                    .onAppear {
                        // Show toolbar when entering edit mode
                        showFormattingToolbar = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                } else {
                    ScrollView {
                        MarkdownTextView(text: note.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                    }
                }
                
                Spacer()
            }
            .background(Color(.windowBackgroundColor))
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                appState.secureDeleteNote(note)
            }
        } message: {
            Text("This note will be permanently and securely deleted. This action cannot be undone.")
        }
    }
    
    private func handleFormatting(_ format: FormatType) {
        // Apply formatting to selected text
        let formattedText = MarkdownFormatter.applyFormat(format, to: editedContent, in: selectedTextRange)
        editedContent = formattedText
    }
}

/// Enhanced text editor with formatting support
struct EnhancedTextEditor: View {
    @Binding var text: String
    @Binding var showFormattingToolbar: Bool
    @Binding var selectedTextRange: NSRange
    @Binding var toolbarPosition: CGPoint
    
    var body: some View {
        VStack(spacing: 0) {
            // Always show toolbar when editing
            if showFormattingToolbar {
                HStack(spacing: 8) {
                    // Bold
                    FormatButton(
                        icon: "bold",
                        shortcut: "⌘B",
                        action: { applyFormat(.bold) }
                    )
                    
                    // Italic
                    FormatButton(
                        icon: "italic", 
                        shortcut: "⌘I",
                        action: { applyFormat(.italic) }
                    )
                    
                    // Underline
                    FormatButton(
                        icon: "underline",
                        shortcut: "⌘U", 
                        action: { applyFormat(.underline) }
                    )
                    
                    Divider()
                        .frame(height: 20)
                    
                    // Bullet list
                    FormatButton(
                        icon: "list.bullet",
                        shortcut: "⌘L", 
                        action: { applyFormat(.bulletList) }
                    )
                    
                    // Heading
                    FormatButton(
                        icon: "textformat.size",
                        shortcut: "⌘H",
                        action: { applyFormat(.heading1) }
                    )
                    
                    // Link
                    FormatButton(
                        icon: "link",
                        shortcut: "⌘K",
                        action: { applyFormat(.link) }
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            TextEditor(text: $text)
                .font(.system(size: 14))
                .onTapGesture {
                    // Show toolbar when user starts editing
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showFormattingToolbar = true
                    }
                }
        }
    }
    
    private func applyFormat(_ format: FormatType) {
        // Apply formatting to current text
        let formattedText = MarkdownFormatter.applyFormat(format, to: text, in: NSRange(location: 0, length: text.count))
        text = formattedText
    }
}

/// Floating formatting toolbar
struct FloatingFormattingToolbar: View {
    let selectedTextRange: NSRange
    let onFormat: (FormatType) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Bold
            FormatButton(
                icon: KeyboardShortcuts.iconName(for: .bold),
                shortcut: KeyboardShortcuts.shortcutString(for: .bold),
                action: { onFormat(.bold) }
            )
            
            // Italic
            FormatButton(
                icon: KeyboardShortcuts.iconName(for: .italic), 
                shortcut: KeyboardShortcuts.shortcutString(for: .italic),
                action: { onFormat(.italic) }
            )
            
            // Underline
            FormatButton(
                icon: KeyboardShortcuts.iconName(for: .underline),
                shortcut: KeyboardShortcuts.shortcutString(for: .underline), 
                action: { onFormat(.underline) }
            )
            
            Divider()
                .frame(height: 20)
            
            // Lists
            FormatButton(
                icon: KeyboardShortcuts.iconName(for: .bulletList),
                shortcut: KeyboardShortcuts.shortcutString(for: .bulletList), 
                action: { onFormat(.bulletList) }
            )
            
            // Headings
            FormatButton(
                icon: KeyboardShortcuts.iconName(for: .heading1),
                shortcut: KeyboardShortcuts.shortcutString(for: .heading1),
                action: { onFormat(.heading1) }
            )
            
            // Links
            FormatButton(
                icon: KeyboardShortcuts.iconName(for: .link),
                shortcut: KeyboardShortcuts.shortcutString(for: .link),
                action: { onFormat(.link) }
            )
            
            Spacer()
            
            // More options
            FormatButton(
                icon: KeyboardShortcuts.iconName(for: .more),
                shortcut: KeyboardShortcuts.shortcutString(for: .more),
                action: { onFormat(.more) }
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

/// Format button component
struct FormatButton: View {
    let icon: String
    let shortcut: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(shortcut)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.clear)
        )
        .onHover { isHovered in
            // Subtle hover effect
        }
    }
}

/// Markdown text view for displaying formatted content
struct MarkdownTextView: View {
    let text: String
    
    var body: some View {
        Text(MarkdownFormatter.parseToAttributedString(text))
            .font(.system(size: 14))
            .foregroundColor(.primary)
    }
}

/// Tag panel component for organizing notes
struct TagPanel: View {
    let tags: Set<String>
    @Binding var currentTag: String
    let onTagSelected: (String) -> Void
    
    var filteredTags: [String] {
        if currentTag.isEmpty {
            return Array(tags).sorted()
        }
        return Array(tags).filter { $0.lowercased().contains(currentTag.lowercased()) }.sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Tags")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("\(tags.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            
            TextField("Search tags...", text: $currentTag)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 12)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(filteredTags, id: \.self) { tag in
                        Button(action: { onTagSelected(tag) }) {
                            HStack {
                                Text("#\(tag)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.clear)
                        )
                        .onHover { isHovered in
                            // Hover effect
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .leading
        )
    }
}

/// Row view for displaying a note in the list with macOS-native styling
struct NoteRowView: View {
    let note: Note
    @ObservedObject var appState: AppState
    @State private var showingSummary: Bool = false
    @State private var summary: NoteSummary?
    @State private var isSummarizing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Note content
            VStack(alignment: .leading, spacing: 6) {
                Text(note.title)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(note.content)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(note.updatedAt, style: .relative)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            // Summarize button
            if appState.noteAssistant.isAvailable {
                HStack {
                    Button(action: {
                        if showingSummary {
                            showingSummary = false
                        } else {
                            summarizeNote()
                        }
                    }) {
                        HStack(spacing: 4) {
                            if isSummarizing {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: showingSummary ? "chevron.up" : "brain.head.profile")
                                    .font(.system(size: 12))
                            }
                            
                            Text(showingSummary ? "Hide Summary" : "Summarize")
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(isSummarizing)
                    
                    Spacer()
                }
            }
            
            // Summary content
            if showingSummary, let summary = summary {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Summary")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(summary.summary)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        if !summary.keyPoints.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Key Points:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                ForEach(summary.keyPoints, id: \.self) { point in
                                    HStack(alignment: .top, spacing: 4) {
                                        Text("•")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                        
                                        Text(point)
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Text("Confidence: \(Int(summary.confidence * 100))%")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(summary.generatedAt, style: .relative)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Private Methods
    
    private func summarizeNote() {
        guard appState.noteAssistant.isAvailable else { return }
        
        isSummarizing = true
        showingSummary = true
        
        Task {
            let result = await appState.noteAssistant.summarize(note)
            
            await MainActor.run {
                summary = result
                isSummarizing = false
            }
        }
    }
}

/// Placeholder view for when no note is selected with macOS-native styling
struct PlaceholderView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}

#Preview {
    NotesView(appState: AppState())
        .frame(minWidth: 800, minHeight: 600)
} 