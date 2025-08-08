import SwiftUI
import AppKit

/// A WYSIWYG rich text editor that renders formatting in real-time
struct RichTextEditor: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var onTextChange: ((NSAttributedString) -> Void)?
    var onSelectionChange: ((NSRange) -> Void)?
    var font: NSFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    
    init(attributedText: Binding<NSAttributedString>, onTextChange: ((NSAttributedString) -> Void)? = nil, onSelectionChange: ((NSRange) -> Void)? = nil, font: NSFont = .monospacedSystemFont(ofSize: 14, weight: .regular)) {
        self._attributedText = attributedText
        self.onTextChange = onTextChange
        self.onSelectionChange = onSelectionChange
        self.font = font
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        // Create scroll view and text view
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        // Set up text system
        let storage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let container = NSTextContainer(size: NSSize(width: scrollView.bounds.width, height: .greatestFiniteMagnitude))
        
        storage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(container)
        container.widthTracksTextView = true
        
        // Create text view with the text system
        let textView = NSTextView(frame: scrollView.bounds, textContainer: container)
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        
        // Configure scroll view
        scrollView.documentView = textView
        scrollView.contentView.postsBoundsChangedNotifications = true
        textView.delegate = context.coordinator
        textView.font = font
        textView.isRichText = true
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticLinkDetectionEnabled = true
        textView.smartInsertDeleteEnabled = true
        textView.usesFontPanel = true
        textView.usesRuler = true
        textView.isGrammarCheckingEnabled = true
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.textColor = .textColor
        
        // Set text container properties
        textView.textContainer?.lineFragmentPadding = 12
        textView.textContainer?.widthTracksTextView = true
        
        // Set layout manager properties
        textView.layoutManager?.defaultAttachmentScaling = .scaleProportionallyDown
        
        // Set text view appearance
        textView.backgroundColor = .clear
        textView.drawsBackground = true
        
        // Set initial content
        textView.textStorage?.setAttributedString(attributedText)
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // Only update if content has changed externally
        if !context.coordinator.isUpdating && 
           textView.attributedString() != attributedText {
            textView.textStorage?.setAttributedString(attributedText)
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        var isUpdating = false
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            isUpdating = true
            parent.onTextChange?(textView.attributedString())
            isUpdating = false
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.onSelectionChange?(textView.selectedRange())
        }
    }
}

// MARK: - Style Application

extension NSTextView {
    func applyStyle(_ style: TextStyle, to range: NSRange? = nil) {
        guard let textStorage = textStorage else { return }
        let effectiveRange = range ?? selectedRange()
        
        guard effectiveRange.location != NSNotFound,
              effectiveRange.location + effectiveRange.length <= textStorage.length else {
            return
        }
        
        textStorage.beginEditing()
        
        switch style {
        case .bold:
            toggleBold(range: effectiveRange)
        case .italic:
            toggleItalic(range: effectiveRange)
        case .underline:
            toggleUnderline(range: effectiveRange)
        case .code:
            toggleCodeStyle(range: effectiveRange)
        case .header(let level):
            applyHeader(level: level, range: effectiveRange)
        case .link(let url):
            applyLink(url: url, range: effectiveRange)
        case .bulletList:
            applyBulletList(range: effectiveRange)
        }
        
        textStorage.endEditing()
        needsDisplay = true
    }
    
    private func toggleBold(range: NSRange) {
        guard let textStorage = textStorage else { return }
        let boldFont = NSFont.boldSystemFont(ofSize: font?.pointSize ?? 14)
        
        var hasBold = true
        textStorage.enumerateAttribute(.font, in: range, options: []) { value, subrange, stop in
            if let font = value as? NSFont, !font.fontDescriptor.symbolicTraits.contains(.bold) {
                hasBold = false
                stop.pointee = true
            }
        }
        
        if hasBold {
            textStorage.removeAttribute(.font, range: range)
        } else {
            textStorage.addAttribute(.font, value: boldFont, range: range)
        }
    }
    
    private func toggleItalic(range: NSRange) {
        guard let textStorage = textStorage else { return }
        
        var hasItalic = true
        textStorage.enumerateAttribute(.font, in: range, options: []) { value, subrange, stop in
            if let font = value as? NSFont, !font.fontDescriptor.symbolicTraits.contains(.italic) {
                hasItalic = false
                stop.pointee = true
            }
        }
        
        if hasItalic {
            textStorage.removeAttribute(.font, range: range)
        } else {
            if let currentFont = font {
                let italicFont = NSFontManager.shared.convert(currentFont, toHaveTrait: .italicFontMask)
                textStorage.addAttribute(.font, value: italicFont, range: range)
            }
        }
    }
    
    private func toggleUnderline(range: NSRange) {
        guard let textStorage = textStorage else { return }
        
        var hasUnderline = true
        textStorage.enumerateAttribute(.underlineStyle, in: range, options: []) { value, subrange, stop in
            if value == nil {
                hasUnderline = false
                stop.pointee = true
            }
        }
        
        if hasUnderline {
            textStorage.removeAttribute(.underlineStyle, range: range)
        } else {
            textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
    }
    
    private func toggleCodeStyle(range: NSRange) {
        guard let textStorage = textStorage else { return }
        let codeFont = NSFont.monospacedSystemFont(ofSize: font?.pointSize ?? 14, weight: .regular)
        let codeBackground: NSColor = {
            let dynamicColor = NSColor(name: nil, dynamicProvider: { appearance in
                switch appearance.name {
                case .aqua, .vibrantLight, .accessibilityHighContrastAqua, .accessibilityHighContrastVibrantLight:
                    return NSColor(calibratedWhite: 0.95, alpha: 1.0)
                default:
                    return NSColor(calibratedWhite: 0.15, alpha: 1.0)
                }
            })
            return dynamicColor
        }()
        
        var hasCodeStyle = true
        textStorage.enumerateAttribute(.font, in: range, options: []) { value, subrange, stop in
            if let font = value as? NSFont, !font.fontName.contains("Mono") {
                hasCodeStyle = false
                stop.pointee = true
            }
        }
        
        if hasCodeStyle {
            textStorage.removeAttribute(.font, range: range)
            textStorage.removeAttribute(.backgroundColor, range: range)
        } else {
            textStorage.addAttributes([
                .font: codeFont,
                .backgroundColor: codeBackground
            ], range: range)
        }
    }
    
    private func applyHeader(level: Int, range: NSRange) {
        guard let textStorage = textStorage else { return }
        let size: CGFloat
        switch level {
        case 1: size = 24
        case 2: size = 20
        case 3: size = 18
        default: size = 16
        }
        
        let headerFont = NSFont.systemFont(ofSize: size, weight: .bold)
        textStorage.addAttribute(.font, value: headerFont, range: range)
    }
    
    private func applyLink(url: URL, range: NSRange) {
        guard let textStorage = textStorage else { return }
        textStorage.addAttribute(.link, value: url, range: range)
    }
    
    private func applyBulletList(range: NSRange) {
        guard let textStorage = textStorage else { return }
        let text = textStorage.string
        let paragraphRange = (text as NSString).paragraphRange(for: range)
        
        // Get the paragraph text
        let paragraphText = (text as NSString).substring(with: paragraphRange)
        
        // Add bullet point if not already present
        if !paragraphText.hasPrefix("• ") {
            textStorage.replaceCharacters(in: NSRange(location: paragraphRange.location, length: 0), with: "• ")
        }
    }
}

// MARK: - Text Styles

enum TextStyle: Equatable {
    case bold
    case italic
    case underline
    case code
    case header(level: Int)
    case link(url: URL)
    case bulletList
    
    var systemImage: String {
        switch self {
        case .bold: return "bold"
        case .italic: return "italic"
        case .underline: return "underline"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .header: return "textformat.size"
        case .link: return "link"
        case .bulletList: return "list.bullet"
        }
    }
    
    var shortcut: String {
        switch self {
        case .bold: return "⌘B"
        case .italic: return "⌘I"
        case .underline: return "⌘U"
        case .code: return "⌘E"
        case .header: return "⌘H"
        case .link: return "⌘K"
        case .bulletList: return "⌘L"
        }
    }
}

// MARK: - Equatable Implementation

extension TextStyle {
    static func == (lhs: TextStyle, rhs: TextStyle) -> Bool {
        switch (lhs, rhs) {
        case (.bold, .bold),
             (.italic, .italic),
             (.underline, .underline),
             (.code, .code),
             (.bulletList, .bulletList):
            return true
        case (.header(let lhsLevel), .header(let rhsLevel)):
            return lhsLevel == rhsLevel
        case (.link(let lhsURL), .link(let rhsURL)):
            return lhsURL == rhsURL
        default:
            return false
        }
    }
}