//
//  CaptionaryApp.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Main app entry point
//

import SwiftUI

@main
struct CaptionaryApp: App {
    @StateObject private var sessionVM = SessionVM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionVM)
        }
    }
}
