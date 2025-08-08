//
//  ContentView.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import SwiftUI

/// Main content view that manages the sidebar navigation and view switching
struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            SidebarView(appState: appState)
        } detail: {
            // Detail view based on selected tab
            DetailView(appState: appState)
        }
        .navigationSplitViewStyle(.balanced)
        .preferredColorScheme(appState.isDarkMode ? .dark : .light)
    }
}

/// Sidebar view with navigation items using macOS-native styling
struct SidebarView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        List(SidebarTab.allCases, id: \.self, selection: $appState.selectedTab) { tab in
            HStack(spacing: 12) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(appState.selectedTab == tab ? .accentColor : .secondary)
                    .frame(width: 20)
                
                Text(tab.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(appState.selectedTab == tab ? .primary : .secondary)
            }
            .padding(.vertical, 4)
            .tag(tab)
        }
        .listStyle(.sidebar)
        .navigationTitle("Sereno")
        .frame(minWidth: 200, maxWidth: 250)
    }
}

/// Detail view that switches content based on selected tab
struct DetailView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        Group {
            switch appState.selectedTab {
            case .notes:
                NotesView(appState: appState)
            case .newNote:
                NewNoteView(appState: appState)
            case .askNotes:
                AskNotesView(appState: appState)
            case .settings:
                SettingsView(appState: appState)
            case .about:
                AboutView(appState: appState)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 800, minHeight: 600)
}
