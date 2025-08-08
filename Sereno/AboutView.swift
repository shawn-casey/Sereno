//
//  AboutView.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import SwiftUI
import AppKit

/// View that displays information about the Sereno app using macOS-native design
struct AboutView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // App Icon and Title
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 8) {
                        Text("Sereno")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Secure Local AI Note-Taking")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
                
                // App Description
                GroupBox("About Sereno") {
                    Text("Sereno is a secure, local-first note-taking application that leverages artificial intelligence to enhance your productivity while keeping your data private and secure.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 16)
                }
                
                // Features
                GroupBox("Key Features") {
                    VStack(spacing: 16) {
                        FeatureRow(icon: "lock.shield", title: "Local AI Processing", description: "All AI features run locally on your device")
                        FeatureRow(icon: "eye.slash", title: "Privacy First", description: "Your notes never leave your device")
                        FeatureRow(icon: "bolt", title: "Fast & Responsive", description: "Optimized for speed and efficiency")
                        FeatureRow(icon: "icloud.slash", title: "No Cloud Required", description: "Works completely offline")
                    }
                    .padding(.vertical, 16)
                }
                
                // Version Info
                GroupBox("Version Information") {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Version")
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Text("1.0.0")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Build")
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Text("1")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 16)
                }
                
                // Links
                GroupBox("Legal") {
                    HStack(spacing: 16) {
                        Button("Privacy Policy") {
                            // TODO: Open privacy policy
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.regular)
                        
                        Button("Terms of Service") {
                            // TODO: Open terms of service
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.regular)
                    }
                    .padding(.vertical, 16)
                }
                
                Spacer(minLength: 40)
            }
            .padding(32)
        }
        .navigationTitle("About")
        .background(Color(.windowBackgroundColor))
    }
}

/// Row component for displaying a feature in the About view with macOS-native styling
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    AboutView(appState: AppState())
        .frame(minWidth: 800, minHeight: 600)
} 