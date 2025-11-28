//
//  AppRepository.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import Foundation

protocol AppRepositoryProtocol {
    func fetchCharacters(page: Int) async throws -> [Character]
    func fetchCharacterDetails(_ id: Int) async throws -> Character
}

final class AppRepository: AppRepositoryProtocol {
    let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchCharacters(page: Int) async throws -> [Character] {
        return try await networkService.fetchCharacters(page)
    }
    
    func fetchCharacterDetails(_ id: Int) async throws -> Character {
        return try await networkService.fetchCharacterDetails(id)
    }
}
