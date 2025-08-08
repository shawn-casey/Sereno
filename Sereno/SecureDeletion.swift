//
//  SecureDeletion.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import Foundation
import Security
import Darwin

/// Utilities for secure, unrecoverable file deletion on macOS
struct SecureDeletion {
    
    /// Securely deletes a file by overwriting it with random data before deletion
    /// - Parameter fileURL: The URL of the file to securely delete
    /// - Returns: True if deletion was successful, false otherwise
    static func secureDelete(fileURL: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return false
        }
        
        do {
            // Get file size for proper overwriting
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            guard let fileSize = fileAttributes[.size] as? Int64 else {
                return false
            }
            
            // Open file for writing
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            defer {
                try? fileHandle.close()
            }
            
            // Overwrite with random data multiple times
            let overwritePasses = 3
            let chunkSize = 64 * 1024 // 64KB chunks for efficiency
            
            for _ in 0..<overwritePasses {
                try fileHandle.seek(toOffset: 0)
                
                var bytesWritten: Int64 = 0
                while bytesWritten < fileSize {
                    let remainingBytes = fileSize - bytesWritten
                    let currentChunkSize = min(Int64(chunkSize), remainingBytes)
                    
                    // Generate random data
                    let randomData = generateRandomData(size: Int(currentChunkSize))
                    fileHandle.write(randomData)
                    
                    bytesWritten += currentChunkSize
                }
                
                // Force flush to disk
                try fileHandle.synchronize()
            }
            
            // Close file handle
            try fileHandle.close()
            
            // Delete the file
            try FileManager.default.removeItem(at: fileURL)
            
            return true
            
        } catch {
            print("Secure deletion failed: \(error)")
            return false
        }
    }
    
    /// Securely deletes multiple files
    /// - Parameter fileURLs: Array of file URLs to securely delete
    /// - Returns: Array of URLs that were successfully deleted
    static func secureDeleteMultiple(fileURLs: [URL]) -> [URL] {
        var successfullyDeleted: [URL] = []
        
        for fileURL in fileURLs {
            if secureDelete(fileURL: fileURL) {
                successfullyDeleted.append(fileURL)
            }
        }
        
        return successfullyDeleted
    }
    
    /// Generates cryptographically secure random data
    /// - Parameter size: The size of random data to generate
    /// - Returns: Random data as Data object
    private static func generateRandomData(size: Int) -> Data {
        var randomData = Data(count: size)
        let result = randomData.withUnsafeMutableBytes { pointer in
            SecRandomCopyBytes(kSecRandomDefault, size, pointer.baseAddress!)
        }
        
        if result != errSecSuccess {
            // Fallback to less secure random if cryptographic random fails
            randomData = Data((0..<size).map { _ in UInt8.random(in: 0...255) })
        }
        
        return randomData
    }
    
    /// Securely deletes a note's associated files (main content and metadata)
    /// - Parameter note: The note to securely delete
    /// - Parameter baseDirectory: The base directory where note files are stored
    /// - Returns: True if all files were successfully deleted
    static func secureDeleteNote(_ note: Note, from baseDirectory: URL) -> Bool {
        let noteID = note.id.uuidString
        
        // Define file paths for the note
        let contentFileURL = baseDirectory.appendingPathComponent("\(noteID).txt")
        let metadataFileURL = baseDirectory.appendingPathComponent("\(noteID).json")
        
        // Securely delete both files
        let contentDeleted = secureDelete(fileURL: contentFileURL)
        let metadataDeleted = secureDelete(fileURL: metadataFileURL)
        
        return contentDeleted && metadataDeleted
    }
    
    /// Securely deletes all notes from a directory
    /// - Parameter baseDirectory: The base directory containing note files
    /// - Returns: Number of notes successfully deleted
    static func secureDeleteAllNotes(from baseDirectory: URL) -> Int {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: baseDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            
            let deletedURLs = secureDeleteMultiple(fileURLs: fileURLs)
            return deletedURLs.count
            
        } catch {
            print("Failed to enumerate files for secure deletion: \(error)")
            return 0
        }
    }
} 