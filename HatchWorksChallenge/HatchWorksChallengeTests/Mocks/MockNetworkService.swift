//
//  MockNetworkService.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import Foundation
@testable import HatchWorksChallenge

final class MockNetworkService: NetworkServiceProtocol {
    
    var fetchCharactersResult: Result<[Character], Error>?
    var fetchCharacterDetailsResult: Result<Character, Error>?
    
    private(set) var fetchCharactersCalls: [Int] = []
    private(set) var fetchCharacterDetailsCalls: [Int] = []
    
    var fetchCharactersCallCount: Int {
        fetchCharactersCalls.count
    }
    
    var fetchCharacterDetailsCallCount: Int {
        fetchCharacterDetailsCalls.count
    }
    
    func fetchCharacters(_ page: Int) async throws -> [HatchWorksChallenge.Character] {
        fetchCharactersCalls.append(page)
        
        guard let result = fetchCharactersResult else { fatalError("MockNetworkService.fetchCharacterResult not configured") }
        
        switch result {
        case .success(let characters):
            return characters
        case .failure(let error):
            throw error
        }
    }
    
    func fetchCharacterDetails(_ id: Int) async throws -> HatchWorksChallenge.Character {
        fetchCharacterDetailsCalls.append(id)
        
        guard let result = fetchCharacterDetailsResult else { fatalError("MockNetworkService.fetchCharacterDetailsCalls not configured") }
        
        switch result {
        case .success(let character):
            return character
        case .failure(let error):
            throw error
        }
    }
    
    func reset() {
        fetchCharactersResult = nil
        fetchCharacterDetailsResult = nil
        fetchCharactersCalls.removeAll()
        fetchCharacterDetailsCalls.removeAll()
    }
    
    func setupFetchCharactersSuccess(_ characters: [Character]) {
        fetchCharactersResult = .success(characters)
    }
    
    func setupFetchCharactersFailure(_ error: Error) {
        fetchCharactersResult = .failure(error)
    }
    
    func setupFetchCharacterDetailsSuccess(_ character: Character) {
        fetchCharacterDetailsResult = .success(character)
    }
    
    func setupFetchCharacterDetailsFailure(_ error: Error) {
        fetchCharacterDetailsResult = .failure(error)
    }
}
