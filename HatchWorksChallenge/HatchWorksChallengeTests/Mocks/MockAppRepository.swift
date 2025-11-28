//
//  MockAppRepository.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import Foundation
@testable import HatchWorksChallenge

final class MockAppRepository: AppRepositoryProtocol {
    
    var fetchCharactersResult: Result<[HatchWorksChallenge.Character], Error>?
    var fetchCharacterDetailsResult: Result<HatchWorksChallenge.Character, Error>?
    
    private(set) var fetchCharactersCalls: [Int] = []
    private(set) var fetchCharacterDetailsCalls: [Int] = []
    private(set) var lastFetchCharactersPage: Int?
    private(set) var lastFetchCharacterDetailsId: Int?
    
    var shouldDelay: Bool = false
    var delayDuration: UInt64 = 100_000_000
    
    var fetchCharactersCallCount: Int {
        fetchCharactersCalls.count
    }
    
    var fetchCharacterDetailsCallCount: Int {
        fetchCharacterDetailsCalls.count
    }
    
    func fetchCharacters(page: Int) async throws -> [HatchWorksChallenge.Character] {
        fetchCharactersCalls.append(page)
        lastFetchCharactersPage = page
        
        if shouldDelay {
            try? await Task.sleep(nanoseconds: delayDuration)
        }
        
        guard let result = fetchCharactersResult else { fatalError("MockAppRepository.fetchCharactersResult not configured") }
        
        switch result {
        case .success(let characters):
            return characters
        case .failure(let error):
            throw error
        }
    }
    
    func fetchCharacterDetails(_ id: Int) async throws -> HatchWorksChallenge.Character {
        fetchCharacterDetailsCalls.append(id)
        lastFetchCharacterDetailsId = id
        
        if shouldDelay {
            try? await Task.sleep(nanoseconds: delayDuration)
        }
        
        guard let result = fetchCharacterDetailsResult else { fatalError("MockAppRepository.fetchCharacterDetailsResult not configured") }
        
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
        shouldDelay = false
    }
    
    func setupFetchCharactersSuccess(_ characters: [Character]) {
        fetchCharactersResult = .success(characters)
    }
    
    func setupFetchCharactersFailure(error: Error) {
        fetchCharactersResult = .failure(error)
    }
    
    func setupFetchCharacterDetailsSuccess(_ character: Character) {
        fetchCharacterDetailsResult = .success(character)
    }
    
    func setupFetchCharacterDetailsFailure(error: Error) {
        fetchCharacterDetailsResult = .failure(error)
    }
}
