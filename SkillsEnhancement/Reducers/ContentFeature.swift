//
//  ContentFeature.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 01.05.2025.
//

import ComposableArchitecture

@Reducer
struct ContentFeature {

    @CasePathable
    @ObservableState
    enum State: Equatable {
        case loading(LoadingContentFeature.State)
        case loaded(LoadedContentFeature.State)
        case error

        init() {
            self = .loading(LoadingContentFeature.State())
        }
    }

    @CasePathable
    enum Action: Equatable {
        case loading(LoadingContentFeature.Action)
        case loaded(LoadedContentFeature.Action)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
          case showHome
        }
    }
    
    @Dependency(\.networkClient) var networkClient
    
    var body: some Reducer<State, Action> {
        Scope(state: \.loading, action: \.loading) {
            LoadingContentFeature()
        }
        Scope(state: \.loaded, action: \.loaded) {
            LoadedContentFeature()
        }

        Reduce { state, action in
            switch action {
            case let .loading(loadingAction):
                return handleLoadingAction(action: loadingAction, state: &state)
                
            case .loaded(.delegate(.showHome)):
                return .send(.delegate(.showHome))
                
            case .loaded:
              return .none
                
            case .delegate:
              return .none
            }
        }
    }

    private func handleLoadingAction(action: LoadingContentFeature.Action, state: inout State) -> Effect<Action> {
        switch action {
        case .task:
            return .none

        case let .delegate(.finish(.success(response))):
            state = .loaded(LoadedContentFeature.State(characterResult: response))

            return .none

        case .delegate(.finish(.failure)):
            state = .error

            return .none
        }
    }
}
