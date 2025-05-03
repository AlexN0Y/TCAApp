//
//  HomeView.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 03.05.2025.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    
    private let store: StoreOf<HomeFeature>
    
    init(store: StoreOf<HomeFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("👋 Welcome, \(store.username)!")
                .font(.largeTitle)
            
            Button("Show Characters") {
                store.send(.showCharactersButtonTapped)
            }
            .buttonStyle(.borderedProminent)
            
            Button("Logout") {
                store.send(.logoutButtonTapped)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
