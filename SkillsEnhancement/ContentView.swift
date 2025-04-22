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
    
    @ObservableState
    struct State: Equatable {
        var childCircleRows: IdentifiedArrayOf<ChildCircleView.ViewState> = []
        var selectedCharacter: CharacterResult? = nil
        var currentPage: Int = 1
        var isLoadingPage: Bool = false
    }
    
    @CasePathable
    enum Action {
        case childCircleRowsAction(IdentifiedAction<ChildCircleView.ViewState.ID, ChildCircleView.ViewAction>)
        case selectCharacter(CharacterResult?)
        case onButtonTapped
        case fetchResult(Result<NonEmptyArray<CharacterResult>, Error>)
        case loadNextPage
    }
    
    @Dependency(\.networkClient) var networkClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .fetchResult(.success(response)):
                let newRows = IdentifiedArray(
                    uniqueElements: response.map {
                        ChildCircleView.ViewState(character: $0)
                    }
                )
                if state.currentPage == 1 {
                    state.childCircleRows = IdentifiedArray(uniqueElements: newRows)
                } else {
                    state.childCircleRows += IdentifiedArray(uniqueElements: newRows)
                }
                state.isLoadingPage = false
                state.currentPage += 1
                
                return .none
                
            case let .selectCharacter(character):
                state.selectedCharacter = character
                return .none
                
            case let .fetchResult(.failure(error)):
                print("❌ fetchCharacters failed:", error)
                
                return .none
                
            case .onButtonTapped:
                state.currentPage = 1
                state.isLoadingPage = true
                
                return .run { send in
                    await send(
                        .fetchResult(
                            Result { try await networkClient.fetchCharacters(page: 1) }
                        )
                    )
                }
                
            case .loadNextPage:
                guard !state.isLoadingPage else { return .none }
                print("Loading next page")
                state.isLoadingPage = true
                let currentPage = state.currentPage + 1
                return .run { send in
                    await send(
                        .fetchResult(
                            Result {
                                try await networkClient.fetchCharacters(page: currentPage)
                            }
                        )
                    )
                }
                
            case let .childCircleRowsAction(.element(id, action)):
                
                switch action {
                case .onTap:
                    guard let character = state.childCircleRows[id: id]?.character else {
                        return .none
                    }
                    return .send(.selectCharacter(character))
                }
            }
        }
    }
}

struct ContentView: View {
    
    let store: StoreOf<ContentFeature>
    @StateObject private var viewStore: ViewStoreOf<ContentFeature>
    
    init(store: StoreOf<ContentFeature>) {
        self.store = store
        self._viewStore = StateObject(
            wrappedValue: ViewStore(
                store,
                observe: { $0 }
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Button {
                        store.send(.onButtonTapped)
                    } label: {
                        Text("Fetch characters")
                    }
                }
                .padding()
                
                VStack {
                    ForEach(store.scope(state: \.childCircleRows, action: \.childCircleRowsAction)) { store in
                        ChildCircleView(store: store)
                            .onAppear {
                                if store.id ==
                                    viewStore.childCircleRows.last?.id
                                {
                                    viewStore.send(.loadNextPage)
                                }
                            }
                    }
                    
                    if viewStore.isLoadingPage {
                        ProgressView()
                    }
                }
            }
            .navigationDestination(
                item: viewStore.binding(
                    get: \.selectedCharacter,
                    send: ContentFeature.Action.selectCharacter
                )
            ) { character in
                CharacterDetailView(character: character)
            }
            .navigationTitle("Rick & Morty")
        }
    }
}

struct ChildCircleView: View {
    
    @ObservableState
    struct ViewState: Identifiable, Equatable {
        let character: CharacterResult
        
        var id: CharacterResult.Id {
            character.id
        }
        
        var name: NonEmptyString {
            character.name
        }
    }
    
    enum ViewAction {
        case onTap
    }
    
    let store: Store<ViewState, ViewAction>
    
    init(store: Store<ViewState, ViewAction>) {
        self.store = store
    }
    
    var body: some View {
        Circle()
            .fill(.green)
            .frame(width: 200, height: 200)
            .overlay {
                Text(store.name.rawValue)
                    .foregroundStyle(Color.black)
            }
            .onTapGesture {
                store.send(.onTap)
            }
        
    }
}

struct CharacterDetailView: View {
    
    let character: CharacterResult
    
    var body: some View {
        ScrollView {
            AsyncImage(url: character.image) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(character.name.rawValue)
                    .font(.largeTitle).bold()
                
                Text("Status: \(character.status.rawValue)")
                Text("Species: \(character.species.rawValue)")
                Text("Gender: \(character.gender.rawValue)")
            }
            .padding()
        }
        .navigationTitle(character.name.rawValue)
    }
}
