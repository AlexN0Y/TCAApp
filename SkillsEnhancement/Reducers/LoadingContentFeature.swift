//
//  LoadingContentFeature.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 01.05.2025.
//

import ComposableArchitecture
import NonEmpty

@Reducer
struct LoadingContentFeature {
    
    @ObservableState
    struct State: Equatable {}
    
    @CasePathable
    enum Action: Equatable {
        case task
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case finish(Result<NonEmptyArray<CharacterResult>, APIError>)
        }
    }
    
    @Dependency(\.networkClient) var networkClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    do {
                        let response = try await networkClient.fetchCharacters(page: 1)
                        await send(.delegate(.finish(.success(response))))
                    } catch {
                        let apiError: APIError
                        if let e = error as? APIError {
                            apiError = e
                        } else {
                            apiError = .network(error.localizedDescription)
                        }
                        await send(.delegate(.finish(.failure(apiError))))
                    }
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
