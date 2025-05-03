//
//  HomeFeature.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 03.05.2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct HomeFeature {
    
  @ObservableState
  struct State: Equatable {
    var username: String = ""
  }

  enum Action: Equatable {
    case showCharactersButtonTapped
    case logoutButtonTapped
    case delegate(Delegate)

    enum Delegate: Equatable {
      case logout
      case showCharacters
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .showCharactersButtonTapped:
        return .send(.delegate(.showCharacters))

      case .logoutButtonTapped:
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        return .send(.delegate(.logout))

      case .delegate:
        return .none
      }
    }
  }
}
