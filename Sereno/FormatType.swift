//
//  FormatType.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import Foundation
import SwiftUI

/// Represents different formatting types for text
enum FormatType {
    case bold, italic, underline
    case bulletList, numberedList
    case heading1, heading2, heading3
    case quote, checkbox, link
    case attachment, code
    case more
}

/// Utility for handling markdown formatting
struct MarkdownFormatter {
    
    /// Applies formatting to selected text
    /// - Parameters:
    ///   - format: The type of formatting to apply
    ///   - text: The original text
    ///   - range: The range of text to format
    /// - Returns: The formatted text
    static func applyFormat(_ format: FormatType, to text: String, in range: NSRange) -> String {
        let selectedText = (text as NSString).substring(with: range)
        let beforeText = (text as NSString).substring(to: range.location)
        let afterText = (text as NSString).substring(from: range.location + range.length)
        
        let formattedText: String
        
        switch format {
        case .bold:
            formattedText = "**\(selectedText)**"
        case .italic:
            formattedText = "*\(selectedText)*"
        case .underline:
            formattedText = "__\(selectedText)__"
        case .bulletList:
            formattedText = selectedText.components(separatedBy: .newlines)
                .map { line in
                    if line.trimmingCharacters(in: .whitespaces).isEmpty {
                        return line
                    }
                    return "- \(line)"
                }
                .joined(separator: "\n")
        case .numberedList:
            formattedText = selectedText.components(separatedBy: .newlines)
                .enumerated()
                .map { index, line in
                    if line.trimmingCharacters(in: .whitespaces).isEmpty {
                        return line
                    }
                    return "\(index + 1). \(line)"
                }
                .joined(separator: "\n")
        case .heading1:
            formattedText = "# \(selectedText)"
        case .heading2:
            formattedText = "## \(selectedText)"
        case .heading3:
            formattedText = "### \(selectedText)"
        case .quote:
            formattedText = selectedText.components(separatedBy: .newlines)
                .map { line in
                    if line.trimmingCharacters(in: .whitespaces).isEmpty {
                        return line
                    }
                    return "> \(line)"
                }
                .joined(separator: "\n")
        case .checkbox:
            formattedText = selectedText.components(separatedBy: .newlines)
                .map { line in
                    if line.trimmingCharacters(in: .whitespaces).isEmpty {
                        return line
                    }
                    return "- [ ] \(line)"
                }
                .joined(separator: "\n")
        case .link:
            formattedText = "[\(selectedText)](url)"
        case .code:
            formattedText = "`\(selectedText)`"
        case .attachment:
            formattedText = "![\(selectedText)](attachment)"
        case .more:
            formattedText = selectedText // No change for more options
        }
        
        return beforeText + formattedText + afterText
    }
    
    /// Parses markdown text to attributed string for display
    /// - Parameter text: The markdown text to parse
    /// - Returns: Attributed string with formatting
    static func parseToAttributedString(_ text: String) -> AttributedString {
        // For now, return a simple attributed string without complex formatting
        // TODO: Implement proper markdown parsing when needed
        return AttributedString(text)
    }
} 