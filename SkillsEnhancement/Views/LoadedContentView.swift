//
//  LoadedContentView.swift
//  SkillsEnhancement
//
//  Created by Yehor Kyrylov on 22.04.2025.
//

import SwiftUI
import ComposableArchitecture
import NonEmpty

@Reducer
struct LoadedContentFeature {

    @ObservableState
    struct State {
        enum LoadingState {
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
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear(CharacterResult.Id)
        case onCharacterTapped(CharacterResult)
        case prefetchResult(Result<NonEmptyArray<CharacterResult>, Error>)
    }

    @Dependency(\.networkClient) var networkClient

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case let .onAppear(characterId):
                if characterId == state.childCircleRows.last?.id, !state.loadingState.isLoading {
                    state.loadingState = state.loadingState.nextLoadingState()

                    return .run { [nextPage = state.loadingState.nextPage] send in
                        await send(
                            .prefetchResult(
                                Result {
                                    try await networkClient.fetchCharacters(page: nextPage)
                                }
                            )
                        )
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
            }
        }
    }
}

struct LoadedContentView: View {
    @Bindable var store: StoreOf<LoadedContentFeature>

    init(store: StoreOf<LoadedContentFeature>) {
        self.store = store
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(store.childCircleRows) { row in
                        CharacterView(
                            character: row,
                            onTap: {
                                store.send(.onCharacterTapped(row))
                            }
                        )
                        .onAppear {
                            store.send(.onAppear(row.id))
                        }
                    }

                    if store.loadingState.isLoading {
                        ProgressView()
                    }
                }
            }
            .navigationDestination(
                item: $store.selectedCharacter,
                destination: { character in
                    CharacterDetailView(character: character)
                }
            )
        }
    }
}

private struct CharacterView: View {
    private let character: CharacterResult
    private let onTap: () -> Void

    init(
        character: CharacterResult,
        onTap: @escaping () -> Void
    ) {
        self.character = character
        self.onTap = onTap
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            Circle()
                .fill(.green)
                .frame(width: 200, height: 200)
                .overlay {
                    Text(character.name.rawValue)
                        .foregroundStyle(Color.black)
                }
        }
    }
}
