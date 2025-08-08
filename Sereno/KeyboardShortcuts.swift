//
//  KeyboardShortcuts.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import Foundation
import SwiftUI
import AppKit

/// Manages keyboard shortcuts for the app
struct KeyboardShortcuts {
    
    /// Handles key press events for formatting shortcuts
    /// - Parameters:
    ///   - event: The key event
    ///   - text: The current text content
    ///   - selectedRange: The current text selection range
    ///   - onFormat: Callback when formatting should be applied
    /// - Returns: True if the event was handled, false otherwise
    static func handleKeyPress(
        _ event: NSEvent,
        text: String,
        selectedRange: NSRange,
        onFormat: @escaping (FormatType) -> Void
    ) -> Bool {
        // Check for command key combinations
        guard event.modifierFlags.contains(.command) else { return false }
        
        switch event.keyCode {
        case 11: // B key
            if event.modifierFlags.contains(.command) {
                onFormat(.bold)
                return true
            }
        case 34: // I key
            if event.modifierFlags.contains(.command) {
                onFormat(.italic)
                return true
            }
        case 32: // U key
            if event.modifierFlags.contains(.command) {
                onFormat(.underline)
                return true
            }
        case 37: // L key
            if event.modifierFlags.contains(.command) && event.modifierFlags.contains(.shift) {
                onFormat(.bulletList)
                return true
            }
        case 45: // N key
            if event.modifierFlags.contains(.command) && event.modifierFlags.contains(.shift) {
                onFormat(.numberedList)
                return true
            }
        case 18: // 1 key
            if event.modifierFlags.contains(.command) {
                onFormat(.heading1)
                return true
            }
        case 19: // 2 key
            if event.modifierFlags.contains(.command) {
                onFormat(.heading2)
                return true
            }
        case 20: // 3 key
            if event.modifierFlags.contains(.command) {
                onFormat(.heading3)
                return true
            }
        case 40: // K key
            if event.modifierFlags.contains(.command) {
                onFormat(.link)
                return true
            }
        case 46: // M key
            if event.modifierFlags.contains(.command) && event.modifierFlags.contains(.shift) {
                onFormat(.more)
                return true
            }
        default:
            break
        }
        
        return false
    }
    
    /// Gets the shortcut string for a format type
    /// - Parameter format: The format type
    /// - Returns: The keyboard shortcut string
    static func shortcutString(for format: FormatType) -> String {
        switch format {
        case .bold:
            return "⌘B"
        case .italic:
            return "⌘I"
        case .underline:
            return "⌘U"
        case .bulletList:
            return "⌘⇧L"
        case .numberedList:
            return "⌘⇧N"
        case .heading1:
            return "⌘1"
        case .heading2:
            return "⌘2"
        case .heading3:
            return "⌘3"
        case .quote:
            return "⌘⇧Q"
        case .checkbox:
            return "⌘⇧T"
        case .link:
            return "⌘K"
        case .attachment:
            return "⌘⇧A"
        case .code:
            return "⌘⇧C"
        case .more:
            return "⌘⇧M"
        }
    }
    
    /// Gets the icon name for a format type
    /// - Parameter format: The format type
    /// - Returns: The SF Symbol icon name
    static func iconName(for format: FormatType) -> String {
        switch format {
        case .bold:
            return "bold"
        case .italic:
            return "italic"
        case .underline:
            return "underline"
        case .bulletList:
            return "list.bullet"
        case .numberedList:
            return "list.number"
        case .heading1:
            return "textformat.size"
        case .heading2:
            return "textformat.size"
        case .heading3:
            return "textformat.size"
        case .quote:
            return "text.quote"
        case .checkbox:
            return "checkmark.square"
        case .link:
            return "link"
        case .attachment:
            return "paperclip"
        case .code:
            return "chevron.left.forwardslash.chevron.right"
        case .more:
            return "ellipsis.circle"
        }
    }
} 