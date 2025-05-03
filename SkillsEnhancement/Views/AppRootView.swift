//
//  AppRootView.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 03.05.2025.
//

import SwiftUI
import ComposableArchitecture

struct AppRootView: View {
    
    private let store: StoreOf<AppFeature>
    
    init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    var body: some View {
        switch store.state {
        case .auth:
            if let store = store.scope(state: \.auth, action: \.auth) {
                LoginView(store: store)
            }
        case .main:
            if let store = store.scope(state: \.main, action: \.main) {
                MainView(store: store)
            }
        }
    }
}
