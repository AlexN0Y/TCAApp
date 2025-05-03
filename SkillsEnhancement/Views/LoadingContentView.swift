//
//  LoadingContentView.swift
//  SkillsEnhancement
//
//  Created by Yehor Kyrylov on 22.04.2025.
//

import SwiftUI
import ComposableArchitecture
import NonEmpty

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
