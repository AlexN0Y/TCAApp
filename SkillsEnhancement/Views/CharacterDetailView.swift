//
//  CharacterDetailView.swift
//  SkillsEnhancement
//
//  Created by Yehor Kyrylov on 22.04.2025.
//

import SwiftUI

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
