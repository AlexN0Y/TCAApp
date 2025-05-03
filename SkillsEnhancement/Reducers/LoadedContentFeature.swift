//
//  LoadedContentFeature.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 01.05.2025.
//

import ComposableArchitecture
import NonEmpty

@Reducer
struct LoadedContentFeature {
    
    @ObservableState
    struct State: Equatable {
        enum LoadingState: Equatable {
            case prefetching(Int)
            case prefetched(Int)
            
            var isLoading: Bool {
                switch self {
                case .prefetching:
                    true
                    
                case .prefetched:
                    false
                }
            }
            
            var nextPage: Int {
                switch self {
                case let .prefetching(page):
                    page + 1
                    
                case let .prefetched(currentPage):
                    currentPage
                }
            }
            
            func nextLoadingState() -> Self {
                switch self {
                case let .prefetching(currentPage):
                    return .prefetched(currentPage)
                    
                case let .prefetched(currentpage):
                    return .prefetching(currentpage + 1)
                }
            }
        }
        
        var childCircleRows: IdentifiedArrayOf<CharacterResult>
        var loadingState: LoadingState
        var selectedCharacter: CharacterResult?
        
        init(characterResult: NonEmptyArray<CharacterResult>) {
            childCircleRows = IdentifiedArrayOf(uniqueElements: characterResult)
            loadingState = .prefetched(1)
        }
    }
    
    @CasePathable
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear(CharacterResult.Id)
        case onCharacterTapped(CharacterResult)
        case prefetchResult(Result<NonEmptyArray<CharacterResult>, APIError>)
        case backButtonTapped
        
        case delegate(Delegate)
        enum Delegate: Equatable {
            case showHome
        }
    }
    
    @Dependency(\.networkClient) var networkClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case let .onAppear(characterId):
                if characterId == state.childCircleRows.last?.id, !state.loadingState.isLoading {
                    state.loadingState = state.loadingState.nextLoadingState()
                    
                    let nextPage = state.loadingState.nextPage
                    state.loadingState = state.loadingState.nextLoadingState()
                    
                    return .run { send in
                        do {
                            let response = try await networkClient.fetchCharacters(page: nextPage)
                            await send(.prefetchResult(.success(response)))
                        } catch let apiError as APIError {
                            await send(.prefetchResult(.failure(apiError)))
                        } catch {
                            await send(.prefetchResult(.failure(.network(error.localizedDescription))))
                        }
                    }
                }
                
                return .none
                
            case let .onCharacterTapped(character):
                state.selectedCharacter = character
                
                return .none
                
            case let .prefetchResult(.success(response)):
                state.childCircleRows.append(contentsOf: response)
                state.loadingState = state.loadingState.nextLoadingState()
                
                return .none
                
            case .prefetchResult(.failure):
                let currentPage = state.loadingState.nextPage
                state.loadingState = .prefetched(currentPage)
                
                return .none
                
            case .binding:
                return .none
                
            case .backButtonTapped:
                return .send(.delegate(.showHome))
                
            case .delegate:
                return .none
            }
        }
    }
}
