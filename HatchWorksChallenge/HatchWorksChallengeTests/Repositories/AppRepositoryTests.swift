//
//  AppRepositoryTests.swift
//  HatchWorksChallengeTests
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import XCTest
@testable import HatchWorksChallenge

@MainActor
final class AppRepositoryTests: XCTestCase {
    
    var sut: AppRepository!
    var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = AppRepository(networkService: mockNetworkService)
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }

    func testFetchCharactersSuccess() async throws {
        let expectedCharacters = TestFixtures.successCharacters
        mockNetworkService.fetchCharactersResult = .success(expectedCharacters)
        
        let characters = try await sut.fetchCharacters(page: 1)
        
        XCTAssertEqual(characters, expectedCharacters)
        XCTAssertEqual(mockNetworkService.fetchCharactersCallCount, 1)
    }
    
    func testFetchCharactersPropagatesError() async throws {
        let expectedError = NetworkError.invalidResponse
        mockNetworkService.fetchCharactersResult = .failure(expectedError)
        
        do {
            _ = try await sut.fetchCharacters(page: 1)
            XCTFail("Expected to throw error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, expectedError)
        }
    }
    
    func testFetchCharactersHandlesEmptyArray() async throws {
        mockNetworkService.fetchCharactersResult = .success([])
        
        let characters = try await sut.fetchCharacters(page: 1)
        
        XCTAssertTrue(characters.isEmpty)
    }

    func testFetchCharactersDoesNotModifyData() async throws {
        let originalCharacters = TestFixtures.allCharacters
        mockNetworkService.fetchCharactersResult = .success(originalCharacters)
        
        let characters = try await sut.fetchCharacters(page: 1)
        
        XCTAssertEqual(characters, originalCharacters)
    }
    
    func testFetchCharacterDetailsSuccess() async throws {
        let expectedCharacter = TestFixtures.goku
        mockNetworkService.fetchCharacterDetailsResult = .success(expectedCharacter)
        
        let character = try await sut.fetchCharacterDetails(1)
        
        XCTAssertEqual(character.id, expectedCharacter.id)
        XCTAssertFalse(character.transformations?.isEmpty ?? true)
        XCTAssertEqual(mockNetworkService.fetchCharacterDetailsCallCount, 1)
    }
    
    func testFetchCharacterDetailsPropagatesError() async throws {
        let expectedError = NetworkError.invalidResponse
        mockNetworkService.fetchCharacterDetailsResult = .failure(expectedError)
        
        do {
            _ = try await sut.fetchCharacterDetails(1)
            XCTFail("Expected to throw error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, expectedError)
        }
    }
    
    func testMultipleCallsAreTracked() async throws {
        mockNetworkService.fetchCharactersResult = .success(TestFixtures.allCharacters)
        mockNetworkService.fetchCharacterDetailsResult = .success(TestFixtures.goku)
        
        _ = try await sut.fetchCharacters(page: 1)
        _ = try await sut.fetchCharacters(page: 2)
        _ = try await sut.fetchCharacterDetails(1)
        
        XCTAssertEqual(mockNetworkService.fetchCharactersCallCount, 2)
        XCTAssertEqual(mockNetworkService.fetchCharacterDetailsCallCount, 1)
    }
    
    func testSequentialCallsWithDifferentParameters() async throws {
        mockNetworkService.fetchCharactersResult = .success([])
        
        _ = try await sut.fetchCharacters(page: 1)
        _ = try await sut.fetchCharacters(page: 2)
        _ = try await sut.fetchCharacters(page: 3)
        
        XCTAssertEqual(mockNetworkService.fetchCharactersCallCount, 3)
    }
}
