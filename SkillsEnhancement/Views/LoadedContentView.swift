//
//  LoadedContentView.swift
//  SkillsEnhancement
//
//  Created by Yehor Kyrylov on 22.04.2025.
//

import SwiftUI
import ComposableArchitecture
import NonEmpty

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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        store.send(.delegate(.showHome))
                    }
                }
            }
            .scrollIndicators(.hidden)
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
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green)
                .frame(width: UIScreen.main.bounds.width - 32, height: 75)
                .overlay {
                    Text(character.name.rawValue)
                        .foregroundStyle(Color.black)
                }
        }
    }
}
