//
//  MainFeature.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 03.05.2025.
//

import ComposableArchitecture
import DependenciesMacros

@Reducer
struct MainFeature {

    @ObservableState
    @CasePathable
    enum State: Equatable {
        case home(HomeFeature.State)
        case characters(ContentFeature.State)
    }
    
    @CasePathable
    enum Action: Equatable {
        case home(HomeFeature.Action)
        case characters(ContentFeature.Action)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case logout
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.characters, action: \.characters) {
            ContentFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .home(.delegate(.showCharacters)):
                state = .characters(.init())
                return .none
                
            case .home(.delegate(.logout)):
                return .send(.delegate(.logout))
                
            case .characters(.delegate(.showHome)):
                state = .home(.init())
                return .none
                
            default:
                return .none
            }
        }
    }
}
