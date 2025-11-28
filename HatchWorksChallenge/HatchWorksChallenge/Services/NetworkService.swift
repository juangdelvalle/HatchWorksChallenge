//
//  NetworkService.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchCharacters(_ page: Int) async throws -> [Character]
    func fetchCharacterDetails(_ id: Int) async throws -> Character
}

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

final class NetworkService: NetworkServiceProtocol {
    let baseURL: String = "https://dragonball-api.com/api/"
    let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchCharacters(_ page: Int = 1) async throws -> [Character] {
        let urlComponent = "characters?page=\(page)"
        let url = try verifyURL(urlComponent)
        
        let (data, response) = try await session.data(from: url)
        try verifyResponse(response)
        
        return try JSONDecoder().decode(CharactersWrapper.self, from: data).items
    }
    
    func fetchCharacterDetails(_ id: Int) async throws -> Character {
        let urlComponent = "characters/\(id)"
        let url = try verifyURL(urlComponent)
        
        let (data, response) = try await session.data(from: url)
        try verifyResponse(response)
        
        return try JSONDecoder().decode(Character.self, from: data)
    }

    private func verifyURL(_ urlComponent: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(urlComponent)") else {
            throw NetworkError.badURL
        }
        return url
    }
    
    private func verifyResponse(_ urlResponse: URLResponse) throws {
        guard let response = urlResponse as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        if !(200..<300).contains(response.statusCode) {
            throw NetworkError.invalidResponse
        }
    }
}
