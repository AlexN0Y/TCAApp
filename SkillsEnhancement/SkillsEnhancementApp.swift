//
//  SkillsEnhancementApp.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 21.04.2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct SkillsEnhancementApp: App {
    
    let store = Store(initialState: ContentFeature.State()) {
        ContentFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
