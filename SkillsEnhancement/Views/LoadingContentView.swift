//
//  LoadingContentView.swift
//  SkillsEnhancement
//
//  Created by Yehor Kyrylov on 22.04.2025.
//

import SwiftUI
import ComposableArchitecture
import NonEmpty

@Reducer
struct LoadingContentFeature {

    @ObservableState
    struct State {}

    @CasePathable
    enum Action {
        case task
        case delegate(Delegate)

        enum Delegate {
            case finish(Result<NonEmptyArray<CharacterResult>, Error>)
        }
    }

    @Dependency(\.networkClient) var networkClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    await send(
                        .delegate(
                            .finish(
                                Result {
                                    try await networkClient.fetchCharacters(page: 1)
                                }
                            )
                        )
                    )
                }

            case .delegate:
                return .none
            }
        }
    }
}

struct LoadingContentView: View {
    private let store: StoreOf<LoadingContentFeature>

    init(store: StoreOf<LoadingContentFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: UIScreen.main.bounds.width - 32, height: 75)
            }
        }
        .task {
            await store.send(.task).finish()
        }
    }
}
