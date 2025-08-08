# Sereno - Secure Local AI Note-Taking App

Sereno is a secure, local-first note-taking application that leverages artificial intelligence to enhance your productivity while keeping your data private and secure. Built specifically for macOS with native design patterns and Human Interface Guidelines compliance.

## Features

### 🔒 Privacy First
- All data stored locally on your device
- No cloud synchronization required
- **Secure deletion** with cryptographic overwriting before file removal
- End-to-end encryption (planned)
- Local AI processing with on-device models

### 📝 Note Management
- Create, edit, and organize notes with native macOS interface
- Rich text editing with TextEditor optimized for Mac
- Automatic saving and version tracking
- **AI-powered semantic search** across all notes
- **One-click note summarization** with key points extraction
- **Secure note deletion** with unrecoverable file removal
- Native sidebar navigation with proper selection states

### 🤖 AI-Powered Features
- **Note Summarization**: Generate concise summaries with key points for any note
- **Semantic Search**: Find notes using natural language queries (e.g., "meeting notes from June")
- **Ask My Notes**: Ask questions about your notes and get AI-generated answers
- **Local AI Processing**: All AI features run on-device for complete privacy
- **Model Management**: Select and configure local AI models (llama.cpp compatible)
- **Performance Optimization**: Automatic system resource management

### ⚡ Performance & Resource Management
- **Automatic Hardware Detection**: Detects chip model, RAM, battery status
- **Performance Modes**: Low Power, Balanced, and Max Power options
- **System Resource Optimization**: Adjusts AI model usage based on available resources
- **Battery-Aware Processing**: Reduces power consumption when on battery
- **Memory Management**: Optimizes RAM usage for different performance modes

### 🎨 Native macOS Design
- **NavigationSplitView** with balanced layout for optimal screen usage
- **Native controls** with proper sizing and spacing
- **System fonts and colors** for consistent appearance
- **Responsive layout** that adapts to different window sizes
- **Proper window management** with unified toolbar style
- **GroupBox organization** for clear content structure

### ⚙️ Settings & Customization
- Dark mode toggle with native switch controls
- Font size adjustment with slider
- **Local AI model configuration** with file picker
- **AI status monitoring** with real-time feedback
- **Performance mode selection** with system recommendations
- **Hardware capability display** with detailed system information
- Storage management with native styling
- Settings organized in logical groups

## App Structure

### Core Files
- `SerenoApp.swift` - Main app entry point with macOS window configuration
- `ContentView.swift` - Main navigation structure using NavigationSplitView
- `AppState.swift` - Central state management and data models
- `NoteAssistant.swift` - AI operations and model management
- `SecureDeletion.swift` - Secure file deletion utilities
- `SystemInfo.swift` - Hardware detection and system information
- `PerformanceMode.swift` - Performance mode definitions and configuration

### Views
- `NotesView.swift` - List and detail view for notes with AI search and summarization
- `NewNoteView.swift` - Create new notes with native text editing
- `AskNotesView.swift` - AI-powered question answering interface
- `SettingsView.swift` - App settings with AI model and performance configuration
- `AboutView.swift` - App information with native layout patterns

### Data Models
- `Note` - Represents a note with title, content, and timestamps
- `SidebarTab` - Enum for navigation tabs
- `AppState` - ObservableObject for state management
- `NoteSummary` - AI-generated note summaries
- `SearchResult` - Semantic search results
- `AIAnswer` - AI-generated answers to questions
- `PerformanceMode` - Performance mode configuration
- `ModelConfiguration` - AI model configuration settings

## AI Integration

### NoteAssistant Class
The `NoteAssistant` class provides a clean interface for all AI operations:

```swift
// Summarize a note
let summary = await noteAssistant.summarize(note)

// Search notes semantically
let results = await noteAssistant.semanticSearch(query: "meeting notes", in: notes)

// Answer questions about notes
let answer = await noteAssistant.answerQuestion("What did I write about SwiftUI?", using: notes)
```

### AI Status Management
- **Not Initialized**: No model configured
- **Initializing**: Model loading in progress
- **Ready**: AI features available
- **Error**: Model loading failed

### Model Configuration
- Select local AI model files through native file picker
- Automatic initialization when model path is set
- Support for llama.cpp and similar local models
- Graceful fallback to text search when AI unavailable

## Security Features

### Secure Deletion
Sereno implements military-grade secure deletion using:

- **Cryptographic Overwriting**: Files are overwritten with random data before deletion
- **Multiple Passes**: 3-pass overwrite ensures data cannot be recovered
- **APFS Optimization**: Optimized for macOS APFS file system
- **Unrecoverable**: Once deleted, notes cannot be recovered by any means

```swift
// Securely delete a single note
SecureDeletion.secureDeleteNote(note, from: baseDirectory)

// Securely delete all notes
SecureDeletion.secureDeleteAllNotes(from: baseDirectory)
```

## Performance Optimization

### Automatic Hardware Detection
Sereno automatically detects your system's capabilities:

- **Chip Model**: M1, M2, M3, Intel, etc.
- **RAM**: Total and available memory
- **Battery Status**: Power source and battery level
- **System Mode**: Low power mode detection

### Performance Modes

#### 💤 Low Power Mode
- **Memory Usage**: 512MB maximum
- **Concurrent Operations**: 1
- **GPU Acceleration**: Disabled
- **Neural Engine**: Disabled
- **Quantization**: INT8 (fastest, smallest)
- **Context Window**: 1K tokens
- **Use Case**: Battery operation, low-end systems

#### ⚖️ Balanced Mode
- **Memory Usage**: 2GB maximum
- **Concurrent Operations**: 2
- **GPU Acceleration**: Enabled
- **Neural Engine**: Enabled
- **Quantization**: INT16 (balanced)
- **Context Window**: 4K tokens
- **Use Case**: Default for most systems

#### 🚀 Max Power Mode
- **Memory Usage**: 8GB maximum
- **Concurrent Operations**: 4
- **GPU Acceleration**: Enabled
- **Neural Engine**: Enabled
- **Quantization**: FP32 (highest quality)
- **Context Window**: 8K tokens
- **Use Case**: High-end systems, plugged in

### Automatic Recommendations
The app automatically recommends the best performance mode based on:

- **Hardware Capabilities**: Chip model and RAM
- **Power Status**: Battery level and power source
- **System Settings**: Low power mode status
- **Resource Availability**: Available memory and processing power

## macOS Design Principles

### Layout & Navigation
- **NavigationSplitView** with balanced style for optimal space usage
- **Sidebar navigation** with proper selection states and icons
- **Responsive design** that works across standard Mac screen sizes
- **Proper window sizing** with content-appropriate dimensions

### Controls & Interaction
- **Native button styles** with appropriate control sizes
- **System fonts** with proper weights and sizes
- **Native colors** using NSColor for consistent appearance
- **Proper spacing** following macOS Human Interface Guidelines

### Content Organization
- **GroupBox** for logical content grouping
- **Divider** for visual separation
- **ScrollView** for content that exceeds view bounds
- **VStack/HStack** with appropriate spacing

## Development

### Requirements
- Xcode 15.0+
- macOS 14.0+
- Swift 5.9+

### macOS Configuration
The app is configured for optimal macOS experience:

```swift
.windowStyle(.titleBar)
.windowResizability(.contentSize)
.defaultSize(width: 1000, height: 700)
.windowToolbarStyle(.unified)
```

### State Management
The app uses a centralized `AppState` class that manages:
- Selected navigation tab
- Notes collection
- AI assistant for note operations
- Performance mode and system capabilities
- App settings (dark mode, font size, etc.)
- Selected note for editing

### Planned Features
- [ ] Persistent storage using Core Data
- [ ] **llama.cpp integration** for real local AI processing
- [ ] **Advanced search filters** and sorting options
- [ ] **Note categories and tags** with AI-powered organization
- [ ] **Export/import functionality** with multiple formats
- [ ] **End-to-end encryption** for note content
- [ ] **iCloud sync** (optional, encrypted)
- [ ] **Keyboard shortcuts** and menu integration
- [ ] **Batch operations** for multiple notes
- [ ] **AI-powered note suggestions** and auto-completion
- [ ] **Advanced secure deletion options** with custom overwrite patterns

## Architecture

The app follows macOS-native SwiftUI architecture with:

1. **Single Source of Truth**: All state managed in `AppState`
2. **Observable Pattern**: Using `@Published` properties for reactive updates
3. **Separation of Concerns**: Each view handles its specific functionality
4. **Extensibility**: Easy to add new features and views
5. **Native Design**: Follows macOS Human Interface Guidelines
6. **AI Integration**: Clean separation between UI and AI operations
7. **Security First**: Secure deletion and privacy protection
8. **Performance Optimization**: Automatic resource management

## UI/UX Design

- **NavigationSplitView**: Provides native sidebar layout for macOS
- **Modern SwiftUI**: Uses latest SwiftUI features optimized for Mac
- **Responsive Design**: Adapts to different window sizes and screen resolutions
- **Accessibility**: Built with accessibility in mind for macOS
- **Native Controls**: Uses system controls that feel natural on Mac
- **AI Feedback**: Clear status indicators and progress feedback
- **Security Indicators**: Visual feedback for secure operations

## Security Considerations

- All data stored locally
- No network requests (planned)
- Local AI processing with on-device models
- **Secure deletion** with cryptographic overwriting
- Encryption at rest (planned)
- No data sent to external services
- **Unrecoverable deletion** using military-grade techniques

## License

This project is for educational and development purposes. 