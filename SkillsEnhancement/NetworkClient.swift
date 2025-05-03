//
//  NetworkClient.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 21.04.2025.
//

import DependenciesMacros
import Dependencies
import Foundation
import NonEmpty
import Tagged

@DependencyClient
public struct NetworkClient: Sendable {
    
    var fetchCharacters: @Sendable (_ page: Int) async throws -> NonEmptyArray<CharacterResult>
}

public extension DependencyValues {
    
    var networkClient: NetworkClient {
        get { self[NetworkClient.self] }
        set { self[NetworkClient.self] = newValue }
    }
}

// MARK: - Live value -
extension NetworkClient: DependencyKey {
    
    public static var liveValue: NetworkClient {
        let liveHelper = LiveHelper()
        
        return Self(
            fetchCharacters: { page in
                try await liveHelper.fetchCharacters(page: page)
            }
        )
    }
}

// MARK: - Live Helper
extension NetworkClient {
    
    struct LiveHelper {
        
        func fetchCharacters(page: Int) async throws -> NonEmptyArray<CharacterResult> {
            var comps = URLComponents(string: "https://rickandmortyapi.com/api/character")!
            comps.queryItems = [ .init(name: "page", value: "\(page)") ]
            let request = URLRequest(url: comps.url!)
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedData = try JSONDecoder().decode(CharacterResponse.self, from: data)
            return decodedData.results
        }
    }
}

struct CharacterResponse: Decodable {
    
    let info: PageInfo
    let results: NonEmptyArray<CharacterResult>
}

struct PageInfo: Decodable {
    
    let count: Int
    let pages: Int
    let next: URL?
    let prev: URL?
}

struct CharacterResult: Decodable, Equatable, Identifiable {
    
    typealias Id = Tagged<CharacterResult, Int>
    
    let id: Id
    let name: NonEmptyString
    let status: NonEmptyString
    let species: NonEmptyString
    let gender: NonEmptyString
    let image: URL
}

enum APIError: Error, Equatable {
  case network(String)
  case decoding(String)
  case unknown

}
