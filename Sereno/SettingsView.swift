//
//  SettingsView.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import SwiftUI
import AppKit

/// View for app settings and preferences using macOS-native design
struct SettingsView: View {
    @ObservedObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Appearance Section
                GroupBox("Appearance") {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.purple)
                                .font(.system(size: 16))
                                .frame(width: 20)
                            
                            Text("Dark Mode")
                                .font(.system(size: 14))
                            
                            Spacer()
                            
                            Toggle("", isOn: $appState.isDarkMode)
                                .toggleStyle(.switch)
                        }
                        
                        HStack {
                            Image(systemName: "textformat.size")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Font Size")
                                    .font(.system(size: 14))
                                Text("\(Int(appState.fontSize))pt")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Slider(value: $appState.fontSize, in: 12...24, step: 1)
                                .frame(width: 120)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Performance Settings Section
                GroupBox("Performance") {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "speedometer")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Performance Mode")
                                    .font(.system(size: 14))
                                Text(appState.performanceMode.description)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Picker("Performance Mode", selection: $appState.performanceMode) {
                                ForEach(PerformanceMode.allCases, id: \.self) { mode in
                                    HStack {
                                        Image(systemName: mode.icon)
                                        Text(mode.rawValue)
                                    }
                                    .tag(mode)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: appState.performanceMode) { _, newMode in
                                appState.noteAssistant.setPerformanceMode(newMode)
                            }
                        }
                        
                        if let capabilities = appState.systemCapabilities {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.green)
                                    .font(.system(size: 16))
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("System Capabilities")
                                        .font(.system(size: 14))
                                    Text(SystemInfo.getSystemDescription(for: capabilities))
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        let config = ModelConfiguration(performanceMode: appState.performanceMode)
                        HStack {
                            Image(systemName: config.estimatedPowerConsumption.icon)
                                .foregroundColor(powerConsumptionColor(config.estimatedPowerConsumption))
                                .font(.system(size: 16))
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Estimated Power Usage")
                                    .font(.system(size: 14))
                                Text("\(config.estimatedPowerConsumption.rawValue) • \(config.maxMemoryUsage)MB RAM • \(config.maxConcurrentOperations) concurrent ops")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // AI Settings Section
                GroupBox("Local AI Model") {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Model Path")
                                    .font(.system(size: 14))
                                Text(appState.noteAssistant.modelPath.isEmpty ? "No model selected" : appState.noteAssistant.modelPath)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Button("Select Model") {
                                selectModelPath()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(aiStatusColor)
                                .font(.system(size: 16))
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("AI Status")
                                    .font(.system(size: 14))
                                Text(aiStatusText)
                                    .font(.system(size: 12))
                                    .foregroundColor(aiStatusColor)
                            }
                            
                            Spacer()
                        }
                        
                        if appState.noteAssistant.isAvailable {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                    .font(.system(size: 16))
                                    .frame(width: 20)
                                
                                Text("AI features are available")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Storage Section
                GroupBox("Storage") {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "internaldrive")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Local Storage")
                                    .font(.system(size: 14))
                                Text("All data stored locally")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                                .frame(width: 20)
                            
                            Text("Notes")
                                .font(.system(size: 14))
                            
                            Spacer()
                            
                            Text("\(appState.notes.count)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // About Section
                GroupBox("About") {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                                .frame(width: 20)
                            
                            Text("Version")
                                .font(.system(size: 14))
                            
                            Spacer()
                            
                            Text("1.0.0")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Security")
                                    .font(.system(size: 14))
                                Text("End-to-end encryption")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(24)
        }
        .navigationTitle("Settings")
        .background(Color(.windowBackgroundColor))
        .preferredColorScheme(appState.isDarkMode ? .dark : .light)
    }
    
    // MARK: - Computed Properties
    
    private var aiStatusColor: Color {
        switch appState.noteAssistant.status {
        case .ready:
            return .green
        case .initializing:
            return .orange
        case .error(_):
            return .red
        case .notInitialized:
            return .gray
        }
    }
    
    private var aiStatusText: String {
        switch appState.noteAssistant.status {
        case .ready:
            return "Ready"
        case .initializing:
            return "Initializing..."
        case .error(_):
            return "Error"
        case .notInitialized:
            return "Not Configured"
        }
    }
    
    // MARK: - Private Methods
    
    private func selectModelPath() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.data] // Allow any file type for now
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                appState.noteAssistant.setModelPath(url.path)
            }
        }
    }
    
    private func powerConsumptionColor(_ consumption: PowerConsumption) -> Color {
        switch consumption {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}

#Preview {
    SettingsView(appState: AppState())
        .frame(minWidth: 800, minHeight: 600)
} 