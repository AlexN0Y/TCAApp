//
//  MainView.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 02.05.2025.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {
    
  private let store: StoreOf<MainFeature>
    
    init(store: StoreOf<MainFeature>) {
        self.store = store
    }

  var body: some View {
      switch store.state {
      case .home:
          if let store = store.scope(state: \.home, action: \.home) {
              HomeView(store: store)
          }
      case .characters:
          if let store = store.scope(state: \.characters, action: \.characters) {
              ContentView(store: store)
          }
      }
  }
}

