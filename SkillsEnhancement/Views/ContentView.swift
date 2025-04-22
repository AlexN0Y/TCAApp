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

@Reducer
struct ContentFeature {

    @CasePathable
    @ObservableState
    enum State {
        case loading(LoadingContentFeature.State)
        case loaded(LoadedContentFeature.State)
        case error

        init() {
            self = .loading(LoadingContentFeature.State())
        }
    }

    @CasePathable
    enum Action {
        case loading(LoadingContentFeature.Action)
        case loaded(LoadedContentFeature.Action)
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

            case .loaded:
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
