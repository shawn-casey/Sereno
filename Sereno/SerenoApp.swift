//
//  SerenoApp.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import SwiftUI

@main
struct SerenoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1000, height: 700)
        .windowToolbarStyle(.unified)
    }
}
