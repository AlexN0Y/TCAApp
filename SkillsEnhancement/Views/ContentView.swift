//
//  ContentView.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 21.04.2025.
//

import SwiftUI
import ComposableArchitecture
import Combine
import NonEmpty

struct ContentView: View {
    private let store: StoreOf<ContentFeature>

    init(store: StoreOf<ContentFeature>) {
        self.store = store
    }
    
    var body: some View {
        switch store.state {
        case .loading:
            if let store = store.scope(state: \.loading, action: \.loading) {
                LoadingContentView(store: store)
            }

        case .loaded:
            if let store = store.scope(state: \.loaded, action: \.loaded) {
                LoadedContentView(store: store)
            }

        case .error:
            Text("Error")
        }
    }
}
